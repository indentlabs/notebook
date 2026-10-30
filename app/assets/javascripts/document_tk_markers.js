// TK markers for the document editor.
// Writers use "TK" ("to come") as a placeholder for anything they still need to
// fill in. This highlights every TK in #editor and pins a margin flag beside its
// line as a reminder to fill it in before finishing.
//
// Highlights and flags are drawn in an overlay layer *next to* the editor rather
// than by wrapping TKs in spans, so the saved document HTML is never modified.

document.addEventListener('DOMContentLoaded', function() {
  const editorElement = document.getElementById('editor');
  if (!editorElement) return;

  // Uppercase TK as a standalone word (also catches TKTK, a common variant)
  const TK_PATTERN = /\b(?:TK)+\b/g;
  const FLAG_WIDTH = 216;   // px; keep in sync with .tk-margin-flag in document_editor.scss
  const FLAG_GAP = 24;      // px between the text column and the flag
  const FLAG_SPACING = 4;   // px between stacked flags

  const container = editorElement.parentNode;
  if (window.getComputedStyle(container).position === 'static') {
    container.style.position = 'relative';
  }

  // The overlay sits behind the (transparent) editor so highlights don't cover the text
  const overlay = document.createElement('div');
  overlay.className = 'tk-overlay';
  overlay.setAttribute('aria-hidden', 'true');
  container.insertBefore(overlay, editorElement);
  container.classList.add('tk-container');

  // Flags sit above the editor so they can be clicked
  const flagLayer = document.createElement('div');
  flagLayer.className = 'tk-flag-layer';
  container.appendChild(flagLayer);

  const findTkRanges = function() {
    const ranges = [];
    const walker = document.createTreeWalker(editorElement, NodeFilter.SHOW_TEXT, null);
    let node;
    while ((node = walker.nextNode())) {
      if (node.nodeValue.indexOf('TK') === -1) continue;
      TK_PATTERN.lastIndex = 0;
      let match;
      while ((match = TK_PATTERN.exec(node.nodeValue))) {
        const range = document.createRange();
        range.setStart(node, match.index);
        range.setEnd(node, match.index + match[0].length);
        ranges.push(range);
      }
    }
    return ranges;
  };

  const selectRange = function(range) {
    const selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    editorElement.focus();
  };

  const render = function() {
    overlay.innerHTML = '';
    flagLayer.innerHTML = '';

    const ranges = findTkRanges();
    if (ranges.length === 0) return;

    const containerRect = container.getBoundingClientRect();

    // Only show margin flags when there's room for them to the right of the text
    const roomForFlags = document.documentElement.clientWidth - containerRect.right >= FLAG_GAP + FLAG_WIDTH + 16;

    // Group TKs by line so each line gets a single flag
    const lines = [];
    ranges.forEach(function(range) {
      const rects = Array.prototype.slice.call(range.getClientRects());
      if (rects.length === 0) return;

      rects.forEach(function(rect) {
        const highlight = document.createElement('div');
        highlight.className = 'tk-highlight';
        highlight.style.top = (rect.top - containerRect.top) + 'px';
        highlight.style.left = (rect.left - containerRect.left) + 'px';
        highlight.style.width = rect.width + 'px';
        highlight.style.height = rect.height + 'px';
        overlay.appendChild(highlight);
      });

      const top = rects[0].top - containerRect.top;
      const line = lines.find(function(l) { return Math.abs(l.top - top) < 4; });
      if (line) {
        line.ranges.push(range);
      } else {
        lines.push({ top: top, height: rects[0].height, ranges: [range] });
      }
    });

    if (!roomForFlags) return;

    let nextAvailableTop = -Infinity;
    lines.forEach(function(line) {
      const flag = document.createElement('button');
      flag.type = 'button';
      flag.className = 'tk-margin-flag';
      flag.style.left = (containerRect.width + FLAG_GAP) + 'px';
      flag.title = 'Click to jump to this TK';

      const label = line.ranges.length > 1 ? line.ranges.length + ' TKs' : 'TK';
      flag.innerHTML =
        '<i class="material-icons tk-margin-flag-icon">flag</i>' +
        '<span><strong>' + label + '</strong> &middot; fill in before finishing</span>';

      flagLayer.appendChild(flag);

      // Center the flag on its line, but never overlap the flag above it
      let flagTop = line.top + (line.height - flag.offsetHeight) / 2;
      flagTop = Math.max(flagTop, nextAvailableTop);
      flag.style.top = flagTop + 'px';
      nextAvailableTop = flagTop + flag.offsetHeight + FLAG_SPACING;

      // Clicking a flag selects the (first) TK on its line so the writer can type over it
      let clickIndex = 0;
      flag.addEventListener('mousedown', function(e) { e.preventDefault(); });
      flag.addEventListener('click', function() {
        selectRange(line.ranges[clickIndex % line.ranges.length]);
        clickIndex++;
      });
    });
  };

  let renderFrame = null;
  const scheduleRender = function() {
    if (renderFrame) return;
    renderFrame = window.requestAnimationFrame(function() {
      renderFrame = null;
      render();
    });
  };

  let inputTimeout = null;
  const debouncedRender = function() {
    clearTimeout(inputTimeout);
    inputTimeout = setTimeout(scheduleRender, 150);
  };

  editorElement.addEventListener('input', debouncedRender);
  if (window.editor && window.editor.subscribe) {
    // Also catches toolbar formatting changes, which don't fire native input events
    window.editor.subscribe('editableInput', debouncedRender);
  }

  window.addEventListener('resize', scheduleRender);
  if (window.ResizeObserver) {
    // Reflows (sidebar toggles, images loading, etc.) move text around
    new ResizeObserver(scheduleRender).observe(container);
  }
  if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(scheduleRender);
  }

  scheduleRender();
});
