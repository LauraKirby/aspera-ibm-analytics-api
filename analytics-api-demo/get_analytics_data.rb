# --------------------------------------
# Step 1: include dependencies
# --------------------------------------
require 'restclient'
require 'json'
require 'base64'
require './authentication.rb'
require './constants.rb'

include Authentication

# --------------------------------------
# Step 2: get authorization
# --------------------------------------
# use Authentication module to obtain bearer token
@bearer_token = log_in

# --------------------------------------
# Step 3: get page 1 of transfers
# --------------------------------------

def generate_request_url
  # analytics base url
  analytics_url = "https://api.ibmaspera.com/analytics/v2/organizations/#{ORGANIZATION_ID}/"
  # resource within analytics application
  analytics_resource = 'transfers'
  # query parameters
  start_time = CGI.escape('2019-01-19T23:00:00Z')
  stop_time = CGI.escape('2019-01-26T23:00:00Z')
  limit = 3
  parameters = "?start_time=#{start_time}&stop_time=#{stop_time}&limit=#{limit}"
  # print what the request url will look like
  puts "\n\nanalytics_url: #{analytics_url + analytics_resource + parameters}"
  analytics_url + analytics_resource + parameters
end

# given our query parameter `limit=3`,
# expect page one to have a max of 3 transfers returned.
begin
  puts "\n\nGET Analytics ./transfers page 1\n\n"
  request = RestClient::Resource.new(
    generate_request_url,
    headers: { Authorization: @bearer_token }
  )

  result = JSON.parse(request.get, symbolize_names: true)
  pretty_print(result)
rescue Exception => e
  puts e
end

# --------------------------------------
# Step 4: get page 2 of transfers
# --------------------------------------

# given our query parameter `limit=3`,
# expect page two to have a max of 3 transfers returned.
begin
  puts "\n\nGET Analytics ./transfers page 2\n\n"
  # link to page two of results is located at `result[:next][:href]`
  if result
    # any query parameters from initial request will be automatically appended here.
    # note: result[:first][:href] will always provide the url to the very first page of transfers.
    analytics_url_two = result[:next][:href]

    # print what the url will look like for page two of transfers
    puts "page two url: #{analytics_url_two}"

    request_two = RestClient::Resource.new(
      analytics_url_two,
      headers: { Authorization: @bearer_token }
    )

    result_two = JSON.parse(request_two.get, symbolize_names: true)
    pretty_print(result_two)
  else
    puts "There was an error in your initial Activity request or result[:next][:href] doesn't exist on this endpoint"
  end
rescue Exception => e
  puts e
end
