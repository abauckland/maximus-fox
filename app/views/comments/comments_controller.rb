class CommentsController < ApplicationController

  # POST /posts
  # POST /posts.xml
  def create
  
    @post = Post.where(params[:post_id]).first
    @comment = @post.comments.build(params[:comment])
    @comment.save
 
    redirect_to @post
  end

end