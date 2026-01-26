#!/usr/bin/env npx ts-node
/**
 * Run BC AL Tests
 *
 * Uses @volt-technologies/volt-bc-tools TestRunner.
 *
 * Usage:
 *   npx ts-node scripts/run-tests.ts [options]
 *
 * Options:
 *   --codeunit <id>      Run specific test codeunit
 *   --range <start..end> Run codeunits in range (e.g., "70200..70249")
 *   --extension <id>     Run all tests for extension
 *   --suite <name>       Run test suite
 *   --environment <env>  online or local (default: from .env)
 *   --output <dir>       Output directory (default: test-results)
 *   --json               Output as JSON
 */

import { TestRunner, EnvLoader } from '@volt-technologies/volt-bc-tools';

interface TestOptions {
  codeunitId?: number;
  range?: string;
  extensionId?: string;
  suiteName?: string;
  environment?: 'online' | 'local';
  output: string;
  json: boolean;
}

function parseArgs(): TestOptions {
  const args = process.argv.slice(2);
  const options: TestOptions = {
    output: 'test-results',
    json: false,
  };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case '--codeunit':
        options.codeunitId = parseInt(args[++i], 10);
        break;
      case '--range':
        options.range = args[++i];
        break;
      case '--extension':
        options.extensionId = args[++i];
        break;
      case '--suite':
        options.suiteName = args[++i];
        break;
      case '--environment':
        options.environment = args[++i] as 'online' | 'local';
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
  const envLoader = new EnvLoader();
  const config = envLoader.load();

  const environment = options.environment ?? config.deploymentType ?? 'online';

  const runner = new TestRunner({
    environment,
    containerName: config.containerName,
    tenantId: config.tenantId,
    clientId: config.clientId,
    clientSecret: config.clientSecret,
    environmentName: config.environmentName,
    companyName: config.companyName,
    outputPath: options.output,
  });

  try {
    let result;

    if (options.codeunitId) {
      result = await runner.runCodeunit(options.codeunitId);
    } else if (options.range) {
      result = await runner.runCodeunitRange(options.range);
    } else if (options.extensionId) {
      result = await runner.run({ extensionId: options.extensionId });
    } else if (options.suiteName) {
      result = await runner.run({ testSuiteName: options.suiteName });
    } else {
      console.error('Error: Specify --codeunit, --range, --extension, or --suite');
      process.exit(1);
    }

    if (options.json) {
      console.log(JSON.stringify(result, null, 2));
    } else {
      console.log(`\nTest Run ${result.success ? 'Passed' : 'Failed'}`);
      console.log(`  Total: ${result.totalTests}`);
      console.log(`  Passed: ${result.passedTests}`);
      console.log(`  Failed: ${result.failedTests}`);
      console.log(`  Skipped: ${result.skippedTests}`);
      console.log(`  Duration: ${result.duration}ms\n`);

      if (result.failedTests > 0) {
        console.log('Failed Tests:');
        for (const test of result.results.filter((t) => !t.success)) {
          console.log(`  ✗ ${test.codeunitName}::${test.methodName}`);
          if (test.errorMessage) {
            console.log(`    ${test.errorMessage}`);
          }
        }
        console.log();
      }

      if (result.outputFile) {
        console.log(`Results saved to: ${result.outputFile}\n`);
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
