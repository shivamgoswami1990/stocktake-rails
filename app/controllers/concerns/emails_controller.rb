class EmailsController < ApplicationController
  #//////////////////////////////////////////// REST API //////////////////////////////////////////////////////////////
  # POST /send_email_for_customer_site
  def send_email_for_customer_site
    params.permit([:name, :email, :message]).to_unsafe_hash
    response_code = SendgridEmail.send_contact_email(params['name'], params['email'], params['message'])
    render :json => {
      "response_code": response_code
    }
  end
end
