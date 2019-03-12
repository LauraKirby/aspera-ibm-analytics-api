require 'restclient'
require 'json'
require './authentication.rb'
require './constants.rb'

include Authentication

# ---------------------------------------------------
# To run this script first complete the following:
# ---------------------------------------------------

# 1) "Configuring Your Local System and Aspera on Cloud".
# Excluding the addition of ORGANIZATION_ID constant in constants.rb,
# which is referenced in the final step.
# https://developer.ibm.com/aspera/docs/tutorial-aspera-on-cloud-activity-api/configure-your-local-system-and-aspera-on-cloud/

# 2) "Installing Dependencies for the Activity API"
# https://developer.ibm.com/aspera/docs/tutorial-aspera-on-cloud-activity-api/install-dependencies-for-the-activity-api/

# 3) "Setting up Authentication for the Activity API"
# https://developer.ibm.com/aspera/docs/tutorial-aspera-on-cloud-activity-api/authentication-for-the-activity-api/

# 4) Run `ruby get_organization.rb` from terminal.

# ------ get organization details -------
files_url = 'https://api.ibmaspera.com/api/v1/organization'
bearer_token = log_in

begin
  # get information regarding your organization (ie organization subdomain and id)
  puts "\n\nGET Files /organization \n\n"
  request = RestClient::Resource.new(
    files_url,
    headers: { Authorization: bearer_token }
  )

  result = JSON.parse(request.get, symbolize_names: true)
  puts "ORGANIZATION_SUBDOMAIN = #{result[:subdomain_name]}\n ORGANIZATION_ID = #{result[:id]}"
rescue Exception => e
  puts e
end
