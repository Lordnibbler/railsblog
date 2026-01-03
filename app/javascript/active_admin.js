import "@activeadmin/activeadmin";

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
