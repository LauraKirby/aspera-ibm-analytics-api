# Files Authorization & Analytics API

> View the source code on Github: [get_analytics_data](https://github.com/LauraKirby/aspera-ibm-analytics-api/tree/master/analytics-api-demo)

1. Terminal: Create files for Ruby script and dependencies.

    ```bash
    # from project root directory
    touch get_analytics_data.rb Gemfile
    ```

1. Text editor: Add dependencies

    * add the following to `./Gemfile`

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

1. Text editor: Add references to the installed dependencies and Ruby modules

    * add the following to the top of `./get_analytics_data.rb`

    ```ruby
    require 'base64'
    require 'json'
    require 'restclient'
    require 'yaml'
    ```

1. Text editor: Add hard-coded data and helper methods

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

1. Text editor: Generate JWT - Specify values for the follow JWT header keys

    * add the following to the bottom of `./get_analytics_data.rb`

    ```ruby
    # specify authentication type and hashing algorithm
    request_header = {
      typ: 'JWT',
      alg: 'RS256'
    }
    ```

1. Text editor: Generate JWT - Specify values for the follow JWT body keys

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

1. Text editor: Generate JWT & Request Parameters - Construction

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

1. Text editor: Setup Files request object

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

1. Text editor: Extract 'bearer token' from Files response and setup request parameters

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
    ```

1. Text editor: Get page one of `/transfers` for specified parameters

    * add the following to the bottom of `./get_analytics_data.rb`

    ```ruby
    request = RestClient::Resource.new(
      analytics_url + parameters,
      headers: { Authorization: bearer_token }
    )

    # make Analytics GET request
    # expect a max of 3 transfers to be returned, as specified by 'limit'
    result = JSON.parse(request.get, symbolize_names: true)
    pretty_print(result)
    ```

1. Text editor: Get page two of `./transfers` for specified parameters

    * add the following to the bottom of `./get_analytics_data.rb`

    ```ruby
    # link to page two of results is located at `result[:next][:href]`
    analytics_url_two = result[:next][:href]
    # note: result[:first][:href] will always provide the url to the very first page of transfers

    request_two = RestClient::Resource.new(
      analytics_url_two,
      headers: { Authorization: bearer_token }
    )

    result_two = JSON.parse(request_two.get, symbolize_names: true)
    pretty_print(result_two)
    ```

1. Terminal: Run script

    ```bash
    ruby get_analytics_data.rb
    ```

    You should see the Files and Analytics API responses printed in terminal.

    * Files response

    ```json
    {
          "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IjIwMTgtMDYtMDZUMjI6MzU6MTQrMDA6MDAifQ.eyJ1c2VyX2lkIjoiNDE1MTEiLCJzY29wZSI6ImFkbWluOmFsbCIsImV4cGlyZXNfYXQiOiIyMDE5LTAxLTMwVDIzOjE5OjU1WiIsInV1aWQiOiIzOGNlNmRkNC03ZjQyLTQ0YTgtYmFkNi03YTY1ZTNlNjZlNjIiLCJvcmdhbml6YXRpb25faWQiOiIxMzM1NSIsImV4cCI6MTU0ODg5MDM5NSwic3ViIjoibGF1cmFraXJieTI2QGdtYWlsLmNvbSIsIm5hbWUiOiJMYXVyYSBLaXJieSIsImdpdmVuX25hbWUiOiJMYXVyYSIsImZhbWlseV9uYW1lIjoiS2lyYnkiLCJpYXQiOjE1NDg4MDM5OTUsImlzcyI6Imh0dHBzOi8vYXBpLmlibWFzcGVyYS5jb20vYXBpL3YxL29hdXRoMi90b2tlbiIsImlibWlkX2lkIjoiSUJNaWQtNTAzM1RLVFYyQiIsImlkIjoiYW9jLTQxNTExIiwicmVhbG1pZCI6ImFvYy1pYm1pZCIsImlkZW50aWZpZXIiOiI0MTUxMSJ9.wggzDE8xaNgc0ucOs8Tn0sCVwpvJSTVEGmqKeVq3uR0Ru7vkM5yptbFfSfbtg6kAKTzclL_I_rdznlSet20WMo_qb0b2mQiTIuhFLKL9uECoqCXxZ0LNdBpXbt1NxcMhMXIinfWc9PmQaGY6uAyjgOpNZDMBq3EzocHJ2YFUZjrURgrWgCWmDf7xlTcvziuwJ6XrFz8zeKBXRkdeow-wkkcaBM6-Q596GrFf7frQDOAmyRr1WIKZJ6j9V-jY-mrox-Rebsc0BW8sAXKb33TyZ_NHcuQu7n-_6hZ_QARqSIpqtbBEb6fZRY9aSQ8dQ4cdCtokKDjhVe1Kkt-aP1bLAg",
          "token_type": "bearer",
          "expires_in": 86399,
          "scope": "admin:all"
    }
    ```

    * Analytics response for page 1

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


    * Analytics response for page 2

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

1. Web Browser: View [source code on Github](https://github.com/LauraKirby/aspera-ibm-analytics-api/tree/master/analytics-api-demo)

## Additional resources

* [Files JWT Authorization](https://developer.asperasoft.com/web/files/jwt-authorization)
* [Learn more about JWT](https://tools.ietf.org/html/rfc7519)
* [Files API Example](https://developer.ibm.com/aspera/docs/aspera-api-tutorials-use-cases/building-file-sending-application-files-api/)
