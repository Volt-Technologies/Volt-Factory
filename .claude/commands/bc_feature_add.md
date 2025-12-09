---
description: Create a new feature in the factory system with folder structure and features.json entry
args:
  feature_name:
    description: The name of the new feature (e.g., "Customer Portal")
    required: true
  feature_description:
    description: A brief description of the feature
    required: false
---

# Add New Feature to Factory

You are being asked to create a new feature in the Volt Factory system.

## Task Overview

Create a new feature with the following components:

1. **Update features.json**: Add a new feature entry with:
   - Generate a unique ID from the feature name (lowercase, hyphenated)
   - Set the feature name and description
   - Initialize all stages to "not_started" status
   - Set created_date and updated_date to today's date
   - Initialize empty user_stories array

2. **Create Factory Folders**: Create the feature folder in each factory stage:
   - `factory/1research/{feature_name}/`
   - `factory/2functional_design/{feature_name}/`
   - `factory/3technical_design/{feature_name}/`
   - `factory/4development/{feature_name}/`
   - `factory/5unit_test/{feature_name}/`
   - `factory/6documentation/{feature_name}/`

3. **Create BC App Folders**: Create the feature folder in the BC app:
   - `BC/src/{feature_name}/`

4. **Create BC Test Folders**: Create the feature folder in the BC test app:
   - `BC Test/src/{feature_name}/`

## Arguments Provided

- **Feature Name**: {{feature_name}}
- **Feature Description**: {{feature_description}}

## Important Guidelines

1. **Generate ID**: Convert feature name to lowercase with hyphens (e.g., "Customer Portal" -> "customer-portal")
2. **Date Format**: Use YYYY-MM-DD format for dates
3. **Preserve Existing Data**: When updating features.json, preserve all existing features
4. **Create README Files**: Create a README.md file in each factory stage folder with basic information about the feature

## Steps to Execute

1. Read the current features.json file
2. Generate the feature ID from the feature name
3. Create the new feature object with all required fields
4. Add the new feature to the features array
5. Write the updated features.json file
6. Create all required folders in factory stages
7. Create folder in BC/src
8. Create folder in BC Test/src
9. Create README.md files in each factory folder with basic feature information
10. Report completion with summary of created folders

## Example Feature Entry

```json
{
  "id": "customer-portal",
  "name": "Customer Portal",
  "description": "Self-service portal for customers to view orders and invoices",
  "created_date": "2025-11-14",
  "updated_date": "2025-11-14",
  "stages": {
    "research": {
      "status": "not_started",
      "started_date": null,
      "completed_date": null,
      "notes": ""
    },
    "functional_design": {
      "status": "not_started",
      "started_date": null,
      "completed_date": null,
      "notes": ""
    },
    "technical_design": {
      "status": "not_started",
      "started_date": null,
      "completed_date": null,
      "notes": ""
    },
    "development": {
      "status": "not_started",
      "started_date": null,
      "completed_date": null,
      "notes": ""
    },
    "unit_test": {
      "status": "not_started",
      "started_date": null,
      "completed_date": null,
      "notes": ""
    },
    "documentation": {
      "status": "not_started",
      "started_date": null,
      "completed_date": null,
      "notes": ""
    }
  },
  "user_stories": []
}
```

## Success Criteria

- features.json is updated with the new feature
- All factory stage folders are created
- BC/src folder is created
- BC Test/src folder is created
- README.md files are created in each factory folder
- No existing data is lost or modified

Please proceed with creating the new feature.
