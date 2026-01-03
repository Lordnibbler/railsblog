/* eslint no-console:0 */
// This file is bundled by esbuild via jsbundling-rails.
// To reference this file, add <%= javascript_include_tag 'application' %> to the layout.


import 'core-js/stable';
import 'regenerator-runtime/runtime';
import * as Turbo from "@hotwired/turbo";
import $ from 'jquery';

// temporarily disable turbo until we can resolve page scrolling bug on iPadOS
Turbo.session.drive = false;
window.$ = $;
window.jQuery = $;

// import alpinejs and its necessary rails adaptation
import 'alpine-turbo-drive-adapter';
import 'alpine-magic-helpers';
import 'alpinejs';


// If you are using Turbolinks 5.2, use the require syntax and make sure that
// @client-side-validations/client-side-validations is required afterTurbolinks.start(),
// so ClientSideValidations can properly attach its event handlers.
require('@client-side-validations/client-side-validations');

// custom javascripts used throughout the frontend of the site
import './custom';
