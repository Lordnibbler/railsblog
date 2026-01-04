/* eslint no-console:0 */
// This file is bundled by esbuild via jsbundling-rails.
// To reference this file, add <%= javascript_include_tag 'application' %> to the layout.


import $ from 'jquery';
window.$ = $;
window.jQuery = $;

import 'core-js/stable';
import 'regenerator-runtime/runtime';
import Rails from "@rails/ujs";
import * as Turbo from "@hotwired/turbo";

// temporarily disable turbo until we can resolve page scrolling bug on iPadOS
Turbo.session.drive = false;
window.Rails = Rails;
Rails.start();

// import alpinejs and its necessary rails adaptation
import 'alpine-turbo-drive-adapter';
import 'alpine-magic-helpers';
import 'alpinejs';


// If you are using Turbolinks 5.2, use the require syntax and make sure that
// @client-side-validations/client-side-validations is required afterTurbolinks.start(),
// so ClientSideValidations can properly attach its event handlers.
const ClientSideValidations = require('@client-side-validations/client-side-validations');
const startClientSideValidations = () => {
  if (ClientSideValidations && ClientSideValidations.start) {
    ClientSideValidations.start();
  }
};
document.addEventListener('DOMContentLoaded', startClientSideValidations);
document.addEventListener('turbo:load', startClientSideValidations);

// custom javascripts used throughout the frontend of the site
import './custom';
