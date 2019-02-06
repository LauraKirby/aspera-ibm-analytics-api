# Obtain Files API Authentication & Make a Test Request to the Analytics API

> View the source code on Github: [get_analytics_data](https://github.com/LauraKirby/aspera-ibm-analytics-api/tree/master/analytics-api-demo)

We will set up the dependencies, make a request to the Files API to obtain authentication, and make authorized requests to the Analytics API. Note that we use the Files API to configure the Aspera on Cloud platform, which includes the Activity application.

There are three main procedures:

  > I. Install Dependencies

  > II. Obtain Bearer Token

  > Make Analytics API Request

## I. Install Dependencies

1. To specify dependencies that should be installed, add the following to `Gemfile`.

    ```ruby
    source 'https://rubygems.org'

    gem 'jwt'
    gem 'rest-client'
    ```

1. To install dependencies (Ruby gems), run the following in terminal:

    ```bash
    # from project root directory
    bundle
    ```

## II. Obtain Bearer Token

1. To add references to the installed dependencies and Ruby modules, add the following to `./authentication.rb`. This code must remain at the top of the file.

    ```ruby
    require 'restclient'
    require 'json'
    require 'base64'
    require './constants.rb'
    ```

1. To include helper methods, for printing and encoding data, add this code to the bottom of `./authentication.rb`:

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

1. To specify values for the JSON web token (JWT) header keys, add this code to the bottom of `./authentication.rb`:

    ```ruby
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



1. To set up the authentication request to the Files API, add the following code to the bottom of `./authentication.rb`:

    ```ruby
    def log_in
      credentials = generate_auth_credentials
      # "#{ENVIRONMENT}" should be removed below when using production environments
      files_url = "https://api.#{ENVIRONMENT}ibmaspera.com/api/v1/oauth2/#{ORGANIZATION_NAME}/token"
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

1. To confirm that your setup is successful, run the Ruby script:

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

## III. Make Analytics API Request

1. To include required dependencies, add the following code to the bottom of `./get_analytics_data.rb`.

    ```ruby
    # --------------------------------------
    # Step 1: include dependencies
    # --------------------------------------
    require 'restclient'
    require 'json'
    require 'base64'
    require './authentication.rb'
    require './constants.rb'

    include Authentication
    ```

1. To extract the bearer token, call `log_in` from the `Authentication` module. Add the following code to the bottom of `./get_analytics_data.rb`.

   Note that the bearer token is the value of `access_token` in the Files API response.

    ```ruby
    # --------------------------------------
    # Step 2: get authorization
    # --------------------------------------
    # use Authentication module to obtain bearer token
    @bearer_token = log_in
    ```

1. To get the first page of `/transfers` for the request, add the following to the bottom of `./get_analytics_data.rb`:

    ```ruby
    # --------------------------------------
    # Step 3: get page 1 of transfers
    # --------------------------------------

    def generate_request_url
      # analytics base url
      analytics_url = "https://api.qa.ibmaspera.com/analytics/v2/organizations/#{ORGANIZATION_ID}/"
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
    ```

1. To get the second page of `./transfers` for the request, add the following to the bottom of `./get_analytics_data.rb`:

    ```ruby
    # --------------------------------------
    # Step 3: get page 2 of transfers
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
    ```

1. Now you're ready to make Activity API GET requests! To confirm that everything is working, run the Ruby script:

    ```bash
    ruby get_analytics_data.rb
    ```

   The response should print in terminal.

    * Activity response for page 1

    ```json
    {
          "organization_id": 13355,
          "start_time": "2019-01-19T23:00:00.000000000Z",
          "stop_time": "2019-01-26T23:00:00.000000000Z",
          "total_transfers": 5386,
          "transfers": [
                {
                  "client_ip_address": "67.188.183.248",
                  "direction": "receive",
                  "error_code": 0,
                  "error_message": "",
                  "expected_bytes": 5242880,
                  "file_count": 5,
                  "file_id": 1133,
                  "content": "1m1",
                  "folder_count": 0,
                  "num_source_paths": 5,
                  "package_id": "non_package",
                  "peer_error_code": 0,
                  "peer_error_message": "",
                  "server_ip_address": "169.55.186.92",
                  "session_start_time": "2019-01-20T06:04:54.238000000Z",
                  "session_stop_time": "2019-01-20T06:10:43.467000000Z",
                  "status": "completed",
                  "throughput": 3019061.0,
                  "transferred_bytes": 5242880,
                  "updated_at": "2019-01-20T06:10:43.467000000Z",
                  "uuid": "86925705-b504-4460-b5fc-1223d1a1e1c9"
                },
                {
                  "client_ip_address": "67.188.183.248",
                  "direction": "receive",
                  "error_code": 0,
                  "error_message": "",
                  "expected_bytes": 26214400,
                  "file_count": 25,
                  "file_id": 660041,
                  "content": "Package with 25 files",
                  "folder_count": 0,
                  "num_source_paths": 25,
                  "package_id": "BOn5y63kvw",
                  "peer_error_code": 0,
                  "peer_error_message": "",
                  "server_ip_address": "169.55.186.92",
                  "session_start_time": "2019-01-26T16:28:16.045000000Z",
                  "session_stop_time": "2019-01-26T16:31:53.718000000Z",
                  "status": "completed",
                  "throughput": 953458.0,
                  "transferred_bytes": 26214400,
                  "updated_at": "2019-01-26T16:31:53.390000000Z",
                  "uuid": "555c5b96-24c6-407f-996d-b0150f95615f"
                },
                {
                  "client_ip_address": "209.206.68.131",
                  "direction": "receive",
                  "error_code": 0,
                  "error_message": "",
                  "expected_bytes": 1048576000,
                  "file_count": 4,
                  "file_id": 660007,
                  "content": "weird",
                  "folder_count": 0,
                  "num_source_paths": 4,
                  "package_id": "BOn3HOtrxg",
                  "peer_error_code": 0,
                  "peer_error_message": "",
                  "server_ip_address": "169.55.186.92",
                  "session_start_time": "2019-01-26T07:15:52.522000000Z",
                  "session_stop_time": "2019-01-26T07:18:26.837000000Z",
                  "status": "completed",
                  "throughput": 75279695.0,
                  "transferred_bytes": 1048576000,
                  "updated_at": "2019-01-26T07:18:26.528000000Z",
                  "uuid": "5b49ced9-b516-4a9b-b565-a3a92520dfb1"
                }
          ],
          "first": {
            "href": "https://api.qa.ibmaspera.com/analytics/v2/organizations/13355/transfers"
          },
          "next": {
            "href": "https://api.qa.ibmaspera.com/analytics/v2/organizations/13355/transfers?start_time=2019-01-19T23:00:00Z&stop_time=2019-01-26T23:00:00Z&limit=3&next=16q0q4q0q0q52q43q0q0q6q52q95q50q48q49q57q0q35q0q8q21q125q84q173q216q110q192q184q16q91q73q206q217q181q22q74q155q181q101q163q169q37q32q223q177q7q114q101q99q101q105q118q101q240q127q255q255q249q240q127q255q255q253"
          }
    }
    ```


    * Activity response for page 2

    ```json
    {
          "organization_id": 13355,
          "start_time": "2019-01-19T23:00:00.000000000Z",
          "stop_time": "2019-01-26T23:00:00.000000000Z",
          "total_transfers": 5386,
          "transfers": [
                {
                  "client_ip_address": "67.188.183.248",
                  "direction": "receive",
                  "error_code": 0,
                  "error_message": "",
                  "expected_bytes": 5242880,
                  "file_count": 5,
                  "file_id": 1133,
                  "content": "1m1",
                  "folder_count": 0,
                  "num_source_paths": 5,
                  "package_id": "non_package",
                  "peer_error_code": 0,
                  "peer_error_message": "",
                  "server_ip_address": "169.55.186.92",
                  "session_start_time": "2019-01-20T06:04:54.238000000Z",
                  "session_stop_time": "2019-01-20T06:10:43.467000000Z",
                  "status": "completed",
                  "throughput": 3019061.0,
                  "transferred_bytes": 5242880,
                  "updated_at": "2019-01-20T06:10:43.467000000Z",
                  "uuid": "86925705-b504-4460-b5fc-1223d1a1e1c9"
                },
                {
                  "client_ip_address": "67.188.183.248",
                  "direction": "receive",
                  "error_code": 0,
                  "error_message": "",
                  "expected_bytes": 26214400,
                  "file_count": 25,
                  "file_id": 660041,
                  "content": "Package with 25 files",
                  "folder_count": 0,
                  "num_source_paths": 25,
                  "package_id": "BOn5y63kvw",
                  "peer_error_code": 0,
                  "peer_error_message": "",
                  "server_ip_address": "169.55.186.92",
                  "session_start_time": "2019-01-26T16:28:16.045000000Z",
                  "session_stop_time": "2019-01-26T16:31:53.718000000Z",
                  "status": "completed",
                  "throughput": 953458.0,
                  "transferred_bytes": 26214400,
                  "updated_at": "2019-01-26T16:31:53.390000000Z",
                  "uuid": "555c5b96-24c6-407f-996d-b0150f95615f"
                },
                {
                  "client_ip_address": "209.206.68.131",
                  "direction": "receive",
                  "error_code": 0,
                  "error_message": "",
                  "expected_bytes": 1048576000,
                  "file_count": 4,
                  "file_id": 660007,
                  "content": "weird",
                  "folder_count": 0,
                  "num_source_paths": 4,
                  "package_id": "BOn3HOtrxg",
                  "peer_error_code": 0,
                  "peer_error_message": "",
                  "server_ip_address": "169.55.186.92",
                  "session_start_time": "2019-01-26T07:15:52.522000000Z",
                  "session_stop_time": "2019-01-26T07:18:26.837000000Z",
                  "status": "completed",
                  "throughput": 75279695.0,
                  "transferred_bytes": 1048576000,
                  "updated_at": "2019-01-26T07:18:26.528000000Z",
                  "uuid": "5b49ced9-b516-4a9b-b565-a3a92520dfb1"
                }
          ],
          "first": {
            "href": "https://api.qa.ibmaspera.com/analytics/v2/organizations/13355/transfers"
          },
          "next": {
            "href": "https://api.qa.ibmaspera.com/analytics/v2/organizations/13355/transfers?start_time=2019-01-19T23:00:00Z&stop_time=2019-01-26T23:00:00Z&limit=3&next=16q0q4q0q0q52q43q0q0q6q52q95q50q48q49q57q0q35q0q8q21q125q84q173q216q110q192q184q16q91q73q206q217q181q22q74q155q181q101q163q169q37q32q223q177q7q114q101q99q101q105q118q101q240q127q255q255q249q240q127q255q255q253"
          }
    }
    ```

1. View [source code on Github](https://github.com/LauraKirby/aspera-ibm-analytics-api/tree/master/analytics-api-demo)

## Additional resources

* [Files JWT Authorization](https://developer.asperasoft.com/web/files/jwt-authorization)
* [Learn more about JWT](https://tools.ietf.org/html/rfc7519)
* [Files API Example](https://developer.ibm.com/aspera/docs/aspera-api-tutorials-use-cases/building-file-sending-application-files-api/)
