// Wordsmith: a word-choice reference panel for the document editor.
//
// While the panel is open, whatever the writer highlights in the editor is
// looked up against Notebook's own offline dictionary, thesaurus and rhyming
// data (see WordsmithController). State lives in a shared Alpine store so the
// desktop and mobile copies of the panel always show the same word.

(function() {
  const MAX_SELECTION_LENGTH = 60;
  const MAX_SELECTION_WORDS = 4;
  const RELATED_PREVIEW_COUNT = 30;
  const COLLAPSED_SECTIONS_KEY = 'wordsmithCollapsedSections';

  function normalize(text) {
    return (text || '')
      .replace(/[\u2018\u2019]/g, "'")
      .replace(/^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$/gu, '')
      .replace(/\s+/g, ' ')
      .toLowerCase();
  }

  function readCollapsedSections() {
    try {
      return JSON.parse(localStorage.getItem(COLLAPSED_SECTIONS_KEY)) || {};
    } catch (e) {
      return {};
    }
  }

  // The text highlighted in the editor, or '' if nothing there is highlighted.
  function editorSelectionText() {
    const editor = document.getElementById('editor');
    const selection = window.getSelection();
    if (!editor || !selection || selection.isCollapsed || !selection.rangeCount) return '';
    if (!editor.contains(selection.anchorNode)) return '';

    return selection.toString().trim();
  }

  // How many times the word appears in the document being edited.
  function countInDocument(word) {
    const editor = document.getElementById('editor');
    if (!editor || !word) return 0;

    const escaped = word.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').replace(/ /g, '\\s+');
    const pattern = new RegExp("(^|[^\\p{L}\\p{N}'\u2019])" + escaped + "(?=$|[^\\p{L}\\p{N}'\u2019])", 'giu');
    return (editor.innerText.match(pattern) || []).length;
  }

  document.addEventListener('alpine:init', function() {
    Alpine.store('wordsmith', {
      active: false,
      status: 'idle', // idle, loading, found, not_found, unavailable, error
      query: '',
      input: '',
      result: null,
      usageCount: 0,
      history: [],
      showAllRelated: false,
      collapsed: readCollapsedSections(),
      cache: {},
      requestId: 0,
      lastSelection: '',
      selectionAtTabPress: '',

      setActive(active) {
        this.active = active;
        if (active) {
          this.lastSelection = '';
          // Tapping the tab on a touch screen can clear the highlight before the panel
          // opens, so fall back to what was highlighted when the tab was pressed.
          this.lookupSelection(editorSelectionText() || this.selectionAtTabPress);
        }
        this.selectionAtTabPress = '';
      },

      // Look up the editor's current selection, if it's short enough to be a word or phrase.
      lookupSelection(text = editorSelectionText()) {
        // selectionchange also fires when clicking a word in the panel moves focus out of
        // the editor, with the old highlight still in place. Only a new highlight counts,
        // or it would yank the panel straight back to the word that's highlighted.
        if (text === this.lastSelection) return;
        this.lastSelection = text;

        if (!text || text.length > MAX_SELECTION_LENGTH || text.split(/\s+/).length > MAX_SELECTION_WORDS) return;

        this.lookup(text);
      },

      lookup(text, options = {}) {
        const word = normalize(text);
        if (!word || (word === this.query && this.status !== 'error')) return;

        if (this.query && this.status === 'found' && !options.fromHistory) {
          this.history.push(this.query);
          if (this.history.length > 25) this.history.shift();
        }

        this.query = word;
        this.input = word;
        this.showAllRelated = false;
        this.usageCount = countInDocument(word);

        if (this.cache[word]) {
          this.show(this.cache[word]);
          return;
        }

        this.status = 'loading';
        const requestId = ++this.requestId;

        fetch('/wordsmith/lookup?q=' + encodeURIComponent(word), {
          headers: { 'Accept': 'application/json' },
          credentials: 'same-origin'
        })
          .then(response => {
            if (!response.ok) throw new Error('Wordsmith lookup failed: HTTP ' + response.status);
            return response.json();
          })
          .then(data => {
            if (data.available) this.cache[word] = data;
            if (requestId === this.requestId) this.show(data);
          })
          .catch(error => {
            console.error(error);
            if (requestId === this.requestId) this.status = 'error';
          });
      },

      retry() {
        const word = this.query;
        this.query = '';
        this.lookup(word, { fromHistory: true });
      },

      show(data) {
        this.result = data;
        this.status = !data.available ? 'unavailable' : (data.found ? 'found' : 'not_found');
      },

      back() {
        const previous = this.history.pop();
        if (previous) this.lookup(previous, { fromHistory: true });
      },

      search() {
        this.lookup(this.input);
      },

      isCollapsed(section) {
        return !!this.collapsed[section];
      },

      toggleSection(section) {
        this.collapsed[section] = !this.collapsed[section];
        try {
          localStorage.setItem(COLLAPSED_SECTIONS_KEY, JSON.stringify(this.collapsed));
        } catch (e) {}
      },

      // Senses grouped by part of speech, keeping the server's order.
      get meaningGroups() {
        const groups = [];
        ((this.result && this.result.senses) || []).forEach(sense => {
          const last = groups[groups.length - 1];
          if (last && last.pos === sense.pos) {
            last.senses.push(sense);
          } else {
            groups.push({ pos: sense.pos, senses: [sense] });
          }
        });
        return groups;
      },

      get relatedWords() {
        const words = (this.result && this.result.related) || [];
        return this.showAllRelated ? words : words.slice(0, RELATED_PREVIEW_COUNT);
      },

      get hiddenRelatedCount() {
        const words = (this.result && this.result.related) || [];
        return this.showAllRelated ? 0 : Math.max(words.length - RELATED_PREVIEW_COUNT, 0);
      }
    });
  });

  // While the panel is closed, a new highlight pulls the Wordsmith tab out and back
  // to point the writer at it. Shares lastSelection with lookupSelection, so closing
  // the panel over a word it just looked up doesn't set the tab off.
  function nudgeTab(store) {
    const text = editorSelectionText();
    if (text === store.lastSelection) return;
    store.lastSelection = text;
    if (!text) return;

    document.querySelectorAll('.js-sidebar-toggle-tab[data-panel="wordsmith"]').forEach(tab => {
      tab.classList.remove('wordsmith-tab-nudge');
      void tab.offsetWidth; // restart the animation if it's already playing
      tab.classList.add('wordsmith-tab-nudge');
      tab.addEventListener('animationend', () => tab.classList.remove('wordsmith-tab-nudge'), { once: true });
    });
  }

  // Remember what was highlighted when the Wordsmith tab is pressed (see setActive). Pressing
  // comes before a tap clears the highlight, so this catches it even when the click can't.
  document.addEventListener('pointerdown', function(event) {
    if (!window.Alpine || !event.target.closest('.js-sidebar-toggle-tab[data-panel="wordsmith"]')) return;

    Alpine.store('wordsmith').selectionAtTabPress = editorSelectionText();
  }, true);

  // Follow the writer's highlighting while the panel is open, or nudge its tab while it's closed.
  let selectionTimer = null;
  document.addEventListener('selectionchange', function() {
    if (!window.Alpine || !document.getElementById('editor')) return;

    const store = Alpine.store('wordsmith');
    if (!store) return;

    clearTimeout(selectionTimer);
    selectionTimer = setTimeout(() => store.active ? store.lookupSelection() : nudgeTab(store), 300);
  });

  // Fired by the toolbar button; documentEditController opens the panel on the same event.
  window.addEventListener('wordsmith-open', function(event) {
    if (!window.Alpine) return;
    Alpine.store('wordsmith').lookup(event.detail && event.detail.text);
  });

  // Hammer button for the Medium Editor toolbar. Built lazily because
  // MediumEditor is loaded after this file.
  window.createWordsmithToolbarButton = function() {
    const icon = '<i class="material-icons text-lg">hardware</i>';
    const WordsmithButton = MediumEditor.extensions.button.extend({
      name: 'wordsmith',
      action: 'wordsmith',
      aria: 'Look up in Wordsmith',
      contentDefault: icon,
      contentFA: icon,

      handleClick: function(event) {
        event.preventDefault();
        event.stopPropagation();

        const text = window.getSelection().toString();
        window.dispatchEvent(new CustomEvent('wordsmith-open', { detail: { text: text } }));
      }
    });

    return new WordsmithButton();
  };
})();
