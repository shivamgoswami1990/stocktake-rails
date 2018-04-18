class Statistic < ApplicationRecord
  before_create :check_record_count

  private
  def check_record_count
    raise "You can create only one row of this table" if Statistic.count > 0
  end
end
