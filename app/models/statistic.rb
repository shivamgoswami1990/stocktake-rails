class Statistic < ApplicationRecord
  before_create :check_record_count

  after_commit :bust_statistic_cache

  def bust_statistic_cache
    Rails.cache.redis.set("statistics", self.to_json)
  end

  private
  def check_record_count
    raise "You can create only one row of this table" if Statistic.count > 0
  end
end
