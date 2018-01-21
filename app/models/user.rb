class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  # Use scope function from ./app/models/concerns
  include ScopeGenerator
  User.new.createScope(User)

  has_attached_file :profile_image,
                    path: ':rails_root/public/profile_image/:id/:style/:basename.:extension',
                    url: '/profile_image/:id/:style/:basename.:extension',
                    styles: { thumb: '100x100>', small: '50x50' }, default_url: nil

  validates_attachment :profile_image,
                                          content_type: { content_type: ['image/jpeg', 'image/jpg', 'image/gif', 'image/png'] },
                                          size: { in: 0..10_000.kilobytes }

  has_many :invoices

  # Custom JSON Attributes
  def as_json(options = {})
    super.as_json(options).merge(profile_image_url: profile_image_file_name.eql?(nil) ? '' : profile_image)
  end
end
