// Skill Made By : Crypticplay_RBLX - Only on Youtube
// Fills a design board from content.json (made by tools/build_content.py from the content spreadsheets).
// Nothing on a board is invented: an empty cell shows a labelled TEXT HOLDER (dashed box) instead.
//
//   <span data-bind="text.title_shop" data-ph="TITLE"></span>
//   <span data-bind="currencies.coins.amount" data-format="abbrev" data-ph="COINS"></span>
//   <div data-repeat="pets" data-count="10">              <!-- template, cloned per row -->
//     <img data-src="icon">  <b data-field="name" data-ph="PET NAME"></b>
//     <i data-field="power" data-format="abbrev" data-ph="POWER"></i>
//   </div>
//   data-repeat="shop" data-where="section=featured"  filters rows; data-class="rarity" adds the value as a class.
// Formats: abbrev (1.23K, 4.5M), commas (12,500), time (9:59, 1:02:03, 2d 4h), price (abbrev, keeps 0).
// The board works with no content.json at all: everything shows as text holders.
(function () {
  const SUF = ['', 'K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No', 'Dc'];
  function abbrev(n) {
    if (typeof n !== 'number' || !isFinite(n)) return String(n);
    const neg = n < 0; n = Math.abs(n); let i = 0;
    while (n >= 1000 && i < SUF.length - 1) { n /= 1000; i++; }
    let s = i === 0 ? String(Math.floor(n)) : n < 10 ? (Math.floor(n * 100) / 100).toFixed(2) : n < 100 ? (Math.floor(n * 10) / 10).toFixed(1) : String(Math.floor(n));
    if (s.includes('.')) s = s.replace(/0+$/, '').replace(/\.$/, '');
    return (neg ? '-' : '') + s + SUF[i];
  }
  const commas = n => (n < 0 ? '-' : '') + Math.floor(Math.abs(n)).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  function time(sec) {
    sec = Math.max(0, Math.floor(sec)); const d = Math.floor(sec / 86400), h = Math.floor(sec % 86400 / 3600), m = Math.floor(sec % 3600 / 60), s = sec % 60;
    if (d) return `${d}d ${h}h`; if (h) return `${h}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`; return `${m}:${String(s).padStart(2, '0')}`;
  }
  const FMT = { abbrev, commas, time, price: abbrev };

  const css = document.createElement('style');
  css.textContent = `
    .ph { color: rgba(255,255,255,.75) !important; -webkit-text-stroke: 0 !important; text-shadow: none !important;
          outline: 2px dashed rgba(255,255,255,.7); outline-offset: 2px; border-radius: 6px; padding: 0 6px;
          font-family: system-ui, sans-serif !important; font-weight: 700 !important; font-style: normal !important;
          letter-spacing: .06em; font-size: max(11px, .55em) !important; background: rgba(0,0,0,.28); }
    img.ph-img { outline: 2px dashed rgba(255,255,255,.7); outline-offset: -2px; background: rgba(0,0,0,.18); border-radius: 10px; }
    .exporting .ph, .exporting img.ph-img { outline: none !important; background: none !important; }`;
  document.head.appendChild(css);

  const get = (obj, path) => path.split('.').reduce((o, k) => (o == null ? undefined : o[k]), obj);

  function setText(el, val) {
    const fmt = el.dataset.format;
    if (val === undefined || val === null || val === '') {
      el.textContent = el.dataset.ph || (el.dataset.field || el.dataset.bind || 'TEXT').split('.').pop().toUpperCase();
      el.classList.add('ph');
      if (el.dataset.t !== undefined) el.dataset.t = el.textContent;
      return;
    }
    el.classList.remove('ph');
    const out = (el.dataset.prefix || '') + (fmt && FMT[fmt] && typeof val === 'number' ? FMT[fmt](val) : String(val)) + (el.dataset.suffix || '');
    // gradient text keeps its outline copy in data-t and the visible copy in an inner span
    const span = el.querySelector(':scope > span');
    if (el.classList.contains('gt') && span) { span.textContent = out; el.dataset.t = out; } else el.textContent = out;
  }
  function setImg(img, name) {
    if (!name) { img.classList.add('ph-img'); img.removeAttribute('src'); img.alt = ''; return; }
    img.classList.remove('ph-img');
    img.src = (img.dataset.dir || 'assets/icons/') + name + '.png';
  }

  // querySelectorAll skips the root itself; repeated templates carry data-* on the root too
  const all = (root, sel) => (root.matches && root.matches(sel) ? [root] : []).concat([...root.querySelectorAll(sel)]);

  function fill(root, data, scope) {
    all(root, '[data-bind]').forEach(el => {
      const v = get(data, el.dataset.bind);
      if (el.tagName === 'IMG') setImg(el, v); else setText(el, v);
    });
    all(root, '[data-field]').forEach(el => { if (scope) setText(el, scope[el.dataset.field]); });
    all(root, 'img[data-src]').forEach(img => { if (scope) setImg(img, scope[img.dataset.src]); });
    all(root, '[data-class]').forEach(el => {
      if (!scope) return; const v = scope[el.dataset.class];
      if (v) el.classList.add(String(v).toLowerCase());
    });
    all(root, '[data-bind-class]').forEach(el => { const v = get(data, el.dataset.bindClass); if (v) el.classList.add(String(v).toLowerCase()); });
    all(root, '[data-if]').forEach(el => { if (scope) el.style.display = scope[el.dataset.if] ? '' : 'none'; });
  }

  function render(data) {
    document.querySelectorAll('[data-repeat]').forEach(tpl => {
      let rows = get(data, tpl.dataset.repeat) || [];
      if (!Array.isArray(rows)) rows = Object.values(rows);
      if (tpl.dataset.where) {
        const [k, v] = tpl.dataset.where.split('=');
        rows = rows.filter(r => String(r[k]) === v);
      }
      const count = +(tpl.dataset.count || 0);
      const list = rows.slice(0, count || rows.length);
      while (count && list.length < count) list.push({}); // empty slots = text holders, never fake rows
      const parent = tpl.parentNode;
      tpl.removeAttribute('data-repeat');
      const blank = tpl.cloneNode(true);
      let last = tpl;
      list.forEach((row, i) => {
        const el = i === 0 ? tpl : blank.cloneNode(true);
        if (i > 0) { parent.insertBefore(el, last.nextSibling); last = el; }
        fill(el, data, row);
      });
      if (!list.length) tpl.style.display = 'none';
    });
    fill(document, data, null);
    document.dispatchEvent(new CustomEvent('content:ready'));
  }

  const go = () => fetch('content.json', { cache: 'no-store' }).then(r => (r.ok ? r.json() : {})).catch(() => ({})).then(render);
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', go); else go();
  window.CONTENT = { abbrev, commas, time };
})();
