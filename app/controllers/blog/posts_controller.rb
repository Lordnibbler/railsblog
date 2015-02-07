#
# simple controller for rendering published Blog::Post .md files
#
class Blog::PostsController < ApplicationController
  def index
    @posts = Blog::Post.published.page(params[:page])
  end

  def show
    @post = Blog::Post.published.friendly.find(params[:id])
  end
end
