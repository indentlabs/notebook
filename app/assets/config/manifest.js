//= link_tree ../images

// Only the bundles we actually reference from a layout get their own compiled
// output. app/assets/javascripts/application.js and app/assets/stylesheets/application.css
// already `require_tree .` everything beside them, so the `link_directory`
// directives that used to live here compiled every one of those ~85 files a
// second time as a standalone (fingerprinted, gzipped) asset that no view links to.
// Add an explicit `//= link` here if a file ever needs to be served on its own.
//= link application.js
//= link application.css
//= link preload/jquery-3.1.1.min.js
//= link Chart.bundle.js
//= link chartkick.js
