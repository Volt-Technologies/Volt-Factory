# Feature Tracking System

## Overview

The Volt Factory feature tracking system provides centralized management of features, user stories, and their progress through all development stages.

## features.json Structure

The `features.json` file at the root of the project tracks all features and their status:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "version": "1.0.0",
  "last_updated": "2025-11-14",
  "features": [
    {
      "id": "unique-feature-id",
      "name": "Feature Name",
      "description": "Feature description",
      "created_date": "2025-11-14",
      "updated_date": "2025-11-14",
      "stages": {
        "research": {
          "status": "completed",
          "started_date": "2025-11-14",
          "completed_date": "2025-11-14",
          "notes": ""
        },
        "functional_design": {...},
        "technical_design": {...},
        "development": {...},
        "unit_test": {...},
        "documentation": {...}
      },
      "user_stories": [
        {
          "id": "US-001",
          "name": "User Story Name",
          "description": "As a [role], I want [action] so that [benefit]",
          "status": "in_progress",
          "created_date": "2025-11-14",
          "updated_date": "2025-11-14"
        }
      ]
    }
  ]
}
```

## Stage Statuses

Each stage can have one of the following statuses:

- **not_started**: Stage hasn't been started yet
- **in_progress**: Stage is currently being worked on
- **completed**: Stage has been finished
- **skipped**: Stage was intentionally skipped

## Factory Folder Structure

When a feature is created, folders are automatically created in:

```
factory/
  1research/{feature_name}/
  2functional_design/{feature_name}/
  3technical_design/{feature_name}/
  4development/{feature_name}/
  5unit_test/{feature_name}/
  6documentation/{feature_name}/

BC/
  src/{feature_name}/

BC Test/
  src/{feature_name}/
```

## Available Commands

### 1. /add_feature

Creates a new feature in the system.

**Usage:**
```bash
/add_feature feature_name:"Customer Portal" feature_description:"Self-service portal for customers"
```

**What it does:**
- Adds feature entry to features.json
- Creates all factory stage folders
- Creates BC/src folder
- Creates BC Test/src folder
- Initializes README files

### 2. /feature_status

Displays the current status of all features.

**Usage:**
```bash
/feature_status
```

**What it shows:**
- Summary statistics
- Feature details with stage progress
- Visual indicators (✅ ⏸️ 🔄)
- User story counts

### 3. /update_feature_stage

Updates the status of a specific stage for a feature.

**Usage:**
```bash
/update_feature_stage feature_id:"product-attributes" stage:"development" status:"completed" notes:"All development completed"
```

**Parameters:**
- `feature_id`: The ID of the feature (lowercase with hyphens)
- `stage`: One of: research, functional_design, technical_design, development, unit_test, documentation
- `status`: One of: not_started, in_progress, completed, skipped
- `notes`: Optional notes about the update

**What it does:**
- Updates stage status
- Sets started_date when moving from not_started
- Sets completed_date when marking as completed
- Updates feature's updated_date
- Adds notes if provided

### 4. /add_user_story

Adds a new user story to an existing feature.

**Usage:**
```bash
/add_user_story feature_id:"product-attributes" story_id:"US-005" story_name:"Export Attributes" story_description:"As a data analyst, I want to export attributes so that I can analyze them in Excel"
```

**What it does:**
- Adds user story to features.json
- Creates folders in functional_design and technical_design stages
- Creates README files with user story details

## Workflow Example

### Creating a New Feature

1. **Create the feature:**
   ```bash
   /add_feature feature_name:"Inventory Management" feature_description:"Track and manage inventory levels"
   ```

2. **Start research stage:**
   ```bash
   /update_feature_stage feature_id:"inventory-management" stage:"research" status:"in_progress"
   ```

3. **Complete research:**
   ```bash
   /update_feature_stage feature_id:"inventory-management" stage:"research" status:"completed" notes:"Research completed with initial findings"
   ```

4. **Add user stories:**
   ```bash
   /add_user_story feature_id:"inventory-management" story_id:"US-001" story_name:"View Inventory Levels" story_description:"As a warehouse manager, I want to view current inventory levels so that I can plan replenishment"
   ```

5. **Check status:**
   ```bash
   /feature_status
   ```

### Tracking Progress

The features.json file serves as the single source of truth for:

- Feature existence and description
- Current stage of each feature
- User stories within each feature
- Dates for tracking progress
- Notes and context

## Benefits

1. **Centralized Tracking**: Single file shows all features and their status
2. **Automated Folder Creation**: Consistent folder structure
3. **Date Tracking**: Know when stages started and completed
4. **User Story Management**: Track user stories within features
5. **Easy Reporting**: Query features.json for reports and dashboards
6. **Git-Friendly**: JSON format works well with version control

## Maintenance

- Update stage statuses as work progresses
- Add notes when completing stages to capture context
- Keep user story descriptions clear and concise
- Review features.json regularly to track overall progress

## Future Enhancements

Potential additions to the system:
- Automated status updates based on folder contents
- Integration with Azure DevOps work items
- Progress dashboards
- Burndown charts
- Team member assignments
- Time tracking per stage
