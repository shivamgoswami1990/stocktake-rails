class StatisticsController < ApplicationController

  before_action :authenticate_user!

  # GET /statistics
  def index
    cached_statistics = Rails.cache.redis.get("statistics")
    if cached_statistics
      @statistics = cached_statistics

    else
      @statistics = Statistic.first
      Rails.cache.redis.set("statistics", @statistics.to_json)
    end

    render :json => @statistics
  end
end
