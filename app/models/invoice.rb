class Invoice < ApplicationRecord
  # Use scope function from ./app/models/concerns
  include ScopeGenerator, PgSearch
  pg_search_scope :search_by_item_array, :against => :item_array
  pg_search_scope :search_by_company_customer_id,
                  :associated_against => {
                      :customer => [:name, :st_address, :city, :state_name],
                      :company => [:name, :st_address, :city, :state_name]
                  }, :against => [:invoice_no_as_int]
  Invoice.new.createScope(Invoice)

  belongs_to :user
  belongs_to :customer
  belongs_to :company
  has_many :notification_objects, as: :entity
  validates :invoice_no, uniqueness: { scope: [:financial_year, :company_id] }

  counter_culture :company, column_name: proc {|model| model.invoice_status.eql?('SAVED') ? 'invoice_count' : nil},
                  column_names: {
                      ["invoices.invoice_status = ?", 1] => 'invoice_count'
                  }
  counter_culture :customer, column_name: proc {|model| model.invoice_status.eql?('SAVED') ? 'invoice_count' : nil},
                  column_names: {
                      ["invoices.invoice_status = ?", 1] => 'invoice_count'
                  }
  counter_culture :user, column_name: proc {|model| model.invoice_status.eql?('SAVED') ? 'invoice_count' : nil},
                  column_names: {
                      ["invoices.invoice_status = ?", 1] => 'invoice_count'
                  }

  # Define enum
  enum invoice_status: [:DRAFT, :SAVED]

  # Custom JSON Attributes
  def as_json(options={})
    super.as_json(options).merge({ user: self.user, company: self.company, customer: self.customer})
  end

  after_commit :bust_invoice_cache # Move this to sidekiq once activejobs are included

  private

  def bust_invoice_cache
    Rails.cache.redis.set("invoices/" + self.id.to_s, self.to_json)
  end
end
