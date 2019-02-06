require 'restclient'
require 'json'
require 'base64'
require 'byebug'
require './authentication.rb'
require './constants.rb'

include Authentication
# ------ setup data for Analytics request -------
analytics_url = "https://api.qa.ibmaspera.com/analytics/v2/organizations/#{ORGANIZATION_ID}/transfers"
start_time = CGI.escape('2019-01-19T23:00:00Z')
stop_time = CGI.escape('2019-01-26T23:00:00Z')
limit = 3
parameters = "?start_time=#{start_time}&stop_time=#{stop_time}&limit=#{limit}"
bearer_token = log_in
puts "\n\nanalytics_url: #{analytics_url + parameters}"

# get page 1 of transfers
# expect a max of 3 transfers to be returned
begin
  puts "\n\nGET Analytics ./transfers page 1\n\n"
  request = RestClient::Resource.new(
    analytics_url + parameters,
    headers: { Authorization: bearer_token }
  )

  result = JSON.parse(request.get, symbolize_names: true)
  pretty_print(result)
rescue Exception => e
  puts e
end

# get page 2 of transfers
begin
  puts "\n\nGET Analytics ./transfers page 2\n\n"
  # link to page two of results is located at `result[:next][:href]`
  if result
    analytics_url_two = result[:next][:href]
    # note: result[:first][:href] will always provide the url to the very first page of transfers

    request_two = RestClient::Resource.new(
      analytics_url_two,
      headers: { Authorization: bearer_token }
    )

    result_two = JSON.parse(request_two.get, symbolize_names: true)
    pretty_print(result_two)
  else
    puts "There was an error in your initial Activity request or result[:next][:href] doesn't exist on this endpoint"
  end
rescue Exception => e
  puts e
end
