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
    raise ActiveRecord::RecordNotFound unless permalink_date_matches?
  end

  private

  def permalink_date_matches?
    return true unless params[:year]

    requested_date = params.values_at(:year, :month, :day).join('/')
    requested_date == @post.created_at.strftime('%Y/%m/%d')
  end
end
