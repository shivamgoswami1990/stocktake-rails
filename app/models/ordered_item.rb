class OrderedItem < ApplicationRecord
  # Use scope function from ./app/models/concerns
  include ScopeGenerator, PgSearch::Model
  OrderedItem.new.createScope(OrderedItem)

  # pg_search
  pg_search_scope :search_ordered_item, against: {
      name_key: 'A',
      item_name: 'B',
  }, using: {
      tsearch: { prefix: true }
  }

  belongs_to :user
  belongs_to :company, optional: true
  belongs_to :customer
  belongs_to :invoice, optional: true

  # Custom JSON Attributes
  def as_json(options={})
    super.as_json(options).merge({ user: self.user, company: self.company})
  end
end
