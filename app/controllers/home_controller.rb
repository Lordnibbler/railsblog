class HomeController < ApplicationController
    def show
        @posts = Blog::Post.published.newest.limit(3)
    end
end