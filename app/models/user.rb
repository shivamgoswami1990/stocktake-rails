class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  User.new.createScope(User)

  has_many :invoices
end
