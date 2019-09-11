class StatisticCalculationJob < ApplicationJob
  queue_as :default

  def perform(financial_year, *args)
    stats_controller = StatisticsController.new
    stats_controller.stats_for_financial_year(financial_year)
  end
end
