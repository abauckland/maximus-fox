class HelpsController < ApplicationController

before_filter :require_user
layout "users"

  def index
    @tutorials = Help.all
  end

  def tutorial

    @tutorial = Help.where('id = ?', params[:id]).first


  redirect_to @tutorial.video.to_s

  end

end