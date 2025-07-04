//# This file is prepended with an underscore to ensure it comes alphabetically-first
//# when application.js includes all JS files in the directory with require_tree.
//# Here be dragons.

// After we have fully moved to TailwindCSS, this file can be safely removed (I think lol).

if (!window.Notebook) { window.Notebook = {}; }
Notebook.init = function() {
  // Initialize MaterializeCSS stuff
  M.AutoInit();
  $('.sidenav').sidenav();
  $('.quick-reference-sidenav').sidenav({
    closeOnClick: true,
    edge:         'right',
    draggable:    false
  });
  $('#recent-edits-sidenav').sidenav({
    closeOnClick: true,
    edge:         'right',
    draggable:    false
  });
  $('.slider').slider({ height: 200, indicators: false });
  $('.dropdown-trigger').dropdown({ coverTrigger: false });
  $('.dropdown-trigger-on-hover').dropdown({ coverTrigger: false, hover: true });
  $('.tooltipped').tooltip({ enterDelay: 50 });
  $('.with-character-counter').characterCounter();
  $('.materialboxed').materialbox();
};

$(() => Notebook.init());
