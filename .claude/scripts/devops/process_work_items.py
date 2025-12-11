import json
import os
from pathlib import Path

# Work items data will be loaded from a JSON file
work_items_file = "work_items.json"

def load_work_items():
    """Load work items from JSON file"""
    with open(work_items_file, 'r') as f:
        return json.load(f)

def organize_hierarchy(work_items):
    """Organize work items into Epic -> Feature -> User Story hierarchy"""
    # Create lookup dictionaries
    items_by_id = {item['id']: item for item in work_items}

    # Organize by type
    epics = []
    features = []
    user_stories = []

    for item in work_items:
        item_type = item.get('fields', {}).get('System.WorkItemType', '')
        parent_id = item.get('fields', {}).get('System.Parent')

        item_data = {
            'id': item['id'],
            'title': item['fields']['System.Title'],
            'type': item_type,
            'parent_id': parent_id,
            'children': []
        }

        if item_type == 'Epic':
            epics.append(item_data)
        elif item_type == 'Feature':
            features.append(item_data)
        elif item_type == 'User Story':
            user_stories.append(item_data)

    # Build hierarchy: attach features to epics and user stories to features
    epics_dict = {e['id']: e for e in epics}
    features_dict = {f['id']: f for f in features}

    for feature in features:
        if feature['parent_id'] and feature['parent_id'] in epics_dict:
            epics_dict[feature['parent_id']]['children'].append(feature)

    for story in user_stories:
        if story['parent_id'] and story['parent_id'] in features_dict:
            features_dict[story['parent_id']]['children'].append(story)

    return epics

def print_hierarchy(epics):
    """Print the work item hierarchy"""
    print(f"\n{'='*80}")
    print("WORK ITEM HIERARCHY")
    print(f"{'='*80}\n")

    for epic in epics:
        print(f"📘 EPIC {epic['id']}: {epic['title']}")
        for feature in epic['children']:
            print(f"  📗 FEATURE {feature['id']}: {feature['title']}")
            for story in feature['children']:
                print(f"    📄 USER STORY {story['id']}: {story['title']}")
        print()

def save_hierarchy_report(epics):
    """Save hierarchy to a text file"""
    with open('work_items_hierarchy.txt', 'w', encoding='utf-8') as f:
        f.write("="*80 + "\n")
        f.write("WORK ITEM HIERARCHY\n")
        f.write("="*80 + "\n\n")

        for epic in epics:
            f.write(f"📘 EPIC {epic['id']}: {epic['title']}\n")
            for feature in epic['children']:
                f.write(f"  📗 FEATURE {feature['id']}: {feature['title']}\n")
                for story in feature['children']:
                    f.write(f"    📄 USER STORY {story['id']}: {story['title']}\n")
            f.write("\n")

def generate_processing_list(epics):
    """Generate a list of features to process"""
    features_to_process = []

    for epic in epics:
        for feature in epic['children']:
            features_to_process.append({
                'epic_id': epic['id'],
                'epic_title': epic['title'],
                'feature_id': feature['id'],
                'feature_title': feature['title'],
                'user_stories': feature['children']
            })

    # Save to JSON for processing
    with open('features_to_process.json', 'w', encoding='utf-8') as f:
        json.dump(features_to_process, f, indent=2, ensure_ascii=False)

    return features_to_process

if __name__ == "__main__":
    # Load and organize work items
    work_items = load_work_items()
    epics = organize_hierarchy(work_items)

    # Print hierarchy
    print_hierarchy(epics)

    # Save reports
    save_hierarchy_report(epics)

    # Generate processing list
    features = generate_processing_list(epics)

    print(f"\n✅ Found {len(epics)} Epics with {len(features)} Features")
    print(f"✅ Saved hierarchy to: work_items_hierarchy.txt")
    print(f"✅ Saved processing list to: features_to_process.json")
