class Item < ApplicationRecord
  paginates_per 10

  # Use scope function from ./app/models/concerns
  include ScopeGenerator, PgSearch::Model
  Item.new.createScope(Item)

  # pg_search
  pg_search_scope :search_item, against: {
      name: 'A',
      series: 'B'
  }, using: {
      tsearch: { prefix: true }
  }
end
