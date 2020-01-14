class Transport < ApplicationRecord
  # Use scope function from ./app/models/concerns
  include ScopeGenerator, PgSearch::Model
  Transport.new.createScope(Transport)

  validates_uniqueness_of :gst_no
  after_commit :update_transports_cache

  # pg_search
  pg_search_scope :search_transport, against: {
      name: 'A'
  }, using: {
      tsearch: { prefix: true }
  }

  private

  def update_transports_cache
    update_cache("transports", self)
  end
end
