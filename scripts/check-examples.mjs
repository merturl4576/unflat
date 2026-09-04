#!/usr/bin/env node
// Proves the zero-markup claim: every examples/*/after.html must equal
// before.html plus one unflat block. Exit 1 on any failure.
import { readdirSync, readFileSync, existsSync, statSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { checkPair } from './lib/unflat-block.mjs';

const dir = resolve(process.argv[2] ?? 'examples');
const allowMissing = process.argv.includes('--allow-missing');
let failed = 0, checked = 0;

for (const name of readdirSync(dir).sort()) {
  const d = join(dir, name);
  if (!statSync(d).isDirectory() || name.startsWith('_')) continue;
  const before = join(d, 'before.html');
  const after = join(d, 'after.html');
  if (!existsSync(before)) continue;
  if (!existsSync(after)) {
    console.log(`${allowMissing ? 'SKIP' : 'FAIL'}  ${name}  (no after.html)`);
    if (!allowMissing) failed++;
    continue;
  }
  const r = checkPair(readFileSync(before, 'utf8'), readFileSync(after, 'utf8'));
  checked++;
  if (r.ok) console.log(`PASS  ${name}`);
  else { failed++; console.log(`FAIL  ${name}  ${r.reason}${r.line ? ' at line ' + r.line : ''}`); }
}
console.log(`\n${checked} checked, ${failed} failed`);
process.exit(failed ? 1 : 0);
