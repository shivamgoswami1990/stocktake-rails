module SendgridEmail
    include SendGrid
    def send_contact_email(name, category, email, message)
        require 'sendgrid-ruby'

        data = {
          "personalizations": [
            {
              "to": [
                {
                  "email": "info@jkaromatics.com"
                }
              ],
              "dynamic_template_data": {
                "name": name,
                "category": category,
                "email": email,
                "message": message
              }
            }
          ],
          "from": {
            "email": "info@jkaromatics.com",
            "name": "JK Aromatics and Perfumers"
          },
          "template_id": "d-83915bd672e2481ca40d8af9c4df0aec"
        }
        sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
        begin
          response = sg.client.mail._("send").post(request_body: data)
        rescue Exception => e
          puts e.message
        end
        return response.status_code
      end

      module_function :send_contact_email
end