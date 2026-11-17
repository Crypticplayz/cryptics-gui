// Skill Made By : Crypticplay_RBLX - Only on Youtube
// Export helper for the UI board: isolates one piece at a time (no text, transparent bg) and reports layout.
// Two modes:
//   * Generic (every template from v2.2): mark exportable pieces in the HTML with
//       data-piece="name" data-margin="10"   (and optional data-keep=".sel1,.sel2")
//     and the layout origin with data-origin on the window element. EXPORT.layout() then lists every
//     placed piece, icon and text relative to that origin, ready for the UIKit assembly script.
//   * Legacy: the original cartoony shop selectors below (used when no [data-piece] exists).
(function () {
  const css = document.createElement('style');
  css.textContent = `
    body.exporting, html:has(body.exporting) { background: transparent !important; }
    .xp-frame { position: absolute; pointer-events: none; background: transparent; z-index: 99999; }
    .exporting .artboard { background: none !important; }
    .exporting .artboard::before { display: none !important; }
    .exporting .legend { display: none !important; }
    .exporting * { visibility: hidden !important; animation: none !important; }
    .exporting .xp-on, .exporting .xp-on::before, .exporting .xp-on::after { visibility: visible !important; }
    .exporting .xp-on { color: transparent !important; -webkit-text-stroke: 0 !important; text-shadow: none !important; }
    .exporting .xp-keep, .exporting .xp-keep * { visibility: visible !important; }
    .exporting .xp-frame { visibility: visible !important; }
  `;
  document.head.appendChild(css);

  const pills = () => document.querySelectorAll('.pill');
  const LEGACY = {
    header:     { el: () => document.querySelector('.s3d.header'), m: 10 },
    body:       { el: () => document.querySelector('.s3d.body'), m: 10 },
    starter:    { el: () => document.querySelector('.s3d.starter'), m: 10, keep: ['.starter .decor', '.starter .ht'] },
    card_cyan:  { el: () => document.querySelector('.card.cyan'), m: 10 },
    card_mag:   { el: () => document.querySelector('.card.mag'), m: 10 },
    card_peach: { el: () => document.querySelector('.card.peach'), m: 10 },
    free:       { el: () => document.querySelector('.s3d.free'), m: 10 },
    tab_gold:   { el: () => document.querySelector('.rail .btn.gold'), m: 40 },
    tab_navy:   { el: () => document.querySelector('.rail .btn.navy'), m: 10 },
    tab_green:  { el: () => document.querySelector('.rail .btn.green'), m: 10 },
    close:      { el: () => document.querySelector('.btn.close'), m: 10 },
    buy_big:    { el: () => document.querySelector('.starter .buy'), m: 10 },
    btn_green:  { el: () => document.querySelector('.card.cyan .btn'), m: 10 },
    btn_gray:   { el: () => document.querySelector('.card.mag .btn'), m: 10 },
    pill_coin:  { el: () => pills()[0], m: 10 },
    pill_gem:   { el: () => pills()[1], m: 10 },
    tile:       { el: () => document.querySelector('.tile'), m: 10 },
    tag:        { el: () => document.querySelector('.tag'), m: 12 },
    badge:      { el: () => document.querySelector('.badge-n'), m: 8 },
    check:      { el: () => document.querySelector('.check'), m: 4, keep: ['.check', '.check *'] },
    hud_shop:   { el: () => document.querySelector('.hud .hudbtn'), m: 40 },
    hud_badge:  { el: () => document.querySelector('.hud .badge-n'), m: 8 },
  };

  let GENERIC = false;
  function genericPieces() {
    const out = {};
    document.querySelectorAll('[data-piece]').forEach(el => {
      const name = el.dataset.piece;
      if (out[name]) return; // first element with a name is the exported image; others reuse it
      out[name] = { el: () => document.querySelector(`[data-piece="${name}"]`), m: +(el.dataset.margin || 10),
                    keep: el.dataset.keep ? el.dataset.keep.split(',') : undefined };
    });
    return out;
  }
  let PIECES = LEGACY;
  // resolved on first use, so the script can load before the board's HTML
  function resolve() { GENERIC = !!document.querySelector('[data-piece]'); PIECES = GENERIC ? genericPieces() : LEGACY; if (window.EXPORT) window.EXPORT.PIECES = PIECES; }

  function clear() {
    document.body.classList.remove('exporting');
    document.querySelectorAll('.xp-on,.xp-keep').forEach(n => n.classList.remove('xp-on', 'xp-keep'));
  }
  function prepare(name) {
    resolve();
    clear();
    const p = PIECES[name]; const el = p.el();
    document.body.classList.add('exporting');
    el.classList.add('xp-on');
    (p.keep || []).forEach(sel => document.querySelectorAll(sel).forEach(n => n.classList.add('xp-keep')));
    const r = el.getBoundingClientRect();
    // a transparent frame around the piece (+ margin for black lip / glow); Playwright screenshots this frame
    let f = document.querySelector('.xp-frame');
    if (!f) { f = document.createElement('div'); f.className = 'xp-frame'; document.body.appendChild(f); }
    Object.assign(f.style, { left: (r.left + scrollX - p.m) + 'px', top: (r.top + scrollY - p.m) + 'px', width: (r.width + 2 * p.m) + 'px', height: (r.height + 2 * p.m) + 'px' });
    return { width: r.width + 2 * p.m, height: r.height + 2 * p.m, margin: p.m };
  }

  function rel(el, origin) {
    const r = el.getBoundingClientRect();
    return { x: +(r.left - origin.left).toFixed(1), y: +(r.top - origin.top).toFixed(1), w: +r.width.toFixed(1), h: +r.height.toFixed(1) };
  }
  function textRect(el, origin) {
    const tn = [...el.childNodes].filter(n => n.nodeType === 3 && n.textContent.trim());
    const target = tn.length ? tn[tn.length - 1] : (el.querySelector('span') || el);
    let r;
    if (target.nodeType === 3) { const rg = document.createRange(); rg.selectNodeContents(target); r = rg.getBoundingClientRect(); }
    else r = target.getBoundingClientRect();
    return { x: +(r.left - origin.left).toFixed(1), y: +(r.top - origin.top).toFixed(1), w: +r.width.toFixed(1), h: +r.height.toFixed(1) };
  }

  function genericLayout() {
    clear();
    const originEl = document.querySelector('[data-origin]') || document.querySelector('.win') || document.body;
    const o = originEl.getBoundingClientRect();
    const pieces = {};
    for (const [k, p] of Object.entries(PIECES)) pieces[k] = { ...rel(p.el(), o), margin: p.m };
    const place = [];
    document.querySelectorAll('[data-piece]').forEach((el, i) => place.push({ piece: el.dataset.piece, order: i, role: el.dataset.role || null, ...rel(el, o) }));
    const icons = [];
    originEl.querySelectorAll('img').forEach(im => {
      if (im.closest('.decor')) return;
      const src = im.getAttribute('src');
      icons.push({ src, file: src.split('/').pop(), cls: im.className, ...rel(im, o), rot: getComputedStyle(im).transform });
    });
    const texts = [];
    originEl.querySelectorAll('.t, .gt, [data-text]').forEach(el => {
      const txt = el.textContent.trim(); if (!txt) return;
      const cs = getComputedStyle(el);
      const g = el.classList.contains('gt') ? [cs.getPropertyValue('--g1').trim(), cs.getPropertyValue('--g2').trim()] : null;
      texts.push({ text: txt, name: el.dataset.text || null, ...textRect(el, o), size: parseFloat(cs.fontSize), color: g ? null : cs.color, gradient: g });
    });
    return { window: { w: o.width, h: o.height }, pieces, place, icons, texts };
  }

  function layout() {
    resolve();
    if (GENERIC) return genericLayout();
    clear();
    const win = document.querySelector('.win'); const o = win.getBoundingClientRect();
    const hud = document.querySelector('.hud'); const ho = hud.getBoundingClientRect();
    const pieces = {};
    for (const [k, p] of Object.entries(PIECES)) {
      const el = p.el(); const base = k.startsWith('hud') ? ho : o;
      pieces[k] = { ...rel(el, base), margin: p.m };
    }
    // every placed instance of a piece in the window
    const place = [];
    const add = (piece, el, extra) => place.push({ piece, ...rel(el, o), ...(extra || {}) });
    add('body', document.querySelector('.s3d.body'));
    add('header', document.querySelector('.s3d.header'));
    document.querySelectorAll('.rail .btn').forEach((b, i) => add(b.classList.contains('gold') ? 'tab_gold' : b.classList.contains('green') ? 'tab_green' : 'tab_navy', b, { tab: b.textContent.trim(), order: i }));
    add('free', document.querySelector('.s3d.free'));
    add('close', document.querySelector('.btn.close'), { role: 'close' });
    pills().forEach((p, i) => add(i ? 'pill_gem' : 'pill_coin', p));
    add('starter', document.querySelector('.s3d.starter'));
    document.querySelectorAll('.tile').forEach(t => add('tile', t));
    add('buy_big', document.querySelector('.starter .buy'), { role: 'buy', item: 'Starter Pack' });
    [['card_cyan', '.card.cyan'], ['card_mag', '.card.mag'], ['card_peach', '.card.peach']].forEach(([pc, sel]) => {
      const c = document.querySelector(sel); add(pc, c);
      const b = c.querySelector('.btn'); add(b.classList.contains('gray') ? 'btn_gray' : 'btn_green', b, { role: 'buy', item: c.querySelector('h3').textContent.trim() });
    });
    add('tag', document.querySelector('.tag'));
    add('badge', document.querySelector('.free .badge-n'), { role: 'ring' });
    add('check', document.querySelector('.check'));
    // icons
    const icons = [];
    document.querySelectorAll('.win img').forEach(im => {
      if (im.closest('.decor')) return;
      const src = im.getAttribute('src');
      icons.push({ src, file: src.split('/').pop(), cls: im.className, ...rel(im, o), rot: getComputedStyle(im).transform });
    });
    const decor = [];
    document.querySelectorAll('.win .decor img').forEach(im => decor.push({ file: im.getAttribute('src').split('/').pop(), cls: im.className, ...rel(im, o), opacity: +getComputedStyle(im).opacity }));
    // texts
    const texts = [];
    const T = (sel, opt) => document.querySelectorAll(sel).forEach(el => {
      const cs = getComputedStyle(el); const txt = el.textContent.trim(); if (!txt) return;
      const g = el.classList.contains('gt') ? [getComputedStyle(el).getPropertyValue('--g1').trim(), getComputedStyle(el).getPropertyValue('--g2').trim()] : null;
      texts.push({ text: txt, sel, ...textRect(el, o), size: parseFloat(cs.fontSize), color: g ? null : cs.color, gradient: g, ...(opt || {}) });
    });
    T('.title'); T('.pill .amt'); T('.btn.close'); T('.rail .btn'); T('.free .lbl'); T('.free .badge-n'); T('.starter h2'); T('.starter .sub');
    T('.tile span'); T('.op'); T('.starter .buy'); T('.card h3'); T('.card .btn'); T('.tag');
    return { window: { w: 1120, h: 680 }, pieces, place, icons, decor, texts,
             hud: { w: ho.width, h: ho.height, icon: rel(hud.querySelector('.hudbtn img'), ho), label: textRect(hud.querySelector('.hudlbl'), ho), badge: rel(hud.querySelector('.badge-n'), ho) } };
  }
  window.EXPORT = { PIECES, prepare, clear, layout };
})();
