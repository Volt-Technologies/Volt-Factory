---
description: Update the status of a feature stage in the factory system
args:
  feature_id:
    description: The ID of the feature (e.g., "product-attributes")
    required: true
  stage:
    description: The stage to update (research, functional_design, technical_design, development, unit_test, documentation)
    required: true
  status:
    description: The new status (not_started, in_progress, completed, skipped)
    required: true
  notes:
    description: Optional notes about the stage update
    required: false
---

# Update Feature Stage

You are being asked to update the status of a feature stage in the Volt Factory system.

## Task Overview

Update a specific stage of a feature with a new status and optional notes.

## Arguments Provided

- **Feature ID**: {{feature_id}}
- **Stage**: {{stage}}
- **Status**: {{status}}
- **Notes**: {{notes}}

## Valid Stages

- `research` - Initial research phase
- `functional_design` - Functional design documentation
- `technical_design` - Technical design and architecture
- `development` - Implementation phase
- `unit_test` - Testing phase
- `documentation` - Documentation phase

## Valid Statuses

- `not_started` - Stage has not been started
- `in_progress` - Stage is currently being worked on
- `completed` - Stage has been completed
- `skipped` - Stage has been intentionally skipped

## Steps to Execute

1. Read the current factory/features.json file
2. Find the feature with the specified feature_id
3. Update the specified stage with:
   - New status
   - Set started_date to today if status changes from not_started to in_progress
   - Set completed_date to today if status changes to completed
   - Add notes if provided
4. Update the feature's updated_date to today
5. Update the last_updated field at the root level
6. Write the updated factory/features.json file
7. Display a summary of the update

## Important Rules

1. **Date Management**:
   - Set `started_date` when status changes from `not_started` to `in_progress` or `completed`
   - Set `completed_date` when status changes to `completed`
   - Clear `completed_date` if status changes from `completed` to something else
   - Preserve existing dates unless the status transition requires a change

2. **Validation**:
   - Verify the feature_id exists
   - Verify the stage name is valid
   - Verify the status is valid
   - Provide clear error messages if validation fails

3. **Preserve Data**:
   - Keep all other feature data unchanged
   - Keep all other features unchanged

## Example Update

```json
"stages": {
  "development": {
    "status": "completed",
    "started_date": "2025-11-10",
    "completed_date": "2025-11-14",
    "notes": "All development tasks completed successfully"
  }
}
```

## Success Output

After updating, display:
- Feature name and ID
- Stage that was updated
- Old status -> New status
- Dates set/updated
- Notes added (if any)

Please proceed with updating the feature stage.
