#!/usr/bin/env npx ts-node
/**
 * BC Publisher Script
 *
 * Publishes Business Central AL applications using @volt-technologies/bc-tools.
 *
 * Usage:
 *   npx ts-node scripts/publish.ts <app-file> [options]
 *
 * Options:
 *   --sync-mode <mode>   Sync mode: Add, Clean, Development, ForceSync (default: ForceSync)
 *   --skip-verification  Skip app signature verification (default: true)
 *   --container <name>   Container name for local deployment
 *   --environment <name> Environment name override
 *   --json               Output results as JSON
 */

import * as fs from 'fs';
import * as path from 'path';
import { AppPublisher, EnvLoader } from '@volt-technologies/bc-tools';
import type { PublishResult } from '@volt-technologies/bc-tools';

interface PublishOptions {
  appFile: string;
  syncMode?: string;
  skipVerification?: boolean;
  container?: string;
  environment?: string;
  json?: boolean;
}

function parseArgs(): PublishOptions {
  const args = process.argv.slice(2);
  const options: PublishOptions = {
    appFile: '',
    skipVerification: true,
    syncMode: 'ForceSync',
  };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (!arg) continue;

    if (arg.startsWith('--')) {
      switch (arg) {
        case '--sync-mode':
          options.syncMode = args[++i];
          break;
        case '--skip-verification':
          options.skipVerification = true;
          break;
        case '--no-skip-verification':
          options.skipVerification = false;
          break;
        case '--container':
          options.container = args[++i];
          break;
        case '--environment':
          options.environment = args[++i];
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

function findAppFiles(dir: string): string[] {
  const appFiles: string[] = [];

  if (!fs.existsSync(dir)) return appFiles;

  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isFile() && entry.name.endsWith('.app')) {
      appFiles.push(fullPath);
    } else if (entry.isDirectory()) {
      appFiles.push(...findAppFiles(fullPath));
    }
  }

  return appFiles;
}

async function main() {
  const options = parseArgs();

  // Auto-discover app file if not specified
  if (!options.appFile) {
    const outputDir = process.env['BC_OUTPUT_DIR'] ?? 'output';
    const appFiles = findAppFiles(outputDir);

    if (appFiles.length === 0) {
      console.error('Error: No .app file specified and none found in output directory');
      process.exit(1);
    }

    if (appFiles.length === 1) {
      options.appFile = appFiles[0]!;
      console.log(`Found app file: ${options.appFile}`);
    } else {
      console.error('Error: Multiple .app files found. Please specify which one:');
      for (const file of appFiles) {
        console.error(`  ${file}`);
      }
      process.exit(1);
    }
  }

  if (!fs.existsSync(options.appFile)) {
    console.error(`Error: App file not found: ${options.appFile}`);
    process.exit(1);
  }

  try {
    const envLoader = new EnvLoader();
    const config = envLoader.load();

    const publisher = new AppPublisher({
      environment: config.deploymentType,
      containerName: options.container ?? config.containerName,
      tenantId: config.tenantId,
      clientId: config.clientId,
      clientSecret: config.clientSecret,
      environmentName: options.environment ?? config.environmentName,
      syncMode: options.syncMode as 'Add' | 'Clean' | 'Development' | 'ForceSync',
      skipVerification: options.skipVerification,
    });

    const result: PublishResult = await publisher.publish(options.appFile);

    if (options.json) {
      console.log(JSON.stringify(result, null, 2));
    } else {
      if (result.success) {
        console.log(`✓ Published ${result.appName} v${result.appVersion}`);
        console.log(`  Publisher: ${result.appPublisher}`);
        console.log(`  Duration: ${result.duration}ms`);
        console.log(`  Environment: ${options.environment ?? config.environmentName}`);
      } else {
        console.error(`✗ Publish failed: ${result.error}`);
        process.exit(1);
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
