class PostsController < ApplicationController

layout "websites"

  # GET /posts
  # GET /posts.xml
  def index
    
    if params[:topic].blank?
      @posts = Post.all
    else
      @posts = Post.where('topic = ?', params[:topic])
    end

    @topics = Post.all.collect{|i| i.topic}.uniq.compact

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])
    @post_comments = Comment.where(:post_id => params[:id], :checked => 1)
    @comment = Comment.new
    @topics = Post.all.collect{|i| i.topic}.uniq.sort

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

end