#
# simple controller for rendering published Blog::Post .md files
#
class Blog::PostsController < ApplicationController
  def index
    set_body_class('home')
    @posts = Blog::Post.published.page(params[:page])
  end

  def show
    set_body_class('post')
    @post = Blog::Post.published.friendly.find(params[:id])
  end
end
