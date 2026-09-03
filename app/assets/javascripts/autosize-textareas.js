// Auto-grow textareas (.js-autosize-textarea) to fit their content.
//
// The only way to measure a textarea's content height is to collapse it so
// scrollHeight reflects the text rather than the current box. Done naively,
// that collapse shortens the whole document for one synchronous layout. Every
// browser clamps the window scroll position to the shorter document during
// that layout; Chromium's scroll anchoring quietly puts it back, but browsers
// without it (Safari/WebKit) leave the page scrolled up by however much the
// textarea shrank. For a long field near the bottom of an edit page that looks
// like the page jumping to the top on every keystroke.
//
// So while measuring, the textarea's parent is pinned to its current height
// (the document can't get shorter, so nothing gets clamped), and any scroll
// offset that moved anyway is restored afterwards.
$(document).ready(function() {
  const yPadding = 16;
  const lineHeight = 20;
  const minLines = 3;
  const minHeight = yPadding + (minLines * lineHeight);

  function scrollOffsets(element) {
    const offsets = [{ node: window, top: window.pageYOffset }];
    for (let node = element.parentElement; node; node = node.parentElement) {
      if (node.scrollTop > 0) offsets.push({ node: node, top: node.scrollTop });
    }
    return offsets;
  }

  function restoreScrollOffsets(offsets) {
    offsets.forEach(function(entry) {
      if (entry.node === window) {
        if (window.pageYOffset !== entry.top) window.scrollTo(window.pageXOffset, entry.top);
      } else if (entry.node.scrollTop !== entry.top) {
        entry.node.scrollTop = entry.top;
      }
    });
  }

  function fitToContent(textarea) {
    const parent = textarea.parentElement;
    const offsets = scrollOffsets(textarea);
    const previousMinHeight = parent ? parent.style.minHeight : '';

    if (parent) parent.style.minHeight = parent.offsetHeight + 'px';
    textarea.style.height = minHeight + 'px';
    textarea.style.height = Math.max(textarea.scrollHeight, minHeight) + 'px';
    if (parent) parent.style.minHeight = previousMinHeight;

    restoreScrollOffsets(offsets);
  }

  // Textareas that aren't rendered yet (e.g. inside a hidden category section)
  // have no scrollHeight, so estimate from the line count until they're shown.
  function estimateFromLines(textarea) {
    const linesCount = Math.max(textarea.value.split("\n").length, minLines);
    textarea.style.height = (yPadding + (linesCount * lineHeight)) + 'px';
  }

  const elements = document.getElementsByClassName('js-autosize-textarea');
  for (let i = 0; i < elements.length; i++) {
    const textarea = elements[i];
    textarea.style.overflowY = 'hidden';

    if (textarea.offsetParent === null) {
      estimateFromLines(textarea);
      textarea.dataset.autosizeEstimated = 'true';
    } else {
      fitToContent(textarea);
    }

    textarea.addEventListener('input', function() { fitToContent(this); });
    // A field sized while hidden gets measured properly the first time it's focused.
    textarea.addEventListener('focus', function() {
      if (this.dataset.autosizeEstimated) {
        delete this.dataset.autosizeEstimated;
        fitToContent(this);
      }
    });
  }
});
