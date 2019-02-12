require 'restclient'
require 'json'
require './authentication.rb'
require './constants.rb'

include Authentication

# -----------------------------------
# To run this script:
# -----------------------------------

# 1) Complete step 1 "System and Application Setup".
# Excluding the addition of ORGANIZATION_ID constant in constants.rb.
# Referenced in the final step.
# https://laurakirby.github.io/aspera-ibm-analytics-api/setup.html

# 2) Complete step 2, "Install Dependencies"
# https://laurakirby.github.io/aspera-ibm-analytics-api/dependencies.html

# 3) Complete step 3, "Obtain Files Application Authentication"

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

