## This file is prepended with an underscore to ensure it comes alphabetically-first
## when application.js includes all JS files in the directory with require_tree.
## Here be dragons.

window.Notebook ||= {}
Notebook.init = ->
  $('.tooltipped').tooltip { enterDelay: 50 }
  M.AutoInit()
  $('.dropdown-trigger').dropdown { coverTrigger: false }

  console.log 'Hey look it works'

# We're using $ -> here for document readiness, but if we ever use Turbolinks we'd want:
# $(document).on "turbolinks:load", ->
$ ->
  Notebook.init()