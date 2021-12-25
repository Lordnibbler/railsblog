# renders the home page
class HomeController < ApplicationController
  def index
    @posts = Blog::Post.published.newest.limit(3)
  end
end
