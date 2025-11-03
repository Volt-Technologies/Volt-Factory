# Wiki Sync Setup Instructions

This document provides setup instructions for syncing your `wiki` folder from GitHub to an Azure DevOps Wiki repository using Azure DevOps Pipelines.

## Prerequisites

- GitHub repository with a `wiki` folder
- Azure DevOps project with a Wiki repository (typically named `ProjectName.wiki`)
- GitHub service connection configured in Azure DevOps
- Access to create pipelines and manage service connections

---

## Setup Steps

### Step 1: Configure the Pipeline File

Edit `azure-pipelines-wiki-sync.yml` and update these values:

```yaml
resources:
  repositories:
    - repository: github-source
      endpoint: YOUR_GITHUB_SERVICE_CONNECTION_NAME  # Your GitHub service connection
      name: YOUR_ORG/YOUR_REPO  # e.g., voltbc/volt-factory

variables:
  azureDevOpsOrg: 'VoltBC'  # Your org name
  azureDevOpsProject: 'Factory'  # Your project name
  wikiRepoName: 'Factory.wiki'  # Your wiki repo name (usually ProjectName.wiki)
```

### Step 2: Verify GitHub Service Connection

1. Go to Azure DevOps > Project Settings > Service connections
2. Verify your GitHub service connection exists
3. Note the connection name and update it in the YAML file

### Step 3: Create the Wiki Repository (if needed)

If you don't have a wiki repository yet:

1. Go to Azure DevOps > Overview > Wiki
2. Click "Create" or "Publish code as wiki"
3. Select "Publish code as wiki" and choose your repository
4. Or create a new wiki (this will create a `ProjectName.wiki` repository)

### Step 4: Create the Pipeline

1. Go to Azure DevOps > Pipelines > Create Pipeline
2. Select "Azure Repos Git" or "GitHub" as your source
3. Select "Existing Azure Pipelines YAML file"
4. Choose `azure-pipelines-wiki-sync.yml`
5. Review and run

### Step 5: Grant Pipeline Permissions

The pipeline needs access to push to your wiki repository:

1. Go to Project Settings > Repositories > Your wiki repo
2. Go to Security tab
3. Add "[Your Project] Build Service" with Contribute permissions

### Step 6: Test

1. Make a change to the `wiki` folder in your GitHub repository
2. Commit and push to the `main` branch
3. Watch the pipeline run in Azure DevOps
4. Verify the changes appear in your Azure DevOps Wiki

---

## Troubleshooting

**Error: "Permission denied"**
- Ensure the Build Service has Contribute permissions on the wiki repository
- Check Project Settings > Repositories > [Wiki Repo] > Security

**Error: "Repository not found"**
- Verify the `wikiRepoName` variable matches your actual wiki repository name
- Check if the wiki exists in Azure DevOps

**Pipeline doesn't trigger**
- Verify the GitHub service connection is working
- Check that the trigger paths match your repository structure

---

## Customization Options

### Change Trigger Paths

To monitor different folders or files, update the `paths` filter in `azure-pipelines-wiki-sync.yml`:

```yaml
trigger:
  paths:
    include:
      - wiki/*
      - docs/*  # Add additional paths
```

### Change Commit Author

Update the git config commands in the pipeline variables section:

```yaml
variables:
  commitUserName: 'Your Bot Name'
  commitUserEmail: 'your-bot@yourdomain.com'
```

### Add Notifications

You can add notification tasks to alert on success/failure. See Azure DevOps Pipeline documentation for details on adding email notifications or Teams/Slack integrations.

---

## Support

If you encounter issues not covered here:

1. Check the pipeline logs in Azure DevOps for detailed error messages
2. Verify all credentials and permissions (GitHub service connection, Build Service permissions)
3. Ensure the wiki repository exists and is accessible in Azure DevOps
4. Check that the `wiki` folder exists in your GitHub repository
5. Verify the GitHub service connection has the necessary permissions to read your repository
