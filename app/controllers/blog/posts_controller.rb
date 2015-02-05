#
# simple controller for rendering published Blog::Post .md files
#
class Blog::PostsController < ApplicationController
  def index
    @posts = Blog::Post.all.paginate(page: params[:page], per_page: 2)
  end

  def show
    @post = Blog::Post.published.friendly.find(params[:id])
  end
end
