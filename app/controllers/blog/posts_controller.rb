require 'will_paginate/array'

#
# simple controller for rendering published Blog::Post .md files
#
class Blog::PostsController < ApplicationController
  def index
    @posts = Blog::Post.all.paginate(page: params[:page], per_page: 2)
  end

  def show
    @post = Blog::Post.find_by_name(params[:id])
  end
end
