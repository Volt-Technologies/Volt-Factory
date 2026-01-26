#!/usr/bin/env npx ts-node
/**
 * BC Test Runner Script
 *
 * Executes Business Central tests using volt-technologies/volt-bc-tools.
 *
 * Usage:
 *   npx ts-node scripts/run-tests.ts [options]
 *
 * Options:
 *   --codeunit <id>       Run specific test codeunit
 *   --range <range>       Run codeunits in range (e.g., "70200..70249")
 *   --extension <id>      Run all tests for extension
 *   --list                List available test codeunits
 *   --output <path>       Output directory for results
 *   --json                Output results as JSON
 */

import { TestRunner, EnvLoader } from 'volt-technologies/volt-bc-tools';
import type { TestExecutionResult } from 'volt-technologies/volt-bc-tools';

interface RunOptions {
  codeunit?: number;
  range?: string;
  extension?: string;
  list?: boolean;
  output?: string;
  json?: boolean;
}

function parseArgs(): RunOptions {
  const args = process.argv.slice(2);
  const options: RunOptions = {};

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case '--codeunit':
        options.codeunit = parseInt(args[++i] ?? '0', 10);
        break;
      case '--range':
        options.range = args[++i];
        break;
      case '--extension':
        options.extension = args[++i];
        break;
      case '--list':
        options.list = true;
        break;
      case '--output':
        options.output = args[++i];
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

  try {
    const envLoader = new EnvLoader();
    const config = envLoader.load();

    const runner = new TestRunner({
      environment: config.deploymentType,
      containerName: config.containerName,
      tenantId: config.tenantId,
      clientId: config.clientId,
      clientSecret: config.clientSecret,
      environmentName: config.environmentName,
      companyName: config.companyName,
      outputPath: options.output ?? 'test-results',
    });

    if (options.list) {
      const codeunits = await runner.listTestCodeunits();

      if (options.json) {
        console.log(JSON.stringify(codeunits, null, 2));
      } else {
        console.log('\nTest Codeunits:\n');
        for (const c of codeunits) {
          console.log(`  ${c.id.toString().padStart(6)} - ${c.name}`);
        }
        console.log(`\nTotal: ${codeunits.length} codeunits\n`);
      }
      return;
    }

    const result: TestExecutionResult = await runner.run({
      testCodeunitId: options.codeunit,
      testCodeunitRange: options.range,
      extensionId: options.extension,
    });

    if (options.json) {
      console.log(JSON.stringify(result, null, 2));
    } else {
      if (result.success) {
        console.log(`\n✓ Tests passed: ${result.passedTests}/${result.totalTests}`);
        console.log(`  Duration: ${result.duration}ms\n`);
      } else {
        console.error(`\n✗ Tests failed: ${result.failedTests}/${result.totalTests}\n`);

        const failed = result.results.filter(r => !r.success);
        for (const f of failed.slice(0, 10)) {
          console.error(`  ✗ ${f.codeunitName}::${f.methodName}`);
          if (f.errorMessage) {
            console.error(`    ${f.errorMessage}\n`);
          }
        }

        if (failed.length > 10) {
          console.error(`  ... and ${failed.length - 10} more failures\n`);
        }

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
