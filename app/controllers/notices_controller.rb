class NoticesController < ApplicationController
  skip_before_filter :authenticate_user!, :only => :create

  def create
    # params[:data] if the notice came from a GET request, raw_post if it came via POST
    @notice = App.report_error!(params[:data] || request.raw_post)
    render :xml => @notice
  end
end

