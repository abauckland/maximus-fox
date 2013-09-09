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
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(params[:comment])
      
    respond_to do |format|
      if @comment.save
        format.html { 
          flash[:notice] = 'Thank you for your comment. All comments are checked for spam, once this check has been completed your comment will be published.' 
          redirect_to post_path(params[:post_id])
          }
       # format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
   end
end
