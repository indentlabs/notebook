// Auto-grow textareas (.js-autosize-textarea) to fit their content.
//
// Browsers with `field-sizing: content` (Baseline since mid-2026) do this in
// layout, so the stylesheet rule in autosize-textareas.scss handles it and this
// script does nothing. The code below is the fallback for older browsers.
//
// The fallback has to measure content by collapsing the textarea and reading
// scrollHeight. Done naively, that collapse shortens the whole document for one
// synchronous layout and the browser clamps the window scroll to the shorter
// document. Chromium's scroll anchoring restores it, but Firefox suppresses
// anchoring when the anchor node itself changes height, and Safari has no
// anchoring at all, so the page is left scrolled up by however much the
// textarea shrank. In a long field near the bottom of an edit page that reads
// as the page jumping to the top on every keystroke. Pinning the textarea's
// parent to its current height while measuring means the document can never
// get shorter, so there is nothing to clamp.
$(document).ready(function() {
  if (window.CSS && CSS.supports && CSS.supports('field-sizing', 'content')) return;

  const yPadding = 16;
  const lineHeight = 20;
  const minLines = 3;
  const minHeight = yPadding + (minLines * lineHeight);

  function fitToContent(textarea) {
    const parent = textarea.parentElement;
    const previousMinHeight = parent.style.minHeight;

    parent.style.minHeight = parent.offsetHeight + 'px';
    textarea.style.height = minHeight + 'px';
    textarea.style.height = Math.max(textarea.scrollHeight, minHeight) + 'px';
    parent.style.minHeight = previousMinHeight;
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
