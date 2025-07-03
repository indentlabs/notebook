/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import "../application.css";
import 'controllers'
import '../page_name_loader'

// Import Rails UJS for remote forms and CSRF tokens
// Check if jQuery UJS is already loaded via asset pipeline before loading @rails/ujs
import Rails from '@rails/ujs'
if (typeof $ === 'undefined' || typeof $.rails === 'undefined') {
  Rails.start()
} else {
  console.log('jQuery UJS already loaded via asset pipeline, skipping @rails/ujs')
}

// Support component names relative to this directory:
var componentRequireContext = require.context("components", true);
var ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);
