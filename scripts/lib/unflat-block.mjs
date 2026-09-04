export const START = '/* unflat: start */';
export const END = '/* unflat: end */';

const normalize = (s) => s.replace(/\r\n/g, '\n');

/** Remove the unflat block (START..END plus exactly one trailing newline). */
export function stripUnflatBlock(html) {
  const src = normalize(html);
  const s = src.indexOf(START);
  const e = src.indexOf(END);
  if (s < 0 || e < 0) return { stripped: null, reason: 'missing-markers' };
  if (src.indexOf(START, s + START.length) >= 0 || src.indexOf(END, e + END.length) >= 0) {
    return { stripped: null, reason: 'duplicate-markers' };
  }
  if (e < s) return { stripped: null, reason: 'markers-out-of-order' };
  let end = e + END.length;
  if (src[end] === '\n') end += 1;
  return { stripped: src.slice(0, s) + src.slice(end) };
}

/** True when `after` is exactly `before` with one unflat block inserted. */
export function checkPair(before, after) {
  const { stripped, reason } = stripUnflatBlock(after);
  if (!stripped) return { ok: false, reason };
  const a = normalize(before);
  if (stripped === a) return { ok: true };
  const al = a.split('\n');
  const bl = stripped.split('\n');
  const n = Math.max(al.length, bl.length);
  for (let i = 0; i < n; i++) {
    if (al[i] !== bl[i]) return { ok: false, reason: 'remainder-differs', line: i + 1 };
  }
  return { ok: false, reason: 'remainder-differs', line: n };
}
