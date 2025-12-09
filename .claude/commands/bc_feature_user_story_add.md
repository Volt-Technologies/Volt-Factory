---
description: Add a new user story to a feature in the factory system
args:
  feature_id:
    description: The ID of the feature (e.g., "product-attributes")
    required: true
  story_id:
    description: The ID for the user story (e.g., "US-001" or "01_Story_Name")
    required: true
  story_name:
    description: The name of the user story
    required: true
  story_description:
    description: Description of the user story (preferably in "As a [role], I want [action] so that [benefit]" format)
    required: false
---

# Add User Story to Feature

You are being asked to add a new user story to an existing feature in the Volt Factory system.

## Task Overview

Add a new user story to the specified feature and create corresponding folders in the functional design and technical design stages.

## Arguments Provided

- **Feature ID**: {{feature_id}}
- **Story ID**: {{story_id}}
- **Story Name**: {{story_name}}
- **Story Description**: {{story_description}}

## Steps to Execute

1. **Update factory/features.json**:
   - Read the current factory/features.json file
   - Find the feature with the specified feature_id
   - Add the new user story to the user_stories array
   - Set created_date and updated_date to today
   - Set status to "not_started"
   - Update the feature's updated_date
   - Write the updated factory/features.json file

2. **Create Functional Design Folders** (if functional_design stage is in_progress or completed):
   - Create folder: `factory/2functional_design/{feature_name}/{story_id}/`
   - Create README.md with user story details

3. **Create Technical Design Folders** (if technical_design stage is in_progress or completed):
   - Create folder: `factory/3technical_design/{feature_name}/{story_id}/`
   - Create README.md with user story details

## User Story Format

```json
{
  "id": "US-001",
  "name": "Configure Product Attributes",
  "description": "As a product manager, I want to configure product attributes so that I can categorize products effectively",
  "status": "not_started",
  "created_date": "2025-11-14",
  "updated_date": "2025-11-14"
}
```

## Valid Statuses

- `not_started` - User story has not been started (default)
- `in_progress` - User story is being worked on
- `completed` - User story has been implemented and tested

## Validation

1. Verify the feature_id exists in factory/features.json
2. Verify the story_id is unique within the feature's user stories
3. Provide clear error messages if validation fails

## Folder Structure

For each user story, create folders in applicable stages:

```
factory/
  2functional_design/
    {feature_name}/
      {story_id}/
        README.md
  3technical_design/
    {feature_name}/
      {story_id}/
        README.md
```

## README Template

Create a README.md in each folder with:

```markdown
# {story_name}

**Feature**: {feature_name}
**Story ID**: {story_id}
**Status**: {status}

## Description

{story_description}

## Created

{created_date}
```

## Success Output

After adding, display:
- Feature name and ID
- User story added
- Story ID and name
- Folders created
- Summary of changes

Please proceed with adding the user story.
