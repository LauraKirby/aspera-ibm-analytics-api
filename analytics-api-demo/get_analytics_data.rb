require 'restclient'
require 'yaml'
require 'json'
require 'base64'

# load secrets from config file
# this file should be added to your .gitignore,
# it has been added here for purpose of demonstation
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
scope = 'admin%3Aall'
environment = yaml['environment']
organization_name = yaml['organization_name']
organization_id = yaml['organization_id']
client_id = yaml['client_id']
client_secret = yaml['client_secret']
email = yaml['useremail']

time = Time.now.to_i

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

# construct the hashed JWT
payload = base64url_encode(request_header.to_json) + '.' + base64url_encode(request_body.to_json)
signed = private_key.sign(OpenSSL::Digest::SHA256.new, payload)
jwt_token = payload + '.' + base64url_encode(signed)

# "#{environment + '.' }" should be removed below when using production environments
files_url = "https://api.#{environment + '.' }ibmaspera.com/api/v1/oauth2/#{organization_name}/token"
parameters = "assertion=#{jwt_token}&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&scope=#{scope}"

# setup Files request object
client = RestClient::Resource.new(
  files_url,
  user: client_id,
  password: client_secret,
  headers: { content_type: 'application/x-www-form-urlencoded' }
)

# make request to Files API
result = JSON.parse(client.post(parameters), symbolize_names: true)
pretty_print(result)

# extract 'bearer token'
bearer_token = "Bearer #{result[:access_token]}"

puts "\n\nbearer_token: #{bearer_token}\n\n"

# setup Analytics request object
get_analytics = RestClient::Resource.new(
  "https://api.qa.ibmaspera.com/analytics/v2/organizations/#{organization_id}/volume_usage",
  headers: { Authorization: bearer_token }
)

# make request to Analytics API
result = JSON.parse(get_analytics.get, symbolize_names: true)
pretty_print(result)
