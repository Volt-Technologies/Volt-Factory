#!/usr/bin/env npx ts-node
/**
 * Verify BC App Installation
 *
 * Uses @volt-technologies/volt-bc-tools AppPublisher.
 *
 * Usage:
 *   npx ts-node scripts/verify.ts [options]
 *
 * Options:
 *   --app-name <name>   Name of app to verify
 *   --environment <env> online or local (default: from .env)
 *   --json              Output as JSON
 */

import { AppPublisher, EnvLoader } from '@volt-technologies/volt-bc-tools';

interface VerifyOptions {
  appName?: string;
  environment?: 'online' | 'local';
  json: boolean;
}

function parseArgs(): VerifyOptions {
  const args = process.argv.slice(2);
  const options: VerifyOptions = {
    json: false,
  };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case '--app-name':
        options.appName = args[++i];
        break;
      case '--environment':
        options.environment = args[++i] as 'online' | 'local';
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

  const environment = options.environment ?? config.deploymentType ?? 'local';

  const publisher = new AppPublisher({
    environment,
    containerName: config.containerName,
    tenantId: config.tenantId,
    clientId: config.clientId,
    clientSecret: config.clientSecret,
    environmentName: config.environmentName,
  });

  try {
    if (options.appName) {
      const result = await publisher.verifyInstallation(options.appName);

      if (options.json) {
        console.log(JSON.stringify(result, null, 2));
      } else {
        if (result.verified) {
          console.log(`\n✓ ${result.message}`);
          if (result.details?.app) {
            const app = result.details.app;
            console.log(`  Version: ${app.version}`);
            console.log(`  Publisher: ${app.publisher}`);
            console.log(`  Scope: ${app.scope}\n`);
          }
        } else {
          console.log(`\n✗ ${result.message}\n`);
          process.exit(1);
        }
      }
    } else {
      // List all apps
      const apps = await publisher.getInstalledApps();

      if (options.json) {
        console.log(JSON.stringify(apps, null, 2));
      } else {
        if (apps.length === 0) {
          console.log('\nNo apps installed\n');
        } else {
          console.log('\nInstalled Apps:\n');
          for (const app of apps) {
            const pubStatus = app.isPublished ? 'published' : 'not published';
            const instStatus = app.isInstalled ? 'installed' : 'not installed';
            console.log(`  ${app.publisher}_${app.name} v${app.version}`);
            console.log(`    Status: ${pubStatus}, ${instStatus}`);
          }
          console.log();
        }
      }
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
