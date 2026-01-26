# BC Container Troubleshooting

## Platform Errors

### Non-Windows System
```
Error: BC Docker requires Windows
```
**Solution**: BC Docker containers only run on Windows. Use BC Online sandbox instead.

## Docker Errors

### Docker Not Running
```
Error: Cannot connect to Docker daemon
```
**Solution**:
1. Open Docker Desktop
2. Wait for it to start completely
3. Verify with `docker ps`

### Docker Not Installed
```
Error: docker command not found
```
**Solution**: Install Docker Desktop from https://docker.com

### Insufficient Memory
```
Error: Not enough memory to start container
```
**Solution**:
1. Open Docker Desktop Settings
2. Go to Resources → Advanced
3. Increase memory to at least 8GB
4. Apply & Restart

### Disk Space Full
```
Error: No space left on device
```
**Solution**:
```bash
docker system prune -a  # Remove unused images/containers
```

## BCContainerHelper Errors

### Module Not Found
```
Error: BCContainerHelper module not found
```
**Solution**:
```powershell
Install-Module BCContainerHelper -Force
```

### Module Outdated
**Solution**:
```powershell
Update-Module BCContainerHelper
```

## Container Creation Errors

### Port Already in Use
```
Error: Port 80 is already in use
```
**Solution**:
1. Stop conflicting container: `docker stop <container>`
2. Or use different ports in creation script

### Artifact Download Failed
```
Error: Failed to download BC artifact
```
**Cause**: Network issue or invalid artifact URL.

**Solution**:
1. Check internet connection
2. Verify BC version exists
3. Check proxy settings

### Authentication Failed
```
Error: License file not valid
```
**Solution**:
1. Verify license file path
2. Check license is not expired
3. Ensure license matches BC version

## Container Runtime Errors

### Container Won't Start
```
Error: Container exited immediately
```
**Solution**:
```bash
docker logs bc-container  # Check logs
```

### Cannot Connect to Web Client
```
Error: Connection refused
```
**Solution**:
1. Verify container is running: `docker ps`
2. Check port mapping: `docker port bc-container`
3. Try http://localhost:80/BC

### Service Unavailable
```
Error: 503 Service Unavailable
```
**Cause**: BC server starting up inside container.

**Solution**: Wait 2-3 minutes for services to start.

## Common Solutions

### Restart Container
```bash
docker restart bc-container
```

### View Logs
```bash
docker logs bc-container --tail 100
```

### Enter Container Shell
```bash
docker exec -it bc-container powershell
```

### Check Container Status
```bash
docker inspect bc-container --format '{{.State.Status}}'
```

## Best Practices

1. **Name containers clearly**: Use `bc-{feature}` format
2. **One container per feature**: Avoid conflicts
3. **Update .env after creation**: Keep `CURRENT_FEATURE_CONTAINER` current
4. **Clean up unused containers**: Save disk space
5. **Check before creating**: Reuse existing containers
