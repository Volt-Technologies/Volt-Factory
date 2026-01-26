#!/usr/bin/env npx ts-node
/**
 * BC Docker Container Management
 *
 * Uses @volt-technologies/volt-bc-tools ContainerManager.
 *
 * Usage:
 *   npx ts-node scripts/container.ts <action> [options]
 *
 * Actions:
 *   create    Create a new container
 *   remove    Remove a container
 *   start     Start a stopped container
 *   stop      Stop a running container
 *   restart   Restart container services
 *   list      List all containers
 *   info      Get container info
 *   apps      List installed apps
 *
 * Options:
 *   --name <name>       Container name
 *   --version <ver>     BC version
 *   --country <code>    Country code (default: us)
 *   --memory <limit>    Memory limit (default: 8G)
 *   --json              Output as JSON
 */

import { ContainerManager, EnvLoader } from '@volt-technologies/volt-bc-tools';

interface ContainerOptions {
  action: string;
  name?: string;
  version?: string;
  country?: string;
  memory?: string;
  json: boolean;
}

function parseArgs(): ContainerOptions {
  const args = process.argv.slice(2);
  const options: ContainerOptions = {
    action: args[0] ?? 'list',
    json: false,
  };

  for (let i = 1; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case '--name':
        options.name = args[++i];
        break;
      case '--version':
        options.version = args[++i];
        break;
      case '--country':
        options.country = args[++i];
        break;
      case '--memory':
        options.memory = args[++i];
        break;
      case '--json':
        options.json = true;
        break;
    }
  }

  return options;
}

async function main() {
  const options = parseArgs();
  const envLoader = new EnvLoader();
  const config = envLoader.load();
  const manager = new ContainerManager();

  try {
    switch (options.action) {
      case 'create': {
        const name = options.name;
        if (!name) {
          console.error('Error: --name is required for create');
          process.exit(1);
        }

        const result = await manager.create({
          containerName: name,
          bcVersion: options.version,
          country: options.country ?? 'us',
          memoryLimit: options.memory ?? '8G',
          username: config.localUsername ?? 'admin',
          password: config.localPassword,
          includeTestToolkit: true,
        });

        if (options.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          if (result.success) {
            console.log(`\n✓ Container created: ${name}`);
            console.log(`  Web Client: ${result.container?.webClientUrl}`);
            console.log(`  IP Address: ${result.container?.ipAddress}`);
            console.log(`  Duration: ${result.duration}ms\n`);
          } else {
            console.log(`\n✗ Failed: ${result.error}\n`);
            process.exit(1);
          }
        }
        break;
      }

      case 'remove': {
        const name = options.name ?? config.containerName;
        if (!name) {
          console.error('Error: --name is required for remove');
          process.exit(1);
        }

        const result = await manager.remove(name, true);

        if (options.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          if (result.success) {
            console.log(`✓ Container removed: ${name}`);
          } else {
            console.error(`✗ Failed: ${result.error?.message}`);
            process.exit(1);
          }
        }
        break;
      }

      case 'start': {
        const name = options.name ?? config.containerName;
        if (!name) {
          console.error('Error: --name is required for start');
          process.exit(1);
        }

        const result = await manager.start(name);

        if (options.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          if (result.success) {
            console.log(`✓ Container started: ${name}`);
          } else {
            console.error(`✗ Failed: ${result.error?.message}`);
            process.exit(1);
          }
        }
        break;
      }

      case 'stop': {
        const name = options.name ?? config.containerName;
        if (!name) {
          console.error('Error: --name is required for stop');
          process.exit(1);
        }

        const result = await manager.stop(name);

        if (options.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          if (result.success) {
            console.log(`✓ Container stopped: ${name}`);
          } else {
            console.error(`✗ Failed: ${result.error?.message}`);
            process.exit(1);
          }
        }
        break;
      }

      case 'restart': {
        const name = options.name ?? config.containerName;
        if (!name) {
          console.error('Error: --name is required for restart');
          process.exit(1);
        }

        const result = await manager.restart(name);

        if (options.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          if (result.success) {
            console.log(`✓ Container restarted: ${name}`);
          } else {
            console.error(`✗ Failed: ${result.error?.message}`);
            process.exit(1);
          }
        }
        break;
      }

      case 'list': {
        const containers = await manager.listContainers();

        if (options.json) {
          console.log(JSON.stringify(containers, null, 2));
        } else {
          if (containers.length === 0) {
            console.log('\nNo BC containers found\n');
          } else {
            console.log('\nBC Containers:\n');
            for (const c of containers) {
              const status = c.status === 'running' ? '✓ running' : '○ ' + c.status;
              console.log(`  ${c.name} - ${status}`);
            }
            console.log();
          }
        }
        break;
      }

      case 'info': {
        const name = options.name ?? config.containerName;
        if (!name) {
          console.error('Error: --name is required for info');
          process.exit(1);
        }

        const info = await manager.getInfo(name);

        if (options.json) {
          console.log(JSON.stringify(info, null, 2));
        } else {
          if (info) {
            console.log(`\nContainer: ${info.name}`);
            console.log(`  Status: ${info.status}`);
            console.log(`  IP Address: ${info.ipAddress ?? 'N/A'}`);
            console.log(`  Web Client: ${info.webClientUrl ?? 'N/A'}`);
            console.log(`  Dev Endpoint: ${info.devEndpointUrl ?? 'N/A'}\n`);
          } else {
            console.log(`\nContainer not found: ${name}\n`);
            process.exit(1);
          }
        }
        break;
      }

      case 'apps': {
        const name = options.name ?? config.containerName;
        if (!name) {
          console.error('Error: --name is required for apps');
          process.exit(1);
        }

        const apps = await manager.getInstalledApps(name);

        if (options.json) {
          console.log(JSON.stringify(apps, null, 2));
        } else {
          if (apps.length === 0) {
            console.log('\nNo apps installed\n');
          } else {
            console.log('\nInstalled Apps:\n');
            for (const app of apps) {
              const status = app.isInstalled ? '✓' : '○';
              console.log(`  ${status} ${app.publisher}_${app.name} v${app.version}`);
            }
            console.log();
          }
        }
        break;
      }

      default:
        console.error(`Unknown action: ${options.action}`);
        console.error('Valid actions: create, remove, start, stop, restart, list, info, apps');
        process.exit(1);
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    if (options.json) {
      console.log(JSON.stringify({ success: false, error: message }));
    } else {
      console.error(`Error: ${message}`);
    }
    process.exit(1);
  }
}

main();
