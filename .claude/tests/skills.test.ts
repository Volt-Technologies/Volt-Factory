/**
 * BC Developer Skill Tests
 *
 * Tests the unified bc-developer skill structure and format compliance.
 */

import { describe, it, expect, beforeAll } from 'vitest';
import * as fs from 'fs';
import * as path from 'path';
import { parse as parseYaml } from 'yaml';

const SKILLS_PATH = path.resolve(__dirname, '../skills');
const SKILL_PATH = path.join(SKILLS_PATH, 'bc-developer');
const SKILL_MD_PATH = path.join(SKILL_PATH, 'SKILL.md');

function parseSkillFrontmatter(content: string): Record<string, unknown> {
  // Handle both Unix (\n) and Windows (\r\n) line endings
  const normalized = content.replace(/\r\n/g, '\n');
  const match = normalized.match(/^---\n([\s\S]*?)\n---/);
  if (!match?.[1]) throw new Error('No frontmatter found');
  return parseYaml(match[1]) as Record<string, unknown>;
}

function getSkillBody(content: string): string {
  // Handle both Unix (\n) and Windows (\r\n) line endings
  const normalized = content.replace(/\r\n/g, '\n');
  const match = normalized.match(/^---\n[\s\S]*?\n---\n([\s\S]*)$/);
  return match?.[1] ?? '';
}

describe('BC Developer Skill Discovery', () => {
  it('should have bc-developer skill directory', () => {
    expect(fs.existsSync(SKILL_PATH)).toBe(true);
  });

  it('should be the only skill (unified)', () => {
    const skills = fs.readdirSync(SKILLS_PATH).filter((f) =>
      fs.statSync(path.join(SKILLS_PATH, f)).isDirectory()
    );
    expect(skills).toEqual(['bc-developer']);
  });
});

describe('BC Developer Skill Structure', () => {
  it('should have SKILL.md file', () => {
    expect(fs.existsSync(SKILL_MD_PATH)).toBe(true);
  });

  it('should have scripts directory', () => {
    expect(fs.existsSync(path.join(SKILL_PATH, 'scripts'))).toBe(true);
  });

  it('should have references directory', () => {
    expect(fs.existsSync(path.join(SKILL_PATH, 'references'))).toBe(true);
  });

  it('should have embedded compiler', () => {
    expect(fs.existsSync(path.join(SKILL_PATH, 'scripts/compiler'))).toBe(true);
    expect(fs.existsSync(path.join(SKILL_PATH, 'scripts/compiler/extension'))).toBe(true);
  });
});

describe('TypeScript Scripts', () => {
  const expectedScripts = ['compile.ts', 'publish.ts', 'run-tests.ts', 'container.ts', 'verify.ts'];

  it.each(expectedScripts)('should have %s script', (scriptName) => {
    expect(fs.existsSync(path.join(SKILL_PATH, 'scripts', scriptName))).toBe(true);
  });

  it.each(expectedScripts)('%s should import from @volt-technologies/volt-bc-tools', (scriptName) => {
    const script = fs.readFileSync(path.join(SKILL_PATH, 'scripts', scriptName), 'utf-8');
    expect(script).toContain('@volt-technologies/volt-bc-tools');
  });

  it.each(expectedScripts)('%s should have shebang for ts-node', (scriptName) => {
    const script = fs.readFileSync(path.join(SKILL_PATH, 'scripts', scriptName), 'utf-8');
    expect(script).toContain('#!/usr/bin/env npx ts-node');
  });

  it.each(expectedScripts)('%s should support --json flag', (scriptName) => {
    const script = fs.readFileSync(path.join(SKILL_PATH, 'scripts', scriptName), 'utf-8');
    expect(script).toContain('--json');
  });

  it.each(expectedScripts)('%s should handle errors with exit code 1', (scriptName) => {
    const script = fs.readFileSync(path.join(SKILL_PATH, 'scripts', scriptName), 'utf-8');
    expect(script).toContain('process.exit(1)');
  });

  it('should have README.md for scripts', () => {
    expect(fs.existsSync(path.join(SKILL_PATH, 'scripts/README.md'))).toBe(true);
  });
});

describe('Script Imports', () => {
  it('compile.ts should import ALCompiler', () => {
    const script = fs.readFileSync(path.join(SKILL_PATH, 'scripts/compile.ts'), 'utf-8');
    expect(script).toContain('ALCompiler');
  });

  it('publish.ts should import AppPublisher', () => {
    const script = fs.readFileSync(path.join(SKILL_PATH, 'scripts/publish.ts'), 'utf-8');
    expect(script).toContain('AppPublisher');
  });

  it('run-tests.ts should import TestRunner', () => {
    const script = fs.readFileSync(path.join(SKILL_PATH, 'scripts/run-tests.ts'), 'utf-8');
    expect(script).toContain('TestRunner');
  });

  it('container.ts should import ContainerManager', () => {
    const script = fs.readFileSync(path.join(SKILL_PATH, 'scripts/container.ts'), 'utf-8');
    expect(script).toContain('ContainerManager');
  });

  it('all scripts should import EnvLoader', () => {
    const scripts = ['compile.ts', 'publish.ts', 'run-tests.ts', 'container.ts', 'verify.ts'];
    for (const scriptName of scripts) {
      const script = fs.readFileSync(path.join(SKILL_PATH, 'scripts', scriptName), 'utf-8');
      expect(script).toContain('EnvLoader');
    }
  });
});

describe('SKILL.md Frontmatter', () => {
  let frontmatter: Record<string, unknown>;

  beforeAll(() => {
    const content = fs.readFileSync(SKILL_MD_PATH, 'utf-8');
    frontmatter = parseSkillFrontmatter(content);
  });

  it('should have required "name" field', () => {
    expect(frontmatter['name']).toBeDefined();
    expect(typeof frontmatter['name']).toBe('string');
  });

  it('should have name matching directory name', () => {
    expect(frontmatter['name']).toBe('bc-developer');
  });

  it('should have name in valid format (lowercase, hyphens)', () => {
    const name = frontmatter['name'] as string;
    expect(name).toMatch(/^[a-z][a-z0-9-]*[a-z0-9]$/);
    expect(name).not.toMatch(/--/);
  });

  it('should have name <= 64 characters', () => {
    expect((frontmatter['name'] as string).length).toBeLessThanOrEqual(64);
  });

  it('should have required "description" field', () => {
    expect(frontmatter['description']).toBeDefined();
    expect(typeof frontmatter['description']).toBe('string');
  });

  it('should have description mentioning volt-bc-tools', () => {
    const desc = frontmatter['description'] as string;
    expect(desc).toContain('volt-technologies/bc-tools');
  });

  it('should have description <= 1024 characters', () => {
    expect((frontmatter['description'] as string).length).toBeLessThanOrEqual(1024);
  });

  it('should have allowed-tools field', () => {
    expect(frontmatter['allowed-tools']).toBeDefined();
    expect(typeof frontmatter['allowed-tools']).toBe('string');
  });

  it('should allow npx and node in tools', () => {
    const tools = frontmatter['allowed-tools'] as string;
    expect(tools).toContain('Bash(npx:*)');
    expect(tools).toContain('Bash(node:*)');
  });
});

describe('SKILL.md Body Content', () => {
  let body: string;

  beforeAll(() => {
    const content = fs.readFileSync(SKILL_MD_PATH, 'utf-8');
    body = getSkillBody(content);
  });

  it('should have content after frontmatter', () => {
    expect(body.trim().length).toBeGreaterThan(0);
  });

  it('should be under recommended 500 lines', () => {
    expect(body.split('\n').length).toBeLessThan(500);
  });

  it('should include code examples', () => {
    expect(body).toMatch(/```/);
  });

  it('should document compile command', () => {
    expect(body).toContain('compile.ts');
  });

  it('should document publish command', () => {
    expect(body).toContain('publish.ts');
  });

  it('should document run-tests command', () => {
    expect(body).toContain('run-tests.ts');
  });

  it('should document container command', () => {
    expect(body).toContain('container.ts');
  });

  it('should mention @volt-technologies/volt-bc-tools', () => {
    expect(body).toContain('@volt-technologies/volt-bc-tools');
  });

  it('should include configuration section', () => {
    expect(body).toContain('.env');
    expect(body).toContain('BC_TENANT_ID');
  });
});

describe('Reference Documentation', () => {
  const expectedReferences = ['AL_QUICK_REFERENCE.md', 'OBJECT_CREATION.md', 'TROUBLESHOOTING.md'];

  it.each(expectedReferences)('should have %s reference', (refName) => {
    expect(fs.existsSync(path.join(SKILL_PATH, 'references', refName))).toBe(true);
  });

  it('AL_QUICK_REFERENCE.md should include naming conventions', () => {
    const content = fs.readFileSync(
      path.join(SKILL_PATH, 'references/AL_QUICK_REFERENCE.md'),
      'utf-8'
    );
    expect(content.toLowerCase()).toContain('naming');
  });

  it('OBJECT_CREATION.md should include table and page examples', () => {
    const content = fs.readFileSync(
      path.join(SKILL_PATH, 'references/OBJECT_CREATION.md'),
      'utf-8'
    );
    expect(content.toLowerCase()).toContain('table');
    expect(content.toLowerCase()).toContain('page');
  });

  it('OBJECT_CREATION.md should mention permission set', () => {
    const content = fs.readFileSync(
      path.join(SKILL_PATH, 'references/OBJECT_CREATION.md'),
      'utf-8'
    );
    expect(content.toLowerCase()).toContain('permission');
  });

  it('TROUBLESHOOTING.md should cover compilation errors', () => {
    const content = fs.readFileSync(
      path.join(SKILL_PATH, 'references/TROUBLESHOOTING.md'),
      'utf-8'
    );
    expect(content).toContain('Compilation');
  });

  it('TROUBLESHOOTING.md should cover publishing errors', () => {
    const content = fs.readFileSync(
      path.join(SKILL_PATH, 'references/TROUBLESHOOTING.md'),
      'utf-8'
    );
    expect(content).toContain('Publishing');
  });
});

describe('Embedded Compiler', () => {
  const compilerPath = path.join(SKILL_PATH, 'scripts/compiler');

  it('should have extension folder', () => {
    expect(fs.existsSync(path.join(compilerPath, 'extension'))).toBe(true);
  });

  it('should have bin folder', () => {
    expect(fs.existsSync(path.join(compilerPath, 'extension/bin'))).toBe(true);
  });

  it('should have win32 alc.exe', () => {
    expect(fs.existsSync(path.join(compilerPath, 'extension/bin/win32/alc.exe'))).toBe(true);
  });

  it('should have Analyzers folder', () => {
    expect(fs.existsSync(path.join(compilerPath, 'extension/bin/Analyzers'))).toBe(true);
  });

  it('should have LinterCop analyzer', () => {
    expect(
      fs.existsSync(
        path.join(compilerPath, 'extension/bin/Analyzers/BusinessCentral.LinterCop.dll')
      )
    ).toBe(true);
  });
});
