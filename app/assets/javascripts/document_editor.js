// Ensure Notebook namespace exists
if (!window.Notebook) { window.Notebook = {}; }

Notebook.DocumentEditor = class DocumentEditor {
  constructor(el) {
    this.el = el;
    if (!(this.el.length > 0)) { return; }

    window.editor = new MediumEditor('#editor', {
      targetBlank: true,
      autoLink: false,
      buttonLabels: 'fontawesome',
      toolbar: { buttons: [
        'bold',
        'italic',
        'underline',
        'strikethrough',
        {
          name: 'h1',
          action: 'append-h2',
          aria: 'header type 1',
          tagNames: [ 'h2' ],
          contentDefault: '<b>H1</b>',
          classList: [ 'custom-class-h1' ],
          attrs: { 'data-custom-attr': 'attr-value-h1'
        }
        },
        {
          name: 'h2',
          action: 'append-h3',
          aria: 'header type 2',
          tagNames: [ 'h3' ],
          contentDefault: '<b>H2</b>',
          classList: [ 'custom-class-h2' ],
          attrs: { 'data-custom-attr': 'attr-value-h2'
        }
        },
        {
          name: 'h3',
          action: 'append-h4',
          aria: 'header type 3',
          tagNames: [ 'h4' ],
          contentDefault: '<b>H3</b>',
          classList: [ 'custom-class-h3' ],
          attrs: { 'data-custom-attr': 'attr-value-h3'
        }
        },
        'justifyLeft',
        'justifyCenter',
        'justifyRight',
        'justifyFull',
        'orderedlist',
        'unorderedlist',
        'quote',
        'anchor',
        'removeFormat'
      ]
    },
      anchorPreview: { hideDelay: 0
    },
      placeholder: { text: 'Write as little or as much as you want!'
    },
      paste: { forcePlainText: false
    }
    });

    // Autosave
    let autosave_event = null;
    let last_autosave  = null;

    const autosave = function() {
      if (autosave_event === null) {

        console.log('Queueing autosave');
        $('.js-autosave-icon').addClass('grey-text');
        $('.js-autosave-icon').removeClass('black-text');
        $('.js-autosave-icon').removeClass('red-text');
        $('.js-autosave-status').text('Saving changes...');

        autosave_event = setTimeout((function() {
          console.log('Autosaving...');
          $('.js-autosave-status').text('Saving...');
          autosave_event = null;

          // Do the autosave
          last_autosave = $.ajax({
            type: 'PATCH',
            url: $('#editor').data('save-url'),
            data: { document: {
              title: $('#document_title').val(),
              body: $('#editor').html()
            }
          }
          });

          last_autosave.fail(function(jqXHR, textStatus) {
            $('.js-autosave-status').text('There was a problem saving! We will try to save again, but please make sure you back up any changes.');
            $('.js-autosave-status').addClass('red-text');
            $('.js-autosave-status').removeClass('grey-text');
            $('.js-autosave-status').removeClass('black-text');
          });

          // Done!
          $('.js-autosave-icon').addClass('black-text');
          $('.js-autosave-icon').removeClass('grey-text');
          $('.js-autosave-icon').removeClass('red-text');
          $('.js-autosave-status').text('Saved!');

        }), 2500);

      } else {
        console.log('Waiting for existing autosave');
      }
    };

    editor.subscribe('editableInput', autosave);
    $('#document_title').on('change', autosave);
    $('#document_title').on('keydown', autosave);
    $('.js-autosave-status').on('click', autosave);

    // Allow entering `tab` into the editor
    $(document).delegate('#editor', 'keydown', function(e) {
      const keyCode = e.keyCode || e.which;
      if (keyCode === 9) {
        e.preventDefault();
      }
    });
  }
};

$(() => new Notebook.DocumentEditor($("body.documents.edit")));
