---
description: Create or start Business Central Docker container for a feature
project: true
---

Create or start an isolated Business Central Docker container for the specified feature.

**Usage:** `/bc_create_feature_docker <feature-name>`

**Feature name provided:** {{arg1}}

## Your Task

You are creating a BC Docker container for feature: **{{arg1}}**

Follow these steps:

1. **Read Configuration**:
   - Read `.env` file and check `USE_FEATURE_CONTAINERS` setting
   - If `USE_FEATURE_CONTAINERS=false`, inform the user and exit
   - Check `CURRENT_FEATURE_CONTAINER` to see current container

2. **Check Container Existence**:
   - Run: `docker ps -a --filter "name=bc-{{arg1}}"`
   - If container exists and is stopped: Start it with `docker start bc-{{arg1}}`
   - If container exists and is running: Provide connection details and exit
   - If no container exists: Proceed with creation

3. **Create Container** (if needed):
   - Verify `.claude/scripts/create-bc-container.ps1` exists
   - If not, inform user to run the bc-docker-container-creator agent first
   - Execute: `pwsh -ExecutionPolicy Bypass -File ".claude\scripts\create-bc-container.ps1" -ContainerName "bc-{{arg1}}"`
   - Monitor the creation process

4. **Update Environment**:
   - After successful creation, update `CURRENT_FEATURE_CONTAINER` in `.env` to `bc-{{arg1}}`
   - Use the Edit tool to update the value

5. **Provide Connection Details**:
   ```
   ✓ BC Container Ready: bc-{{arg1}}

   Web Client URL: http://bc-{{arg1}}:80/BC
   Username: admin
   Password: P@ssw0rd

   Container is now set as CURRENT_FEATURE_CONTAINER in .env
   Other agents (compiler, test-runner) will use this container.
   ```

## Important Notes

- Always check if container exists before creating
- Reuse existing containers when possible (just start them)
- Update `.env` with the new container name after creation
- Never create feature-specific PowerShell scripts
- Use only the reusable `.claude/scripts/create-bc-container.ps1`

## Error Handling

- If Windows check fails: Inform that BC Docker requires Windows
- If Docker not running: Provide instructions to start Docker Desktop
- If BCContainerHelper missing: Provide installation instructions
- If script missing: Suggest running bc-docker-container-creator agent to create it
