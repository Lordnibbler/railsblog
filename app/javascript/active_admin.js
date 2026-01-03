// ActiveAdmin's JS expects global jQuery/UJS/UI modules (previously provided by Sprockets).
// With esbuild we must wire those globals and load order explicitly.
const $ = require('jquery');
window.$ = $;
window.jQuery = $;

require('jquery-ujs');
require('jquery-ui/ui/version');
require('jquery-ui/ui/widget');
require('jquery-ui/ui/plugin');
require('jquery-ui/ui/position');
require('jquery-ui/ui/widgets/mouse');
require('jquery-ui/ui/widgets/draggable');
require('jquery-ui/ui/widgets/resizable');
require('jquery-ui/ui/widgets/button');
require('jquery-ui/ui/widgets/datepicker');
require('jquery-ui/ui/widgets/dialog');
require('jquery-ui/ui/widgets/sortable');
require('jquery-ui/ui/widgets/tabs');
require('@activeadmin/activeadmin');

import { marked } from 'marked'

// event listener which renders the <textarea> for the post body
// from markdown on the left pane to HTML on the right pane
document.addEventListener('DOMContentLoaded', () => {
  const blogPostBodyElement = document.querySelector('#blog_post_body');
  if (blogPostBodyElement !== null) {
    blogPostBodyElement.addEventListener('input', updateRenderedMarkdown);

    // populate the rendered markdown once at page load
    updateRenderedMarkdown()
  }

  function updateRenderedMarkdown(){
    const markdownValue = marked.parse(blogPostBodyElement.value);
    const blogPostBodyMarkedElement = document.querySelector('#blog_post_body_marked');
    blogPostBodyMarkedElement.innerHTML = markdownValue;
  }
});
