class CommentsController < ApplicationController

  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end



  # POST /posts
  # POST /posts.xml
  def create
    #@post = Post.where(:id => params[:post_id]).first
    @comment = Comment.create(params[:comment])
    respond_to do |format|
      if @comment.save
        format.html { redirect_to(:controller => "posts", :action => "show", :id => params[:comment][:post_id])}
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
   end
end
