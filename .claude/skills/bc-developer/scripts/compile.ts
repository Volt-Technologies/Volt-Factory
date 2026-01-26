#!/usr/bin/env npx ts-node
/**
 * Compile BC AL Applications
 *
 * Uses @volt-technologies/volt-bc-tools ALCompiler with embedded alc.exe.
 *
 * Usage:
 *   npx ts-node scripts/compile.ts [options]
 *
 * Options:
 *   --all              Compile all apps in BC_APPS_ROOT
 *   --app-path <path>  Compile specific app
 *   --output <dir>     Output directory (default: output)
 *   --json             Output as JSON
 */

import { ALCompiler, EnvLoader } from '@volt-technologies/volt-bc-tools';
import * as path from 'path';

interface CompileOptions {
  all: boolean;
  appPath?: string;
  output: string;
  json: boolean;
}

function parseArgs(): CompileOptions {
  const args = process.argv.slice(2);
  const options: CompileOptions = {
    all: false,
    output: 'output',
    json: false,
  };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case '--all':
        options.all = true;
        break;
      case '--app-path':
        options.appPath = args[++i];
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

  // Resolve compiler path relative to this script
  const compilerPath = path.resolve(__dirname, 'compiler/extension/bin/win32/alc.exe');

  const compiler = new ALCompiler({
    compilerPath,
    packageCachePath: '.alpackages',
    outputDir: options.output,
    enableCodeCop: true,
    enableUICop: true,
  });

  try {
    if (options.all) {
      const appsRoot = config.appsRoot ?? 'BC';
      const result = await compiler.compileAll(appsRoot);

      if (options.json) {
        console.log(JSON.stringify(result, null, 2));
      } else {
        console.log(`\nCompilation ${result.success ? 'Successful' : 'Failed'}`);
        console.log(`  Apps: ${result.successfulApps}/${result.totalApps} succeeded`);
        console.log(`  Duration: ${result.totalDuration}ms\n`);

        for (const r of result.results) {
          const status = r.success ? '✓' : '✗';
          console.log(`  ${status} ${r.appName ?? 'Unknown'} v${r.appVersion ?? '?'}`);

          if (!r.success && r.diagnostics) {
            for (const d of r.diagnostics.filter((x) => x.severity === 'error')) {
              const loc = d.file ? `${d.file}:${d.line}` : '';
              console.log(`    [${d.code}] ${d.message} ${loc}`);
            }
          }
        }
      }

      process.exit(result.success ? 0 : 1);
    } else if (options.appPath) {
      const result = await compiler.compile({ appPath: options.appPath });

      if (options.json) {
        console.log(JSON.stringify(result, null, 2));
      } else {
        if (result.success) {
          console.log(`\n✓ Compiled: ${result.appFile}\n`);
        } else {
          console.log(`\n✗ Compilation failed with ${result.errorCount} errors\n`);
          for (const d of result.diagnostics?.filter((x) => x.severity === 'error') ?? []) {
            const loc = d.file ? `${d.file}:${d.line}` : '';
            console.log(`  [${d.code}] ${d.message} ${loc}`);
          }
        }
      }

      process.exit(result.success ? 0 : 1);
    } else {
      console.error('Error: Specify --all or --app-path');
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
