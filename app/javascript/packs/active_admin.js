// Load Active Admin's styles into Webpacker,
// see `active_admin.scss` for customization.
import "../stylesheets/active_admin";

import "@activeadmin/activeadmin";

const marked = require('marked');

// event listener which renders the <textarea> for the post body
// from markdown on the left pane to HTML on the right pane
document.addEventListener('DOMContentLoaded', () => {
  const blogPostBodyElement = document.querySelector('#blog_post_body');

  blogPostBodyElement.addEventListener('input', updateValue);

  function updateValue(e) {
    const markdownValue = marked(e.target.value);
    const blogPostBodyMarkedElement = document.querySelector('#blog_post_body_marked');
    blogPostBodyMarkedElement.innerHTML = markdownValue;
  }
});
