import { test } from 'node:test';
import assert from 'node:assert/strict';
import { stripUnflatBlock, checkPair } from './lib/unflat-block.mjs';

const before = `<!doctype html>\n<html><head><style>\nbody{background:#111}\n</style></head><body><main><section>hi</section></main></body></html>\n`;
const block = `/* unflat: start */\n:root{--unflat-ground:#0b0b0b}\nhtml{background:var(--unflat-ground)}\n/* unflat: end */`;
const insert = (src, blk) => {
  const i = src.lastIndexOf('</style>');
  return src.slice(0, i) + blk + '\n' + src.slice(i);
};

test('strip removes the block and one trailing newline', () => {
  const after = insert(before, block);
  const { stripped, reason } = stripUnflatBlock(after);
  assert.equal(reason, undefined);
  assert.equal(stripped, before);
});

test('checkPair passes for before + block', () => {
  assert.deepEqual(checkPair(before, insert(before, block)), { ok: true });
});

test('checkPair fails when markers are missing', () => {
  assert.deepEqual(checkPair(before, before), { ok: false, reason: 'missing-markers' });
});

test('checkPair fails on duplicate markers', () => {
  const after = insert(insert(before, block), block);
  assert.deepEqual(checkPair(before, after), { ok: false, reason: 'duplicate-markers' });
});

test('checkPair reports the first differing line when markup changed', () => {
  const after = insert(before, block).replace('<section>hi</section>', '<section data-unflat="plate">hi</section>');
  const r = checkPair(before, after);
  assert.equal(r.ok, false);
  assert.equal(r.reason, 'remainder-differs');
  assert.equal(r.line, 4);
});

test('checkPair ignores CRLF vs LF', () => {
  const after = insert(before, block).replace(/\n/g, '\r\n');
  assert.deepEqual(checkPair(before, after), { ok: true });
});

test('checkPair fails when block is not before last </style>', () => {
  const afterHead = before.replace('</head>', block + '\n</head>');
  assert.deepEqual(checkPair(before, afterHead), { ok: false, reason: 'block-not-before-last-style' });
});

test('checkPair fails when block has no trailing newline', () => {
  const i = before.lastIndexOf('</style>');
  const afterNoNL = before.slice(0, i) + block + before.slice(i);
  assert.deepEqual(checkPair(before, afterNoNL), { ok: false, reason: 'missing-trailing-newline' });
});
