class Statistic < ApplicationRecord
  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Statistic.new.createScope(Statistic)

  after_commit :update_statistics_cache

  private

  def update_statistics_cache
    update_cache("statistics", self)
  end
end
