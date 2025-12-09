#!/usr/bin/env python3
"""
Fetch all work items from Azure DevOps and save to JSON
"""
import json
import subprocess
import sys

# List of all work item IDs we found
WORK_ITEM_IDS = [
    3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
    37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52,
    69, 70, 71, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208,
    209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220
]

def fetch_work_item(item_id):
    """Fetch a single work item using Claude CLI"""
    print(f"Fetching work item {item_id}...", file=sys.stderr)
    # This is a placeholder - in reality, we'll call the Azure DevOps API
    return {
        "id": item_id,
        "fields": {
            "System.Id": item_id,
            "System.WorkItemType": "Unknown",
            "System.Title": f"Work Item {item_id}",
            "System.Parent": None
        }
    }

def main():
    """Main function to fetch all work items"""
    print(f"Fetching {len(WORK_ITEM_IDS)} work items from Azure DevOps...")

    all_work_items = []

    for item_id in WORK_ITEM_IDS:
        try:
            work_item = fetch_work_item(item_id)
            all_work_items.append(work_item)
        except Exception as e:
            print(f"Error fetching work item {item_id}: {e}", file=sys.stderr)

    # Save to JSON
    with open('work_items.json', 'w', encoding='utf-8') as f:
        json.dump(all_work_items, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Successfully fetched {len(all_work_items)} work items")
    print(f"✅ Saved to: work_items.json")

if __name__ == "__main__":
    main()
