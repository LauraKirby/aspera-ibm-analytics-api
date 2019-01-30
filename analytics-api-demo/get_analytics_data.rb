require 'restclient'
require 'yaml'
require 'json'
require 'base64'

# load secrets from config.yml file
# config.yml, jwtRS256.key, jwtRS256.key.pub files
# should be included in your.gitignore,
# they have been been included in this repository for
# purpose of demonstration
yaml = YAML.load_file('config.yml')

# helper methods
def base64url_encode(str)
  Base64.encode64(str).tr('+/', '-_').gsub(/[\n=]/, '')
end

def pretty_print(result)
  pretty = JSON.pretty_generate(result)
  puts pretty
end

# Load information about the Files instance being used
private_key = OpenSSL::PKey::RSA.new(File.read('jwtRS256.key'))
environment = yaml['environment']
organization_name = yaml['organization_name']
organization_id = yaml['organization_id']
client_id = yaml['client_id']
client_secret = yaml['client_secret']
email = yaml['useremail']

time = Time.now.to_i

# ------ setup data for Files Authorization request -------
# specify authentication type and hashing algorithm
request_header = {
  typ: 'JWT',
  alg: 'RS256'
}

request_body = {
  iss: client_id,
  sub: email,
  aud: 'https://api.asperafiles.com/api/v1/oauth2/token',
  nbf: time - 3600,
  exp: time + 3600
}

# construct the hashed JWT and request parameters
payload = base64url_encode(request_header.to_json) + '.' + base64url_encode(request_body.to_json)
signed = private_key.sign(OpenSSL::Digest::SHA256.new, payload)
jwt_token = payload + '.' + base64url_encode(signed)
grant_type = CGI.escape('urn:ietf:params:oauth:grant-type:jwt-bearer')
scope = CGI.escape('admin:all')

# "#{environment + '.' }" should be removed below when using production environments
files_url = "https://api.#{environment + '.' }ibmaspera.com/api/v1/oauth2/#{organization_name}/token"
parameters = "assertion=#{jwt_token}&grant_type=#{grant_type}&scope=#{scope}"

# setup Files request object
client = RestClient::Resource.new(
  files_url,
  user: client_id,
  password: client_secret,
  headers: { content_type: 'application/x-www-form-urlencoded' }
)

# make request to Files API
begin
  puts "\n\n\nmake request to Files API\n\n\n"
  result = JSON.parse(client.post(parameters), symbolize_names: true)
  pretty_print(result)
rescue Exception => e
  puts e
end

# ------ setup data for Analytics request -------
# extract 'bearer token'
# we know that result[:access_token] holds a 'bearer token'
# because result[:token_type] == 'bearer'
bearer_token = "Bearer #{result[:access_token]}"
analytics_url = "https://api.qa.ibmaspera.com/analytics/v2/organizations/#{organization_id}/transfers"
start_time = CGI.escape('2019-01-19T23:00:00Z')
stop_time = CGI.escape('2019-01-26T23:00:00Z')
limit = 3
parameters = "?start_time=#{start_time}&stop_time=#{stop_time}&limit=#{limit}"

# get page 1 of transfers
# expect a max of 3 transfers to be returned
begin
  puts "\n\n\nGET Analytics ./transfers page 1\n\n\n"

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
  puts "\n\n\nGET Analytics ./transfers page 2\n\n\n"
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
