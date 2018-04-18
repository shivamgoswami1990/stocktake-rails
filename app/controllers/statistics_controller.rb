class StatisticsController < ApplicationController

  before_action :authenticate_user!

  # GET /statistics
  def index
    @statistics = Statistic.first
    render :json => @statistics
  end
end
