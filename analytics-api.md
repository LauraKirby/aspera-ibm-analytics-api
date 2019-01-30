# Files Authorization & Analytics API

> View the source code on Github: [get_analytics_data](https://github.com/LauraKirby/aspera-ibm-analytics-api/tree/master/analytics-api-demo)

1. Terminal: Create files for Ruby script and dependencies.

    ```bash
    # from project root directory
    touch get_analytics_data.rb Gemfile
    ```

1. Text editor: Add dependencies to `./Gemfile`

    ```ruby
    source 'https://rubygems.org'

    gem 'jwt'
    gem 'rest-client'
    ```

1. Terminal: Install dependencies (aka Gems)

    ```bash
    # from project root directory
    bundle
    ```

1. Add references to the installed dependencies and Ruby modules

    * add the following to the top of `./get_analytics_data.rb`

    ```ruby
    require 'base64'
    require 'json'
    require 'restclient'
    require 'yaml'
    ```

1. Add hard-coded data and helper methods

    * add the following to the bottom of `./get_analytics_data.rb`

    ```ruby
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

    def get_request(url_string, bearer_token, parameters = '')
      request = RestClient::Resource.new(
        url_string + parameters,
        headers: { Authorization: bearer_token }
      )

      JSON.parse(request.get, symbolize_names: true)
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
    ```

1. Generate JWT: Specify values for the follow JWT header keys

    * add the following to the bottom of `./get_analytics_data.rb`

    ```ruby
    # specify authentication type and hashing algorithm
    request_header = {
      typ: 'JWT',
      alg: 'RS256'
    }
    ```

1. Generate JWT: Specify values for the follow JWT body keys

    * issuer ('iss'): the client ID that is generated when you register an API client.
    * subject ('sub'): the email address of the user who will use the bearer token for authentication.
    * audience ('aud'): is always the [Files API endpoint](https://api.asperafiles.com/api/v1/oauth2/token).
    * not before ('nbf'): a Unix timestamp when the bearer token becomes valid
    * expiration ('exp'): a Unix timestamp when the bearer token expires


    * add the following to the bottom of `./get_analytics_data.rb`

    ```ruby
    request_body = {
      iss: client_id,
      sub: email,
      aud: 'https://api.asperafiles.com/api/v1/oauth2/token',
      nbf: time - 3600,
      exp: time + 3600
    }
    ```

1. Generate JWT & Request Parameters: Construction

    * add the following to the bottom of `./get_analytics_data.rb`

    ```ruby
    # construct the hashed JWT
    payload = base64url_encode(request_header.to_json) + '.' + base64url_encode(request_body.to_json)
    signed = private_key.sign(OpenSSL::Digest::SHA256.new, payload)
    jwt_token = payload + '.' + base64url_encode(signed)

    payload = base64url_encode(request_header.to_json) + '.' + base64url_encode(request_body.to_json)
    signed = private_key.sign(OpenSSL::Digest::SHA256.new, payload)
    jwt_token = payload + '.' + base64url_encode(signed)
    grant_type = CGI.escape('urn:ietf:params:oauth:grant-type:jwt-bearer')
    scope = CGI.escape('admin:all')
    ```

1. Setup Files request object

    * add the following to the bottom of `./get_analytics_data.rb`

    ```ruby
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
    result = JSON.parse(client.post(parameters), symbolize_names: true)
    pretty_print(result)
    ```

1. Extract 'bearer token' from Files response and make Analytics API request

    * add the following to the bottom of `./get_analytics_data.rb`

    ```ruby
    # extract 'bearer token'
    # we know that result[:access_token] holds a 'bearer token'
    # because result[:token_type] == 'bearer'
    bearer_token = "Bearer #{result[:access_token]}"
    analytics_url = "https://api.qa.ibmaspera.com/analytics/v2/organizations/#{organization_id}/transfers"
    start_time = CGI.escape('2019-01-19T23:00:00Z')
    stop_time = CGI.escape('2019-01-26T23:00:00Z')
    limit = 3
    parameters = "?start_time=#{start_time}&stop_time=#{stop_time}&limit=#{limit}"

    # make Analytics GET request
    result = get_request(analytics_url, bearer_token, parameters)
    pretty_print(result)
    ```

1. Run script in terminal

    ```bash
    ruby get_analytics_data.rb
    ```

    * You should see the tokens printed in terminal as well as the Analytics API response.

1. View [source code on Github](https://github.com/LauraKirby/aspera-ibm-analytics-api/tree/master/analytics-api-demo)

## Additional resources

* [Files JWT Authorization](https://developer.asperasoft.com/web/files/jwt-authorization)
* [Learn more about JWT](https://tools.ietf.org/html/rfc7519)
* [Files API Example](https://developer.ibm.com/aspera/docs/aspera-api-tutorials-use-cases/building-file-sending-application-files-api/)
