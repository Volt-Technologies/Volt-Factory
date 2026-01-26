#!/usr/bin/env npx ts-node
/**
 * BC Compiler Script
 *
 * Compiles Business Central AL applications using @volt-technologies/bc-tools.
 *
 * Usage:
 *   npx ts-node scripts/compile.ts [options]
 *
 * Options:
 *   --app-path <path>    Compile specific app
 *   --all                Compile all apps in BC_APPS_ROOT
 *   --output <path>      Output directory (default: output)
 *   --json               Output results as JSON
 */

import { ALCompiler, EnvLoader } from '@volt-technologies/bc-tools';
import type { CompilationResult, MultiAppCompilationResult } from '@volt-technologies/bc-tools';

interface CompileOptions {
  appPath?: string;
  all?: boolean;
  output?: string;
  json?: boolean;
}

function parseArgs(): CompileOptions {
  const args = process.argv.slice(2);
  const options: CompileOptions = {};

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case '--app-path':
        options.appPath = args[++i];
        break;
      case '--all':
        options.all = true;
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

function formatDiagnostics(result: CompilationResult): string[] {
  return result.diagnostics
    .filter(d => d.severity === 'error')
    .map(d => `${d.file ?? 'unknown'}:${d.line ?? 0}: [${d.code}] ${d.message}`);
}

async function main() {
  const options = parseArgs();

  try {
    const envLoader = new EnvLoader();
    const config = envLoader.load();

    const compiler = new ALCompiler({
      packageCachePath: config.packageCachePath ?? '.alpackages',
      outputDir: options.output ?? config.outputDir ?? 'output',
    });

    if (options.all) {
      const appsRoot = config.appsRoot ?? 'BC';
      const result = await compiler.compileAll(appsRoot) as MultiAppCompilationResult;

      if (options.json) {
        console.log(JSON.stringify(result, null, 2));
      } else {
        if (result.success) {
          console.log(`✓ Compiled ${result.successfulApps}/${result.totalApps} apps successfully`);
          for (const r of result.results) {
            if (r.success && r.appFile) {
              console.log(`  • ${r.appName} v${r.appVersion} → ${r.appFile}`);
            }
          }
        } else {
          console.error(`✗ Compilation failed: ${result.failedApps}/${result.totalApps} apps failed`);
          for (const r of result.results) {
            if (!r.success) {
              console.error(`\n  App: ${r.appName ?? 'unknown'}`);
              for (const diag of formatDiagnostics(r)) {
                console.error(`    ${diag}`);
              }
            }
          }
          process.exit(1);
        }
      }
    } else if (options.appPath) {
      const result = await compiler.compile({ appPath: options.appPath }) as CompilationResult;

      if (options.json) {
        console.log(JSON.stringify(result, null, 2));
      } else {
        if (result.success) {
          console.log(`✓ Compiled ${result.appName} v${result.appVersion}`);
          console.log(`  Output: ${result.appFile}`);
          console.log(`  Duration: ${result.duration}ms`);
          if (result.warningCount > 0) {
            console.log(`  Warnings: ${result.warningCount}`);
          }
        } else {
          console.error(`✗ Compilation failed with ${result.errorCount} errors`);
          for (const diag of formatDiagnostics(result)) {
            console.error(`  ${diag}`);
          }
          process.exit(1);
        }
      }
    } else {
      console.error('Error: Specify --app-path <path> or --all');
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
