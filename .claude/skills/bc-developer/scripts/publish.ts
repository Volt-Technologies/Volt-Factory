#!/usr/bin/env npx ts-node
/**
 * Publish BC AL Applications
 *
 * Uses @volt-technologies/volt-bc-tools AppPublisher.
 *
 * Usage:
 *   npx ts-node scripts/publish.ts <app-file> [options]
 *
 * Options:
 *   --sync-mode <mode>  Add, Clean, Development, ForceSync (default: ForceSync)
 *   --environment <env> online or local (default: from .env)
 *   --json              Output as JSON
 */

import { AppPublisher, EnvLoader } from '@volt-technologies/volt-bc-tools';

interface PublishOptions {
  appFile: string;
  syncMode: 'Add' | 'Clean' | 'Development' | 'ForceSync';
  environment?: 'online' | 'local';
  json: boolean;
}

function parseArgs(): PublishOptions {
  const args = process.argv.slice(2);
  const options: PublishOptions = {
    appFile: '',
    syncMode: 'ForceSync',
    json: false,
  };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg.startsWith('--')) {
      switch (arg) {
        case '--sync-mode':
          options.syncMode = args[++i] as PublishOptions['syncMode'];
          break;
        case '--environment':
          options.environment = args[++i] as 'online' | 'local';
          break;
        case '--json':
          options.json = true;
          break;
      }
    } else if (!options.appFile) {
      options.appFile = arg;
    }
  }

  return options;
}

async function main() {
  const options = parseArgs();

  if (!options.appFile) {
    console.error('Error: App file path required');
    console.error('Usage: npx ts-node publish.ts <app-file> [--sync-mode ForceSync] [--json]');
    process.exit(1);
  }

  const envLoader = new EnvLoader();
  const config = envLoader.load();

  const environment = options.environment ?? config.deploymentType ?? 'online';

  console.log('[DEBUG] process.env.BC_ENVIRONMENT_NAME:', process.env.BC_ENVIRONMENT_NAME);
  console.log('[DEBUG] config.environmentName:', config.environmentName);

  const publisher = new AppPublisher({
    environment,
    containerName: config.containerName,
    tenantId: config.tenantId,
    clientId: config.clientId,
    clientSecret: config.clientSecret,
    environmentName: config.environmentName,
    syncMode: options.syncMode,
    skipVerification: true,
  });

  try {
    const result = await publisher.publish(options.appFile);

    if (options.json) {
      console.log(JSON.stringify(result, null, 2));
    } else {
      if (result.success) {
        console.log(`\n✓ Published: ${result.appName} v${result.appVersion}`);
        console.log(`  Publisher: ${result.appPublisher}`);
        console.log(`  Environment: ${environment}`);
        console.log(`  Duration: ${result.duration}ms\n`);
      } else {
        console.log(`\n✗ Publish failed: ${result.error}\n`);
      }
    }

    process.exit(result.success ? 0 : 1);
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
