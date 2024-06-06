// app/javascript/packs/active_admin.js

import $ from 'jquery';
import 'jquery-ui/ui/widget';  // This must be imported first
import 'jquery-ui/ui/widgets/datepicker';
import 'jquery-ui/ui/widgets/dialog';
import 'jquery-ui/ui/widgets/sortable';
import 'jquery-ui/ui/widgets/tabs';
import '@rails/ujs';


// Load Active Admin's styles into Webpacker,
// see `active_admin.scss` for customization.
import './active_admin.scss';

require('@activeadmin/activeadmin');

import { marked } from 'marked';

// Event listener which renders the <textarea> for the post body
// from markdown on the left pane to HTML on the right pane
document.addEventListener('DOMContentLoaded', () => {
  const blogPostBodyElement = document.querySelector('#blog_post_body');
  if (blogPostBodyElement !== null) {
    blogPostBodyElement.addEventListener('input', updateRenderedMarkdown);

    // Populate the rendered markdown once at page load
    updateRenderedMarkdown();
  }

  function updateRenderedMarkdown() {
    const markdownValue = marked.parse(blogPostBodyElement.value);
    const blogPostBodyMarkedElement = document.querySelector('#blog_post_body_marked');
    blogPostBodyMarkedElement.innerHTML = markdownValue;
  }
});
