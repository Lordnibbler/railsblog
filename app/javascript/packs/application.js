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

import 'core-js/stable'
import 'regenerator-runtime/runtime'
import Turbolinks from "turbolinks"
import "stylesheets/application.css"
import "stylesheets/_pygment_monokai.sass"

Turbolinks.start()

// import alpinejs and its necessary rails adaptation
import 'alpine-turbo-drive-adapter'
import 'alpine-magic-helpers'
import 'alpinejs'


// If you are using Turbolinks 5.2, use the require syntax and make sure that
// @client-side-validations/client-side-validations is required afterTurbolinks.start(),
// so ClientSideValidations can properly attach its event handlers.
require('@client-side-validations/client-side-validations')

// custom javascripts used throughout the frontend of the site
import './custom';
