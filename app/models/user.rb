class User < ActiveRecord::Base

  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User, PgSearch::Model

  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  User.new.createScope(User)

  # pg_search
  pg_search_scope :search_user, against: {
      first_name: 'A',
      last_name: 'B'
  }, using: {
      tsearch: { prefix: true }
  }

  has_many :invoices
  has_many :notifications, foreign_key: :notifier_id, class_name: "Notification", dependent: :nullify
  has_many :notifications, foreign_key: :actor_id, class_name: "Notification", dependent: :nullify
end
