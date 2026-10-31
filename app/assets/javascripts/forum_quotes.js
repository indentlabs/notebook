// Collapses deeply nested forum quotes ("quote of a quote of a quote...").
//
// Every quote level indents the text further, so a long reply chain squeezes
// the innermost text down to a letter or two per line on phones. Anything
// nested deeper than MAX_VISIBLE_DEPTH is folded behind a toggle instead.
(function () {
  var MAX_VISIBLE_DEPTH = 2;

  function quoteDepth(blockquote, root) {
    var depth = 0;
    for (var node = blockquote; node && node !== root; node = node.parentElement) {
      if (node.tagName === 'BLOCKQUOTE') depth++;
    }
    return depth;
  }

  function collapseQuotes(root) {
    root.querySelectorAll('blockquote').forEach(function (blockquote) {
      if (blockquote.closest('.forum-quote-collapse')) return;
      if (quoteDepth(blockquote, root) <= MAX_VISIBLE_DEPTH) return;

      var hiddenLevels = 1 + blockquote.querySelectorAll('blockquote').length;
      var details = document.createElement('details');
      details.className = 'forum-quote-collapse';

      var summary = document.createElement('summary');
      summary.textContent = hiddenLevels === 1
        ? 'Show earlier quote'
        : 'Show ' + hiddenLevels + ' earlier quotes';

      blockquote.parentNode.insertBefore(details, blockquote);
      details.appendChild(summary);
      details.appendChild(blockquote);
    });
  }

  function init() {
    document.querySelectorAll('.thredded--post--content').forEach(collapseQuotes);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
