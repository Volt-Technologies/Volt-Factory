#!/usr/bin/env python3
"""
PDF Visual Comparison Tool
Converts PDFs to images and compares them visually to identify differences.
"""

import sys
import os
from pathlib import Path

try:
    from PIL import Image, ImageChops, ImageDraw, ImageFont
    import fitz  # PyMuPDF
except ImportError as e:
    print(f"ERROR: Missing required library: {e}")
    print("\nPlease install required packages:")
    print("  pip install PyMuPDF Pillow")
    sys.exit(1)

def pdf_to_image(pdf_path, page_num=0, dpi=150):
    """Convert first page of PDF to image."""
    try:
        doc = fitz.open(pdf_path)
        if page_num >= len(doc):
            page_num = 0
        page = doc[page_num]
        zoom = dpi / 72  # 72 is default DPI
        mat = fitz.Matrix(zoom, zoom)
        pix = page.get_pixmap(matrix=mat)
        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
        doc.close()
        return img
    except Exception as e:
        print(f"Error converting PDF to image: {e}")
        return None

def compare_images(img1, img2, output_diff=None):
    """Compare two images and highlight differences."""
    # Ensure same size
    if img1.size != img2.size:
        print(f"Warning: Images have different sizes: {img1.size} vs {img2.size}")
        # Resize to match
        img2 = img2.resize(img1.size, Image.Resampling.LANCZOS)
    
    # Convert to RGB if needed
    if img1.mode != 'RGB':
        img1 = img1.convert('RGB')
    if img2.mode != 'RGB':
        img2 = img2.convert('RGB')
    
    # Calculate difference
    diff = ImageChops.difference(img1, img2)
    
    # Get bounding box of differences
    bbox = diff.getbbox()
    
    if bbox:
        print(f"Differences found in region: {bbox}")
        
        # Create annotated difference image
        diff_annotated = img1.copy()
        draw = ImageDraw.Draw(diff_annotated)
        
        # Highlight differences with red boxes
        diff_mask = diff.convert('L')
        threshold = 30
        diff_mask = diff_mask.point(lambda x: 255 if x > threshold else 0)
        
        # Find contours/regions of differences
        import numpy as np
        try:
            diff_array = np.array(diff_mask)
            from scipy import ndimage
            labeled, num_features = ndimage.label(diff_array > threshold)
            
            # Draw boxes around differences
            for i in range(1, num_features + 1):
                coords = np.where(labeled == i)
                if len(coords[0]) > 0:
                    y_min, y_max = coords[0].min(), coords[0].max()
                    x_min, x_max = coords[1].min(), coords[1].max()
                    draw.rectangle([x_min, y_min, x_max, y_max], outline='red', width=3)
        except ImportError:
            # Fallback: draw rectangle around entire difference area
            draw.rectangle(bbox, outline='red', width=3)
        
        if output_diff:
            diff_annotated.save(output_diff)
            print(f"Difference image saved to: {output_diff}")
        
        return diff_annotated, bbox
    else:
        print("No differences found - images are identical!")
        return None, None

def analyze_layout_differences(img1, img2, diff_img=None):
    """Analyze layout differences between images."""
    differences = {
        'colors': [],
        'layout': [],
        'text_regions': [],
        'spacing': [],
        'regions': []
    }
    
    # Simple analysis: compare color histograms
    hist1 = img1.histogram()
    hist2 = img2.histogram()
    
    # Compare RGB channels
    for channel in range(3):
        channel_hist1 = hist1[channel*256:(channel+1)*256]
        channel_hist2 = hist2[channel*256:(channel+1)*256]
        
        # Calculate difference
        diff_sum = sum(abs(a - b) for a, b in zip(channel_hist1, channel_hist2))
        if diff_sum > 10000:  # Threshold
            differences['colors'].append(f"Channel {['R','G','B'][channel]} differs significantly")
    
    # Analyze difference regions if diff image provided
    if diff_img:
        try:
            import numpy as np
            diff_array = np.array(diff_img.convert('L'))
            
            # Find regions with significant differences (threshold)
            threshold = 30
            diff_regions = diff_array > threshold
            
            # Calculate percentage of different pixels
            total_pixels = diff_array.size
            diff_pixels = np.sum(diff_regions)
            diff_percentage = (diff_pixels / total_pixels) * 100
            
            differences['regions'].append({
                'diff_percentage': diff_percentage,
                'diff_pixels': int(diff_pixels),
                'total_pixels': int(total_pixels)
            })
            
            # Find top/bottom/left/right regions with differences
            rows_with_diff = np.any(diff_regions, axis=1)
            cols_with_diff = np.any(diff_regions, axis=0)
            
            if np.any(rows_with_diff):
                top_diff = np.argmax(rows_with_diff)
                bottom_diff = len(rows_with_diff) - np.argmax(rows_with_diff[::-1]) - 1
                differences['layout'].append(f"Vertical differences: top={top_diff}px, bottom={bottom_diff}px")
            
            if np.any(cols_with_diff):
                left_diff = np.argmax(cols_with_diff)
                right_diff = len(cols_with_diff) - np.argmax(cols_with_diff[::-1]) - 1
                differences['layout'].append(f"Horizontal differences: left={left_diff}px, right={right_diff}px")
                
        except ImportError:
            pass
    
    return differences

def main():
    if len(sys.argv) < 3:
        print("Usage: python bc-compare-pdf-visual.py <example.pdf> <generated.pdf> [output_dir]")
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
    
    print(f"Example PDF image size: {img_example.size}")
    print(f"Generated PDF image size: {img_generated.size}")
    
    # Save individual images
    img_example.save(output_dir / "example.png")
    img_generated.save(output_dir / "generated.png")
    print(f"Saved images to {output_dir}")
    
    # Compare images
    print("\nComparing images...")
    diff_img, diff_bbox = compare_images(
        img_example, 
        img_generated,
        output_diff=str(output_dir / "differences.png")
    )
    
    # Analyze differences
    print("\nAnalyzing layout differences...")
    diff_img_for_analysis = Image.open(output_dir / "differences.png") if (output_dir / "differences.png").exists() else None
    differences = analyze_layout_differences(img_example, img_generated, diff_img_for_analysis)
    
    if differences['colors']:
        print("\nColor differences detected:")
        for diff in differences['colors']:
            print(f"  - {diff}")
    
    if differences['regions']:
        print("\nDifference regions:")
        for region in differences['regions']:
            print(f"  - {region['diff_percentage']:.2f}% of pixels differ ({region['diff_pixels']:,} / {region['total_pixels']:,} pixels)")
    
    if differences['layout']:
        print("\nLayout differences:")
        for diff in differences['layout']:
            print(f"  - {diff}")
    
    if diff_bbox:
        print(f"\nVisual differences found!")
        print(f"Difference region: {diff_bbox}")
        print(f"Difference image saved to: {output_dir / 'differences.png'}")
    else:
        print("\n✓ No visual differences detected - PDFs appear identical!")
    
    # Create side-by-side comparison
    print("\nCreating side-by-side comparison...")
    width = max(img_example.width, img_generated.width)
    height = max(img_example.height, img_generated.height)
    
    comparison = Image.new('RGB', (width * 2 + 20, height), color='white')
    comparison.paste(img_example, (0, 0))
    comparison.paste(img_generated, (width + 20, 0))
    
    # Add labels
    draw = ImageDraw.Draw(comparison)
    try:
        font = ImageFont.truetype("arial.ttf", 20)
    except:
        font = ImageFont.load_default()
    
    draw.text((10, 10), "Example PDF", fill='black', font=font)
    draw.text((width + 30, 10), "Generated PDF", fill='black', font=font)
    
    comparison.save(output_dir / "side_by_side.png")
    print(f"Side-by-side comparison saved to: {output_dir / 'side_by_side.png'}")
    
    print(f"\nComparison complete! Check {output_dir} for results.")

if __name__ == "__main__":
    main()

