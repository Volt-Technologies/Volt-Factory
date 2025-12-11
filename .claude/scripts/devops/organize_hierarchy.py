#!/usr/bin/env python3
"""
Organize Azure DevOps work items into Epic -> Feature hierarchy
and generate a processing plan for the bc-functional-designer agent
"""
import json

# Mapping of work items based on what we know:
# - Epics: IDs 3-28, 69-71, 199 (no parent)
# - Features: IDs 29-52, 200-220 (have parent pointing to Epic)

EPIC_IDS = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
            21, 22, 23, 24, 25, 26, 27, 28, 69, 70, 71, 199]

FEATURE_IDS = [29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44,
               45, 46, 47, 48, 49, 50, 51, 52, 200, 201, 202, 203, 204, 205,
               206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217,
               218, 219, 220]

# Epic titles (from the data we saw)
EPIC_TITLES = {
    3: "Seasonality",
    4: "Vendor Management",
    5: "Sales Pricing",
    6: "Licensing/Royalties",
    7: "Sample Management",
    8: "CRM/Call Center",
    9: "Bulk Order",
    10: "Order Entry",
    11: "Order Entry Advanced",
    12: "Gift Cards",
    13: "Catalogs and assortments",
    14: "Planning",
    15: "Custom/Special Orders",
    16: "Value Added Services - Upcharge",
    17: "Bundling/Kitting",
    18: "Allocation",
    19: "Inventory Allocation per Channel",
    20: "Automated Release",
    21: "Vendor Portal",
    22: "WMS Enhancements",
    23: "Integration Framework 3PLs",
    24: "Retail/Consignment Stores",
    25: "Retail Replanishment",
    26: "DOM",
    27: "Returns",
    28: "Charge Backs",
    69: "PIM",
    70: "PLM",
    71: "Order Entry Agent",
    199: "Product / Variant Management"
}

# Feature titles
FEATURE_TITLES = {
    29: "Product Attributes",
    30: "Product Lifecycle",
    31: "Base changing",
    32: "Pre-season/Order Management",
    33: "MOQ",
    34: "Standard order quantities",
    35: "Vendor Costing",
    36: "Purchase Agreemeents",
    37: "Vendor Pricing",
    38: "Lead times",
    39: "Coupons",
    40: "Rebates",
    41: "Margins",
    42: "Markdowns",
    43: "CRSs manual orders",
    44: "Excel upload",
    45: "B2B Portal",
    46: "Ecomm sites (Shopify)",
    47: "Consignment/ Dropshipping",
    48: "Marketplaces",
    49: "EDI",
    50: "Show rooms",
    51: "ASN",
    52: "Order Updates",
    200: "Variant management",
    201: "Licensing / Royalty reporting",
    202: "Sample product status",
    203: "CE Integration for call center",
    204: "Bulk Order draw down pages and automation",
    205: "gift card table and page",
    206: "Create catalog and or assortments pages",
    207: "Open to buy",
    208: "custom product identifier and description",
    209: "VAS attributes at SO header and lines plus customer requirements storage",
    210: "advanced kitting logic",
    211: "Soft allocation",
    212: "Inventory allocation framework",
    213: "Automated order release",
    214: "Advanced warehousing for retail / apparel",
    215: "3Pl integration framework",
    216: "Consignment module",
    217: "Automated Transfer Order creation logic",
    218: "DOM engine",
    219: "Retail / Apparel specific mass end of the season return features",
    220: "Charge back workspace - see F&O"
}

# Known parent-child relationships (from relation data)
# Epic 4 (Vendor Management) has children: 38, 34, 33, 37, 35, 36
# Epic 69 (PIM) has child: 29
# Epic 199 (Product / Variant Management) has child: 200
# Epic 6 (Licensing/Royalties) has child: 201

FEATURE_TO_EPIC = {
    29: 69,   # Product Attributes -> PIM
    33: 4,    # MOQ -> Vendor Management
    34: 4,    # Standard order quantities -> Vendor Management
    35: 4,    # Vendor Costing -> Vendor Management
    36: 4,    # Purchase Agreements -> Vendor Management
    37: 4,    # Vendor Pricing -> Vendor Management
    38: 4,    # Lead times -> Vendor Management
    200: 199, # Variant management -> Product / Variant Management
    201: 6,   # Licensing / Royalty reporting -> Licensing/Royalties
    202: 7,   # Sample product status -> Sample Management (assumption)
    203: 8,   # CE Integration for call center -> CRM/Call Center (assumption)
    204: 9,   # Bulk Order draw down pages -> Bulk Order (assumption)
    205: 12,  # gift card table -> Gift Cards (assumption)
    206: 13,  # Create catalog -> Catalogs and assortments (assumption)
    207: 14,  # Open to buy -> Planning (assumption)
    208: 15,  # custom product identifier -> Custom/Special Orders (assumption)
    209: 16,  # VAS attributes -> Value Added Services - Upcharge (assumption)
    210: 17,  # advanced kitting logic -> Bundling/Kitting (assumption)
    211: 18,  # Soft allocation -> Allocation (assumption)
    212: 19,  # Inventory allocation framework -> Inventory Allocation per Channel (assumption)
    213: 20,  # Automated order release -> Automated Release (assumption)
    214: 22,  # Advanced warehousing -> WMS Enhancements (assumption)
    215: 23,  # 3Pl integration -> Integration Framework 3PLs (assumption)
    216: 24,  # Consignment module -> Retail/Consignment Stores (assumption)
    217: 25,  # Automated Transfer Order -> Retail Replanishment (assumption)
    218: 26,  # DOM engine -> DOM (assumption)
    219: 27,  # Retail returns -> Returns (assumption)
    220: 28,  # Charge back workspace -> Charge Backs (assumption)
    # Features 30-32, 39-52 need parent assignment - will query Azure DevOps
}

def generate_processing_plan():
    """Generate a list of features to process with their epic context"""
    plan = []

    for feature_id in FEATURE_IDS:
        epic_id = FEATURE_TO_EPIC.get(feature_id)

        if epic_id:
            plan.append({
                "feature_id": feature_id,
                "feature_title": FEATURE_TITLES.get(feature_id, f"Feature {feature_id}"),
                "epic_id": epic_id,
                "epic_title": EPIC_TITLES.get(epic_id, f"Epic {epic_id}"),
                "wiki_path": f"wiki/{EPIC_TITLES.get(epic_id, f'Epic-{epic_id}')}/{FEATURE_TITLES.get(feature_id, f'Feature-{feature_id}')}.md"
            })

    # Save to JSON
    with open('feature_processing_plan.json', 'w', encoding='utf-8') as f:
        json.dump(plan, f, indent=2, ensure_ascii=False)

    return plan

def print_plan(plan):
    """Print the processing plan"""
    print(f"\n{'='*80}")
    print(f"FEATURE PROCESSING PLAN - {len(plan)} Features to Process")
    print(f"{'='*80}\n")

    current_epic = None
    for item in plan:
        if item['epic_title'] != current_epic:
            current_epic = item['epic_title']
            print(f"\n📘 EPIC: {current_epic}")

        print(f"  📗 Feature {item['feature_id']}: {item['feature_title']}")
        print(f"     → {item['wiki_path']}")

    print(f"\n{'='*80}")
    print(f"Total: {len(plan)} features across {len(set(item['epic_id'] for item in plan))} epics")
    print(f"{'='*80}\n")

if __name__ == "__main__":
    plan = generate_processing_plan()
    print_plan(plan)
    print(f"✅ Processing plan saved to: feature_processing_plan.json")
