// Every category gets its own stable color, calculated from its name.
// A new category needs no setup: the same name always gives the same color.
//
// Pick a style by changing COVER_STYLE:
//   'gradient'  soft two-color gradient (previous look)
//   'solid'     solid fill
//   'soft'      pale pastel with dark text
//   'initial'   solid fill with a big first letter
//   'strip'     solid fill with a darker strip at the bottom
//   'circles'   solid fill with flat circles
const COVER_STYLE = 'circles';

// Category label on the cover: uppercase, display-style font.
// "SF Pro Display" exists only on Apple devices (and cannot be shipped), so Inter, a free close match, is loaded as the main choice.
const COVER_FONT = '"SF Pro Display", "Inter", -apple-system, "Segoe UI Variable Display", "Segoe UI", system-ui, sans-serif';
if (!document.getElementById('cover-font')) {
  const link = document.createElement('link');
  link.id = 'cover-font';
  link.rel = 'stylesheet';
  link.href = 'https://fonts.googleapis.com/css2?family=Inter:wght@600&display=swap';
  document.head.append(link);
}

function hashString(text) {
  let h = 0;
  for (const ch of text) h = (h * 31 + ch.codePointAt(0)) >>> 0;
  return h;
}

// Optional: pin a color to a specific category by name (hue 0-359).
const CATEGORY_HUES = {
  // 'Programming': 215,
  // 'Languages': 160,
};

function categoryHue(name) {
  const key = String(name || '').trim();
  return key in CATEGORY_HUES ? CATEGORY_HUES[key] : hashString(key.toLowerCase()) % 360;
}

// kept for any code that needs just a CSS background value
function categoryColor(name) {
  const h = categoryHue(name);
  return `linear-gradient(135deg, hsl(${h} 48% 27%), hsl(${(h + 28) % 360} 52% 38%))`;
}

function paintCover(card, category) {
  const cover = card.querySelector('.cover');
  if (!cover) return;
  const h = categoryHue(category), label = cover.textContent;
  const dark = (l, s = 45) => `hsl(${h} ${s}% ${l}%)`;
  cover.style.position = 'relative';
  cover.style.overflow = 'hidden';
  cover.innerHTML = '';
  const add = css => { const d = document.createElement('div'); d.style.cssText = 'position:absolute;' + css; cover.append(d); };
  const text = document.createElement('span');
  text.textContent = label;
  text.style.cssText = `position:relative;z-index:1;font-family:${COVER_FONT};font-size:12px;font-weight:600;letter-spacing:.12em;text-transform:uppercase`;

  if (COVER_STYLE === 'gradient') {
    cover.style.background = categoryColor(category);
  } else if (COVER_STYLE === 'soft') {
    cover.style.background = `hsl(${h} 65% 91%)`;
    cover.style.color = dark(22, 50);
  } else {
    cover.style.background = dark(30);
    cover.style.color = '#fff';
    if (COVER_STYLE === 'initial') {
      add(`right:12px;top:-6px;font-size:72px;font-weight:700;line-height:1;color:${dark(40)}`);
      cover.lastChild.textContent = label.trim().charAt(0).toUpperCase();
    }
    if (COVER_STYLE === 'strip') add(`left:0;right:0;bottom:0;height:30px;background:${dark(22)}`);
    if (COVER_STYLE === 'circles') {
      add(`width:84px;height:84px;right:-16px;top:-24px;border-radius:50%;background:${dark(38)}`);
      add(`width:40px;height:40px;right:52px;top:40px;border-radius:50%;background:${dark(24)}`);
    }
  }
  cover.append(text);
}
