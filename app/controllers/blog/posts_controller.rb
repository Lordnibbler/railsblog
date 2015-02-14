#
# simple controller for rendering published Blog::Post .md files
#
class Blog::PostsController < ApplicationController
  def index
    body_class('home')
    @posts = Blog::Post.published.newest.page(params[:page])
  end

  def show
    body_class('post')
    @post = Blog::Post.published.friendly.find(params[:id])
  end
end
