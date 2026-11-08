// Counts words exactly the way the server does (app/services/word_count_service.rb), so the live
// counts in the editors match the counts the server stores. Read the comment at the top of that
// file for the rules. Both are tested against test/fixtures/files/word_count_cases.json: a change
// here needs the same change there, and a new case in that file.
//
// Usage: NotebookWordCount.count(htmlOrPlainText)
(function (root, factory) {
  var api = factory();
  if (typeof module === 'object' && module.exports) { module.exports = api; }
  if (root) { root.NotebookWordCount = api; }
})(typeof window !== 'undefined' ? window : null, function () {
  'use strict';

  var BLOCK_TAG = /<\/?(?:address|article|aside|blockquote|br|caption|dd|details|div|dl|dt|figcaption|figure|footer|h[1-6]|header|hr|li|main|nav|ol|p|pre|section|summary|table|tbody|td|tfoot|th|thead|tr|ul)\b[^<>]*>/gi;
  var HIDDEN_ELEMENT = /<(script|style)\b[^<>]*>[\s\S]*?<\/\1\s*>/gi;
  var COMMENT = /<!--[\s\S]*?-->/g;
  var ANY_TAG = /<[\/!]?[a-zA-Z][^<>]*>/g;

  var ENTITY = /&(#\d{1,7}|#x[0-9a-f]{1,6}|[a-z][a-z0-9]{1,31});/gi;
  var NAMED_ENTITIES = {
    nbsp: '\u00A0', ensp: '\u2002', emsp: '\u2003', thinsp: '\u2009',
    amp: '&', lt: '<', gt: '>', quot: '"', apos: "'",
    mdash: '\u2014', ndash: '\u2013', hellip: '\u2026',
    lsquo: '\u2018', rsquo: '\u2019', sbquo: '\u201A',
    ldquo: '\u201C', rdquo: '\u201D', bdquo: '\u201E'
  };

  var SEPARATOR = /[\u2014\u2015\u2026]|\.{2,}|-{2,}/g;
  var WHITESPACE = '\\s\\u00A0\\u1680\\u180E\\u2000-\\u200B\\u2028\\u2029\\u202F\\u205F\\u3000\\uFEFF';
  var TOKEN = new RegExp('[^' + WHITESPACE + ']+', 'g');
  var WORDLIKE = /[\p{L}\p{N}]/u;
  var SLASHES = /[\/\\]/;
  var LINK = /^[^\p{L}\p{N}]*(?:(?:https?|ftp):\/\/|www\.)/iu;
  var DATE = /^\d{1,4}\/\d{1,2}(?:\/\d{1,4})?$/;
  var EDGE_PUNCTUATION = /^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$/gu;

  function decodeEntity(match, name) {
    if (name.charAt(0) !== '#') {
      var named = NAMED_ENTITIES[name.toLowerCase()];
      return named === undefined ? '' : named;
    }

    var hex = name.charAt(1) === 'x' || name.charAt(1) === 'X';
    var codepoint = hex ? parseInt(name.slice(2), 16) : parseInt(name.slice(1), 10);
    if (!codepoint || codepoint > 0x10FFFF || (codepoint >= 0xD800 && codepoint <= 0xDFFF)) return '';

    return String.fromCodePoint(codepoint);
  }

  // The text a reader would see, with word-separating markup turned into spaces.
  function plainText(text) {
    text = String(text);

    if (text.indexOf('<') !== -1) {
      text = text.replace(HIDDEN_ELEMENT, ' ').replace(COMMENT, ' ').replace(BLOCK_TAG, ' ').replace(ANY_TAG, '');
    }
    if (text.indexOf('&') !== -1) {
      text = text.replace(ENTITY, decodeEntity);
    }

    return text.replace(SEPARATOR, ' ');
  }

  function wordsInToken(token) {
    if (!WORDLIKE.test(token)) return 0;
    if (!SLASHES.test(token)) return 1;
    if (LINK.test(token)) return 1;
    if (DATE.test(token.replace(EDGE_PUNCTUATION, ''))) return 1;

    return token.split(SLASHES).filter(function (part) { return WORDLIKE.test(part); }).length;
  }

  function count(text) {
    if (text === null || text === undefined) return 0;

    var tokens = plainText(text).match(TOKEN);
    if (!tokens) return 0;

    var words = 0;
    for (var i = 0; i < tokens.length; i++) {
      words += wordsInToken(tokens[i]);
    }
    return words;
  }

  return { count: count, plainText: plainText };
});
