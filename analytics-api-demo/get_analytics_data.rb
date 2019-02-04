require 'restclient'
require 'json'
require 'base64'
require 'byebug'

require './authentication.rb'

include Authentication
# ------ setup data for Analytics request -------
analytics_url = "https://api.qa.ibmaspera.com/analytics/v2/organizations/#{organization_id}/transfers"
puts "\n\nanalytics_url: #{analytics_url}"
start_time = CGI.escape('2019-01-19T23:00:00Z')
stop_time = CGI.escape('2019-01-26T23:00:00Z')
limit = 3
parameters = "?start_time=#{start_time}&stop_time=#{stop_time}&limit=#{limit}"
bearer_token = log_in

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
  analytics_url_two = result[:next][:href]
  # note: result[:first][:href] will always provide the url to the very first page of transfers

  request_two = RestClient::Resource.new(
    analytics_url_two,
    headers: { Authorization: bearer_token }
  )

  result_two = JSON.parse(request_two.get, symbolize_names: true)
  pretty_print(result_two)
rescue Exception => e
  puts e
end
