require 'restclient'
require 'json'
require './authentication.rb'
require './constants.rb'

include Authentication

# Steps 2 and 3 from the home page must be completed before
# running this script

# ------ get organization details -------
files_url = 'https://api.ibmaspera.com/api/v1/organization'
bearer_token = log_in

begin
  # get information regarding your organization (ie organization name and id)
  puts "\n\nGET Files /organization \n\n"
  request = RestClient::Resource.new(
    files_url,
    headers: { Authorization: bearer_token }
  )

  result = JSON.parse(request.get, symbolize_names: true)
  puts "organization_name = #{result[:subdomain_name]}\norganization_id = #{result[:id]}"
rescue Exception => e
  puts e
end
