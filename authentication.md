# Obtain Files Application Authentication

> View the source code on Github: [analytics_api_demo](https://github.com/LauraKirby/aspera-ibm-analytics-api/tree/master/analytics-api-demo)

1. To add references to the installed dependencies and Ruby modules, add the following to `./authentication.rb`. This code must remain at the top of the file.

    ```ruby
    require 'restclient'
    require 'json'
    require 'base64'
    require './constants.rb'
    ```

1. To declare the Authentication module, add this code to the bottom of `./authentication.rb`:
    ```ruby
    module Authentication
      # helper methods

      # generate JWT

      # log in user

    end
    ```

1. To include helper methods, for printing and encoding data, add this code just below `# helper methods`, which is in the `Authentication` module, within `./authentication.rb`:

    ```ruby
    # helper methods
    def base64url_encode(str)
      Base64.encode64(str).tr('+/', '-_').gsub(/[\n=]/, '')
    end

    def pretty_print(result)
      pretty = JSON.pretty_generate(result)
      puts pretty
    end
    ```

1. To specify values for the JSON web token (JWT) header keys, add this code just below `# generate JWT`, which is in the `Authentication` module, within `./authentication.rb`:

    ```ruby
    # generate JWT
    def generate_auth_credentials
      private_key = OpenSSL::PKey::RSA.new(File.read('jwtRS256.key'))
      time = Time.now.to_i

      # specify authentication type and hashing algorithm
      jwt_header = {
        typ: 'JWT',
        alg: 'RS256'
      }

      # specify issuer, subject, audience, not before and expiration
      jwt_body = {
        iss: CLIENT_ID,
        sub: USER_EMAIL,
        aud: 'https://api.asperafiles.com/api/v1/oauth2/token',
        nbf: time - 3600,
        exp: time + 3600
      }

      # construct the hashed JWT and Files API request parameters
      payload = base64url_encode(jwt_header.to_json) + '.' + base64url_encode(jwt_body.to_json)
      signed = private_key.sign(OpenSSL::Digest::SHA256.new, payload)
      jwt_token = payload + '.' + base64url_encode(signed)
      grant_type = CGI.escape('urn:ietf:params:oauth:grant-type:jwt-bearer')
      scope = CGI.escape('admin:all')

      { token: jwt_token, grant_type: grant_type, scope: scope }
    end
    ```

    * issuer ('iss'): Client ID that is generated when you register an API client.
    * subject ('sub'): Email address of the user who will use the bearer token for authentication.
    * audience ('aud'): Always https://api.asperafiles.com/api/v1/oauth2/token.
    * not before ('nbf'): Unix timestamp for when the bearer token becomes valid
    * expiration ('exp'): Unix timestamp for when the bearer token expires



1. To set up the authentication request to the Files API, add this code just below `# log in user`, which is in the `Authentication` module, within `./authentication.rb`:

    ```ruby
    # log in user
    def log_in
      credentials = generate_auth_credentials
      files_url = "https://api.ibmaspera.com/api/v1/oauth2/#{ORGANIZATION_SUBDOMAIN}/token"
      parameters = "assertion=#{credentials[:token]}&grant_type=#{credentials[:grant_type]}&scope=#{credentials[:scope]}"

      # setup Files request object
      client = RestClient::Resource.new(
        files_url,
        user: CLIENT_ID,
        password: CLIENT_SECRET,
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

      # extract and return 'bearer token'
      return "Bearer #{result[:access_token]}" if result
    end
    ```

1. To confirm that your setup is successful, add the following method call to the very bottom of `authentication.rb` (after the final `end`) and then run the Ruby script:

    * Add method call

    ```ruby
    include Authentication
    log_in
    ```

    * Run the Ruby script in Terminal

    ```bash
    ruby authentication.rb
    ```

    The Files API response should print in terminal.

    * Files response

    ```json
    {
          "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IjIwMTgtMDYtMDZUMjI6MzU6MTQrMDA6MDAifQ.eyJ1c2VyX2lkIjoiNDE1MTEiLCJzY29wZSI6ImFkbWluOmFsbCIsImV4cGlyZXNfYXQiOiIyMDE5LTAxLTMwVDIzOjE5OjU1WiIsInV1aWQiOiIzOGNlNmRkNC03ZjQyLTQ0YTgtYmFkNi03YTY1ZTNlNjZlNjIiLCJvcmdhbml6YXRpb25faWQiOiIxMzM1NSIsImV4cCI6MTU0ODg5MDM5NSwic3ViIjoibGF1cmFraXJieTI2QGdtYWlsLmNvbSIsIm5hbWUiOiJMYXVyYSBLaXJieSIsImdpdmVuX25hbWUiOiJMYXVyYSIsImZhbWlseV9uYW1lIjoiS2lyYnkiLCJpYXQiOjE1NDg4MDM5OTUsImlzcyI6Imh0dHBzOi8vYXBpLmlibWFzcGVyYS5jb20vYXBpL3YxL29hdXRoMi90b2tlbiIsImlibWlkX2lkIjoiSUJNaWQtNTAzM1RLVFYyQiIsImlkIjoiYW9jLTQxNTExIiwicmVhbG1pZCI6ImFvYy1pYm1pZCIsImlkZW50aWZpZXIiOiI0MTUxMSJ9.wggzDE8xaNgc0ucOs8Tn0sCVwpvJSTVEGmqKeVq3uR0Ru7vkM5yptbFfSfbtg6kAKTzclL_I_rdznlSet20WMo_qb0b2mQiTIuhFLKL9uECoqCXxZ0LNdBpXbt1NxcMhMXIinfWc9PmQaGY6uAyjgOpNZDMBq3EzocHJ2YFUZjrURgrWgCWmDf7xlTcvziuwJ6XrFz8zeKBXRkdeow-wkkcaBM6-Q596GrFf7frQDOAmyRr1WIKZJ6j9V-jY-mrox-Rebsc0BW8sAXKb33TyZ_NHcuQu7n-_6hZ_QARqSIpqtbBEb6fZRY9aSQ8dQ4cdCtokKDjhVe1Kkt-aP1bLAg",
          "token_type": "bearer",
          "expires_in": 86399,
          "scope": "admin:all"
    }
    ```

1. Once you have confirmed that the `log_in` method is working, remove the following lines, shown below (or comment them out by placing a `#` in front of them):

    ```ruby
    # include Authentication
    # log_in
    ```
