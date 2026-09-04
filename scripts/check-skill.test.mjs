import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, writeFileSync, mkdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { validateSkill } from './check-skill.mjs';

function skill(front, body, refs = []) {
  const d = mkdtempSync(join(tmpdir(), 'unflat-skill-'));
  writeFileSync(join(d, 'SKILL.md'), `---\n${front}\n---\n${body}`);
  mkdirSync(join(d, 'references'));
  for (const r of refs) writeFileSync(join(d, 'references', r), '# ref\n');
  return d;
}

test('valid skill has no problems', () => {
  const d = skill('name: unflat\ndescription: Use when a page looks flat.', '# unflat\nSee references/audit.md\n', ['audit.md']);
  assert.deepEqual(validateSkill(d), []);
});

test('name must match folder convention and description must start with Use when', () => {
  const d = skill('name: Un Flat\ndescription: Adds depth to sites.', '# x\n');
  const p = validateSkill(d);
  assert.ok(p.some(s => s.includes('name')));
  assert.ok(p.some(s => s.includes('Use when')));
});

test('referenced files must exist and body must be under 250 lines', () => {
  const d = skill('name: unflat\ndescription: Use when flat.', '# x\nRead references/missing.md\n' + 'line\n'.repeat(260));
  const p = validateSkill(d);
  assert.ok(p.some(s => s.includes('references/missing.md')));
  assert.ok(p.some(s => s.includes('250')));
});

test('frontmatter must be under 1024 characters', () => {
  const d = skill('name: unflat\ndescription: Use when ' + 'x'.repeat(1100), '# x\n');
  assert.ok(validateSkill(d).some(s => s.includes('1024')));
});
