class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken, Pagy::Backend, HasScopeGenerator, SendgridEmail
  before_action :configure_permitted_parameters, if: :devise_controller?
  require "json"

  def write_to_cache(key, value)
    Rails.cache.write(key, value)
  end

  def read_from_cache(key)
    return Rails.cache.read(key)
  end

  protected

  def configure_permitted_parameters

    # Add the user fields for registration using devise_token_auth
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :address, :phone_no,
                                                       :email])

  end
end
