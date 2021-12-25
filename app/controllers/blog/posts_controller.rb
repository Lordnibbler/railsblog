#
# render published Blog::Post objects
#
class Blog::PostsController < ApplicationController
  before_action do
    body_class('post')
  end

  def index
    @posts = Blog::Post.published.newest.page(params[:page])
  end

  def show
    @post = Blog::Post.published.friendly.find(params[:id])
  end
end
