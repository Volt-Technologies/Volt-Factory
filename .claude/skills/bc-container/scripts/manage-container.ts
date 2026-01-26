#!/usr/bin/env npx ts-node
/**
 * BC Container Management Script
 *
 * Manages Business Central Docker containers using @volt-technologies/bc-tools.
 *
 * Usage:
 *   npx ts-node scripts/manage-container.ts <action> [options]
 *
 * Actions:
 *   create    Create a new container
 *   remove    Remove a container
 *   list      List all containers
 *   start     Start a stopped container
 *   stop      Stop a running container
 *
 * Options:
 *   --name <name>       Container name
 *   --version <ver>     BC version
 *   --country <code>    Country code
 *   --memory <limit>    Memory limit
 *   --json              Output as JSON
 */

import { ContainerManager, EnvLoader } from '@volt-technologies/bc-tools';

interface ContainerOptions {
  action: string;
  name?: string;
  version?: string;
  country?: string;
  memory?: string;
  username?: string;
  password?: string;
  json?: boolean;
}

function parseArgs(): ContainerOptions {
  const args = process.argv.slice(2);
  const options: ContainerOptions = {
    action: args[0] ?? 'list',
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
      case '--username':
        options.username = args[++i];
        break;
      case '--password':
        options.password = args[++i];
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
  const manager = new ContainerManager();

  try {
    switch (options.action) {
      case 'create': {
        if (!options.name) {
          console.error('Error: --name is required for create');
          process.exit(1);
        }

        const envLoader = new EnvLoader();
        const config = envLoader.load();

        const result = await manager.create({
          containerName: options.name,
          bcVersion: options.version,
          country: options.country ?? 'us',
          memoryLimit: options.memory ?? '8G',
          username: options.username ?? config.localUsername ?? 'admin',
          password: options.password ?? config.localPassword,
          includeTestToolkit: true,
        });

        if (options.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          if (result.success) {
            console.log(`\n✓ Container created: ${options.name}`);
            console.log(`  Web Client: ${result.container?.webClientUrl}`);
            console.log(`  IP Address: ${result.container?.ipAddress}\n`);
          } else {
            console.error(`\n✗ Failed: ${result.error}\n`);
            process.exit(1);
          }
        }
        break;
      }

      case 'remove': {
        if (!options.name) {
          console.error('Error: --name is required for remove');
          process.exit(1);
        }

        const result = await manager.remove(options.name, true);

        if (options.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          if (result.success) {
            console.log(`✓ Container removed: ${options.name}`);
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

      case 'start': {
        if (!options.name) {
          console.error('Error: --name is required for start');
          process.exit(1);
        }

        const result = await manager.start(options.name);

        if (options.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          if (result.success) {
            console.log(`✓ Container started: ${options.name}`);
          } else {
            console.error(`✗ Failed: ${result.error?.message}`);
            process.exit(1);
          }
        }
        break;
      }

      case 'stop': {
        if (!options.name) {
          console.error('Error: --name is required for stop');
          process.exit(1);
        }

        const result = await manager.stop(options.name);

        if (options.json) {
          console.log(JSON.stringify(result, null, 2));
        } else {
          if (result.success) {
            console.log(`✓ Container stopped: ${options.name}`);
          } else {
            console.error(`✗ Failed: ${result.error?.message}`);
            process.exit(1);
          }
        }
        break;
      }

      default:
        console.error(`Unknown action: ${options.action}`);
        console.error('Valid actions: create, remove, list, start, stop');
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
