class HelpsController < ApplicationController

before_filter :require_user
layout "projects", :except => [:tutorial]

  def show
    @current_project = Project.where('id = ? AND company_id =?', params[:id], current_user.company_id).first
    
    if @current_project.blank?
      redirect_to log_out_path
    end
    @tutorials = Help.all
  end

  def tutorial

    @tutorial = Help.where('id = ?', params[:id]).first

  end

end