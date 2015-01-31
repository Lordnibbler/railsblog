#
# simple controller for rendering published Blog::Post .md files
#
class Blog::PostsController < ApplicationController
  def index
    @posts = Blog::Post.all
  end

  def show
    @post = Blog::Post.find_by_name(params[:id])
  end
end
