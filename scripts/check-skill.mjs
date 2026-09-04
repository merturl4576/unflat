#!/usr/bin/env node
// Validates an Agent Skill folder: frontmatter shape, size limits, reference links.
import { readFileSync, existsSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export function validateSkill(dir) {
  const problems = [];
  const file = join(dir, 'SKILL.md');
  if (!existsSync(file)) return ['SKILL.md not found'];
  const text = readFileSync(file, 'utf8').replace(/\r\n/g, '\n');
  const m = text.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!m) return ['frontmatter block (--- ... ---) not found at top of SKILL.md'];
  const [, front, body] = m;
  if (front.length > 1024) problems.push(`frontmatter is ${front.length} chars, limit is 1024`);
  const name = (front.match(/^name:\s*(.+)$/m) || [])[1]?.trim();
  const desc = (front.match(/^description:\s*(.+)$/m) || [])[1]?.trim();
  if (!name) problems.push('frontmatter: name is missing');
  else if (!/^[a-z0-9-]+$/.test(name)) problems.push(`frontmatter: name "${name}" must be lowercase letters, digits and hyphens`);
  if (!desc) problems.push('frontmatter: description is missing');
  else if (!desc.startsWith('Use when')) problems.push('frontmatter: description must start with "Use when"');
  const lines = body.split('\n').length;
  if (lines > 250) problems.push(`body is ${lines} lines, keep it under 250`);
  for (const ref of new Set(body.match(/references\/[A-Za-z0-9_.-]+/g) || [])) {
    if (!existsSync(join(dir, ref))) problems.push(`missing file ${ref}`);
  }
  return problems;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const dir = resolve(process.argv[2] ?? 'skills/unflat');
  const p = validateSkill(dir);
  if (p.length) { console.log(p.map(x => 'FAIL  ' + x).join('\n')); process.exit(1); }
  console.log('PASS  ' + dir);
}
