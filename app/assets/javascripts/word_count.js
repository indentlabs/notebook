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

  // A tag is "<", an ASCII name (optionally after "/" or "!") and then whitespace, "/" or ">". So
  // plain text like "I <3 you", "a < b" or an <email@example.com> keeps its words, and so does a
  // Markdown autolink like <https://example.com/page>.
  var TAG = /<(?![A-Za-z][A-Za-z0-9+.\-]*:\/\/)([\/!]?)([A-Za-z][A-Za-z0-9:\-]*)(?=[ \t\n\f\r\/>])[^<>]*>/y;
  // Tags that separate words, the way they separate lines or cells on screen
  var BLOCK_TAGS = {};
  ('address article aside blockquote br caption center dd details dialog div dl dt fieldset ' +
   'figcaption figure footer form h1 h2 h3 h4 h5 h6 header hgroup hr legend li main menu nav ol p ' +
   'pre section summary table tbody td tfoot th thead tr ul').split(' ').forEach(function (name) { BLOCK_TAGS[name] = true; });
  // Elements whose contents aren't shown. Unclosed, they hide the rest of the text, as in a browser.
  var HIDDEN_ELEMENT_ENDS = {
    script: /<\/[Ss][Cc][Rr][Ii][Pp][Tt][ \t\n\f\r]*>/g,
    style: /<\/[Ss][Tt][Yy][Ll][Ee][ \t\n\f\r]*>/g
  };

  var ENTITY = /&(#[0-9]{1,7}|#[xX][0-9A-Fa-f]{1,6}|[A-Za-z][A-Za-z0-9]{1,31});/g;
  // Named entities that split words, join them, or aren't words on their own (keys in lower case)
  var NAMED_ENTITIES = {
    nbsp: '\u00A0', nonbreakingspace: '\u00A0', ensp: '\u2002', emsp: '\u2003',
    emsp13: '\u2004', emsp14: '\u2005', numsp: '\u2007', puncsp: '\u2008',
    thinsp: '\u2009', thinspace: '\u2009', hairsp: '\u200A', verythinspace: '\u200A',
    mediumspace: '\u205F', zerowidthspace: '\u200B', newline: '\n', tab: '\t',
    amp: '&', lt: '<', gt: '>', quot: '"', apos: "'",
    mdash: '\u2014', horbar: '\u2015', ndash: '\u2013', hellip: '\u2026', mldr: '\u2026',
    lsquo: '\u2018', rsquo: '\u2019', sbquo: '\u201A',
    ldquo: '\u201C', rdquo: '\u201D', bdquo: '\u201E'
  };
  // Named entities for letters (&eacute;, &szlig;, &alpha;...), which can be a whole word
  var LETTER_ENTITY = /^(?:[A-Za-z](?:acute|grave|circ|tilde|uml|ring|cedil|slash|caron|macr|ogon|dot|breve|dblac|strok)|[A-Za-z]{2}lig|szlig|eth|thorn)$/i;
  var GREEK_LETTER_ENTITIES = {};
  ('alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu nu xi omicron pi rho sigma ' +
   'sigmaf tau upsilon phi chi psi omega thetasym upsih piv').split(' ').forEach(function (name) { GREEK_LETTER_ENTITIES[name] = true; });
  // Any other named entity is a symbol (&copy;, &euro;), not a word.

  var SEPARATOR = /[\u2014\u2015\u2026]|\.{2,}|-{2,}/g;
  var WHITESPACE = '\\s\\u00A0\\u1680\\u180E\\u2000-\\u200B\\u2028\\u2029\\u202F\\u205F\\u3000\\uFEFF';
  var TOKEN = new RegExp('[^' + WHITESPACE + ']+', 'g');
  var WORDLIKE = /[\p{L}\p{N}]/u;
  var SLASHES = /[\/\\]/;
  // No lookbehind: Safari before 16.4 can't parse one, and a regex it can't parse stops all of application.js.
  var LINK = /(?:[Hh][Tt][Tt][Pp][Ss]?|[Ff][Tt][Pp]):\/\/|(?:^|[^\p{L}\p{N}])[Ww][Ww][Ww]\./u;
  var DATE = /^[^\p{L}\p{N}]*[0-9]{1,4}\/[0-9]{1,2}(?:\/[0-9]{1,4})?[^\p{L}\p{N}]*$/u;

  function decodeEntity(match, name) {
    if (name.charAt(0) !== '#') {
      var lower = name.toLowerCase();
      if (Object.prototype.hasOwnProperty.call(NAMED_ENTITIES, lower)) return NAMED_ENTITIES[lower];
      if (LETTER_ENTITY.test(name) || Object.prototype.hasOwnProperty.call(GREEK_LETTER_ENTITIES, lower)) return 'a';

      return '';
    }

    var hex = name.charAt(1) === 'x' || name.charAt(1) === 'X';
    var codepoint = hex ? parseInt(name.slice(2), 16) : parseInt(name.slice(1), 10);
    if (!codepoint || codepoint > 0x10FFFF || (codepoint >= 0xD800 && codepoint <= 0xDFFF)) return '';

    return String.fromCodePoint(codepoint);
  }

  // One pass over the text, looking at each "<" once, so even malformed HTML takes linear time.
  function stripMarkup(text) {
    var result = [];
    var position = 0;
    var open;

    while ((open = text.indexOf('<', position)) !== -1) {
      result.push(text.slice(position, open));

      if (text.substr(open, 4) === '<!--') {
        var commentEnd = text.indexOf('-->', open + 4);
        result.push(' ');
        position = commentEnd === -1 ? text.length : commentEnd + 3;
        continue;
      }

      TAG.lastIndex = open;
      var tag = TAG.exec(text);
      if (!tag) {
        result.push('<');
        position = open + 1;
        continue;
      }

      var name = tag[2].toLowerCase();
      var tagEnd = open + tag[0].length;
      var hiddenEnd = tag[1] === '' && tag[0].slice(-2) !== '/>' && Object.prototype.hasOwnProperty.call(HIDDEN_ELEMENT_ENDS, name) ? HIDDEN_ELEMENT_ENDS[name] : null;

      if (hiddenEnd) {
        hiddenEnd.lastIndex = tagEnd;
        var close = hiddenEnd.exec(text);
        result.push(' ');
        position = close ? close.index + close[0].length : text.length;
      } else {
        if (BLOCK_TAGS[name]) result.push(' ');
        position = tagEnd;
      }
    }

    result.push(text.slice(position));
    return result.join('');
  }

  // The text a reader would see, with word-separating markup turned into spaces.
  function plainText(text) {
    text = String(text);

    if (text.indexOf('<') !== -1) text = stripMarkup(text);
    if (text.indexOf('&') !== -1) text = text.replace(ENTITY, decodeEntity);

    return text.replace(SEPARATOR, ' ');
  }

  function wordsInToken(token) {
    if (!WORDLIKE.test(token)) return 0;
    if (!SLASHES.test(token)) return 1;
    if (LINK.test(token) || DATE.test(token)) return 1;

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
