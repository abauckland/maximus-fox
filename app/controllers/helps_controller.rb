class HelpsController < ApplicationController

before_filter :require_user
layout "users", :except => [:tutorial]

  def index
    @tutorials = Help.all
  end

  def tutorial

    @tutorial = Help.where('id = ?', params[:id]).first

  end

end