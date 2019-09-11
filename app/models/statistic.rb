class Statistic < ApplicationRecord
  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  Statistic.new.createScope(Statistic)
end
