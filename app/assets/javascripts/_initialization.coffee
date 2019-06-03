## This file is prepended with an underscore to ensure it comes alphabetically-first
## when application.js includes all JS files in the directory with require_tree.
## Here be dragons.

window.Notebook ||= {}
Notebook.init = ->
  # Initialize MaterializeCSS stuff
  M.AutoInit()
  $('.sidenav').sidenav()
  $('.slider').slider { height: 200, indicators: false }
  $('.dropdown-trigger').dropdown { coverTrigger: false }
  $('.tooltipped').tooltip { enterDelay: 50 }
  $('.with-character-counter').characterCounter();

# We're using $ -> here for document readiness, but if we ever use Turbolinks we'd want:
# $(document).on "turbolinks:load", ->
$ ->
  Notebook.init()