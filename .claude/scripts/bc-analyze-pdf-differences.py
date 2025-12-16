#!/usr/bin/env python3
"""
Detailed PDF Difference Analysis
Analyzes differences between example and generated PDFs to identify specific layout issues.
"""

import sys
from pathlib import Path

try:
    from PIL import Image, ImageChops, ImageDraw, ImageFont
    import fitz  # PyMuPDF
    import numpy as np
except ImportError as e:
    print(f"ERROR: Missing required library: {e}")
    print("\nPlease install required packages:")
    print("  py -m pip install PyMuPDF Pillow numpy")
    sys.exit(1)

def pdf_to_image(pdf_path, page_num=0, dpi=150):
    """Convert first page of PDF to image."""
    try:
        doc = fitz.open(pdf_path)
        if page_num >= len(doc):
            page_num = 0
        page = doc[page_num]
        zoom = dpi / 72
        mat = fitz.Matrix(zoom, zoom)
        pix = page.get_pixmap(matrix=mat)
        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
        doc.close()
        return img
    except Exception as e:
        print(f"Error converting PDF to image: {e}")
        return None

def analyze_differences_detailed(img1, img2, output_dir):
    """Perform detailed difference analysis."""
    print("\n=== DETAILED DIFFERENCE ANALYSIS ===\n")
    
    # Ensure same size
    if img1.size != img2.size:
        print(f"WARNING: Images have different sizes: {img1.size} vs {img2.size}")
        img2_resized = img2.resize(img1.size, Image.Resampling.LANCZOS)
    else:
        img2_resized = img2
    
    # Convert to RGB
    img1_rgb = img1.convert('RGB')
    img2_rgb = img2_resized.convert('RGB')
    
    # Calculate difference
    diff = ImageChops.difference(img1_rgb, img2_rgb)
    diff_array = np.array(diff.convert('L'))
    
    # Analyze by regions (divide into sections)
    height, width = diff_array.shape
    sections = {
        'header': (0, int(height * 0.15)),
        'title': (int(height * 0.15), int(height * 0.30)),
        'customer': (int(height * 0.30), int(height * 0.50)),
        'products': (int(height * 0.50), int(height * 0.75)),
        'totals': (int(height * 0.75), int(height * 0.90)),
        'footer': (int(height * 0.90), height)
    }
    
    print("Difference Analysis by Section:")
    print("-" * 60)
    
    threshold = 30
    total_diff_pixels = np.sum(diff_array > threshold)
    total_pixels = diff_array.size
    
    for section_name, (y_start, y_end) in sections.items():
        section_diff = diff_array[y_start:y_end, :]
        section_diff_pixels = np.sum(section_diff > threshold)
        section_total = section_diff.size
        section_percent = (section_diff_pixels / section_total * 100) if section_total > 0 else 0
        
        # Calculate average difference intensity
        avg_intensity = np.mean(section_diff) if section_diff.size > 0 else 0
        
        status = "HIGH" if section_percent > 50 else "MEDIUM" if section_percent > 20 else "LOW"
        
        print(f"{section_name.upper():12} | Diff: {section_percent:5.1f}% | Avg Intensity: {avg_intensity:5.1f} | Status: {status}")
    
    print("-" * 60)
    overall_percent = (total_diff_pixels / total_pixels * 100)
    print(f"{'OVERALL':12} | Diff: {overall_percent:5.1f}% | Total Diff Pixels: {total_diff_pixels:,} / {total_pixels:,}")
    
    # Find specific difference regions
    print("\n=== SPECIFIC DIFFERENCE REGIONS ===")
    
    # Find horizontal bands with differences
    row_diffs = np.sum(diff_array > threshold, axis=1)
    significant_rows = np.where(row_diffs > width * 0.1)[0]  # Rows with >10% differences
    
    if len(significant_rows) > 0:
        print(f"\nRows with significant differences: {len(significant_rows)} rows")
        print(f"  Range: row {significant_rows[0]} to {significant_rows[-1]}")
        print(f"  Vertical span: {significant_rows[-1] - significant_rows[0]} pixels")
    
    # Find vertical bands with differences
    col_diffs = np.sum(diff_array > threshold, axis=0)
    significant_cols = np.where(col_diffs > height * 0.1)[0]  # Cols with >10% differences
    
    if len(significant_cols) > 0:
        print(f"\nColumns with significant differences: {len(significant_cols)} columns")
        print(f"  Range: column {significant_cols[0]} to {significant_cols[-1]}")
        print(f"  Horizontal span: {significant_cols[-1] - significant_cols[0]} pixels")
    
    # Color analysis
    print("\n=== COLOR ANALYSIS ===")
    img1_array = np.array(img1_rgb)
    img2_array = np.array(img2_resized.convert('RGB'))
    
    # Calculate average colors in different regions
    for section_name, (y_start, y_end) in sections.items():
        section1 = img1_array[y_start:y_end, :, :]
        section2 = img2_array[y_start:y_end, :, :]
        
        avg_color1 = np.mean(section1, axis=(0, 1))
        avg_color2 = np.mean(section2, axis=(0, 1))
        
        color_diff = np.abs(avg_color1 - avg_color2)
        max_diff = np.max(color_diff)
        
        if max_diff > 10:  # Significant color difference
            print(f"{section_name.upper():12} | Example RGB: ({avg_color1[0]:.0f}, {avg_color1[1]:.0f}, {avg_color1[2]:.0f}) | "
                  f"Generated RGB: ({avg_color2[0]:.0f}, {avg_color2[1]:.0f}, {avg_color2[2]:.0f}) | "
                  f"Diff: {max_diff:.1f}")
    
    # Generate annotated difference image with section labels
    annotated = img1_rgb.copy()
    draw = ImageDraw.Draw(annotated)
    
    try:
        font = ImageFont.truetype("arial.ttf", 16)
    except:
        font = ImageFont.load_default()
    
    # Draw section boundaries
    colors = {'header': 'red', 'title': 'blue', 'customer': 'green', 'products': 'orange', 'totals': 'purple', 'footer': 'brown'}
    for section_name, (y_start, y_end) in sections.items():
        color = colors.get(section_name, 'black')
        draw.line([(0, y_start), (width, y_start)], fill=color, width=2)
        draw.text((10, y_start + 5), section_name.upper(), fill=color, font=font)
    
    annotated_path = output_dir / "annotated_differences.png"
    annotated.save(annotated_path)
    print(f"\nAnnotated difference image saved to: {annotated_path}")
    
    return {
        'overall_diff_percent': overall_percent,
        'sections': sections,
        'significant_rows': significant_rows,
        'significant_cols': significant_cols
    }

def main():
    if len(sys.argv) < 3:
        print("Usage: py bc-analyze-pdf-differences.py <example.pdf> <generated.pdf> [output_dir]")
        sys.exit(1)
    
    example_pdf = Path(sys.argv[1])
    generated_pdf = Path(sys.argv[2])
    output_dir = Path(sys.argv[3]) if len(sys.argv) > 3 else Path("pdfs/comparison")
    
    if not example_pdf.exists():
        print(f"ERROR: Example PDF not found: {example_pdf}")
        sys.exit(1)
    
    if not generated_pdf.exists():
        print(f"ERROR: Generated PDF not found: {generated_pdf}")
        sys.exit(1)
    
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("Converting PDFs to images...")
    img_example = pdf_to_image(str(example_pdf))
    img_generated = pdf_to_image(str(generated_pdf))
    
    if img_example is None or img_generated is None:
        print("ERROR: Failed to convert PDFs to images")
        sys.exit(1)
    
    print(f"Example PDF: {img_example.size[0]}x{img_example.size[1]} pixels")
    print(f"Generated PDF: {img_generated.size[0]}x{img_generated.size[1]} pixels")
    
    # Perform detailed analysis
    analysis = analyze_differences_detailed(img_example, img_generated, output_dir)
    
    print("\n=== RECOMMENDATIONS ===")
    print("Based on the analysis above, focus on sections with HIGH difference percentages.")
    print("Common issues to check:")
    print("  1. Font sizes and weights")
    print("  2. Colors (especially #0066CC blue and #FF6600 orange)")
    print("  3. Element positioning (Top/Left values)")
    print("  4. Spacing and padding")
    print("  5. Border styles and widths")
    print("  6. Column widths in tables")
    
    print(f"\nAnalysis complete! Check {output_dir} for detailed images.")

if __name__ == "__main__":
    main()

