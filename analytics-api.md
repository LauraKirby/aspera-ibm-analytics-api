
# Files Authorization & Analytics API

1. Terminal:

  ```bash
  touch get_analytics_data.rb Gemfile
  ```

1. Copy and paste the following into `./Gemfile`:

  ```ruby
  source 'https://rubygems.org'

  gem 'jwt'
  gem 'rest-client'
  gem 'byebug'
  ```

1. Install Gems, from terminal

  ```bash
  # from project root directory
  bundle
  ```

1. Add the following to `./get_analytics_data.rb`

  ```ruby
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
  ```


```ruby
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
```

## Create a Files JSON Web Token

## Specify values for the follow JWT header keys

```ruby
# specify authentication type and hashing algorithm
request_header = {
  typ: 'JWT',
  alg: 'RS256'
}
```

## Specify values for the follow JWT body keys

* issuer ('iss'): the client ID that is generated when you register an API client.
* subject ('sub'): the email address of the user who will use the bearer token for authentication.
* audience ('aud'): is always the [Files API endpoint](https://api.asperafiles.com/api/v1/oauth2/token).
* not before ('nbf'): a Unix timestamp when the bearer token becomes valid
* expiration ('exp'): a Unix timestamp when the bearer token expires

request_body = {
  iss: client_id,
  sub: email,
  aud: 'https://api.asperafiles.com/api/v1/oauth2/token',
  nbf: time - 3600,
  exp: time + 3600
}


# Construct the JWT

payload = base64url_encode(request_header.to_json) + '.' + base64url_encode(request_body.to_json)

puts "payload: #{payload}"

signed = private_key.sign(OpenSSL::Digest::SHA256.new, payload)

token = payload + '.' + base64url_encode(signed)

str = "assertion=#{token}&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&scope=#{scope}"

env1 = env + '.' unless env == 'prod'
client = RestClient::Resource.new(
  "https://api.#{env1}ibmaspera.com/api/v1/oauth2/#{org}/token",
  user: client_id,
  password: client_secret,
  headers: { content_type: 'application/x-www-form-urlencoded' }
)


result = JSON.parse(client.post(str), symbolize_names: true)
pretty_print(result)

# ensure the value for result[:access_type] === 'bearer'
bearer_token = "Bearer #{result[:access_token]}"

puts "\n\nbearer_token: #{bearer_token}\n\n"

get_analytics = RestClient::Resource.new(
  "https://api.qa.ibmaspera.com/analytics/v2/organizations/#{org_id}/volume_usage",
  headers: { Authorization: bearer_token }
)

result = JSON.parse(get_analytics.get, symbolize_names: true)
pretty_print(result)


## Additional resources:

* [Files JWT Authorization](https://developer.asperasoft.com/web/files/jwt-authorization)
* [Learn more about JWT](https://tools.ietf.org/html/rfc7519)
* [Files API Example](https://developer.ibm.com/aspera/docs/aspera-api-tutorials-use-cases/building-file-sending-application-files-api/)
