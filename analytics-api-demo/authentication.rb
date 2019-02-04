# Note: config.yml, jwtRS256.key, jwtRS256.key.pub files
# should be included in your.gitignore,
# they have been been included in this repository for
# purpose of demonstration

require 'restclient'
require 'yaml'
require 'json'
require 'base64'

# authorize Files API calls
module Authentication
  # Load information about the Files instance being used
  @@yaml = YAML.load_file('config.yml')

  # helper methods
  def base64url_encode(str)
    Base64.encode64(str).tr('+/', '-_').gsub(/[\n=]/, '')
  end

  def pretty_print(result)
    pretty = JSON.pretty_generate(result)
    puts pretty
  end

  def organization_id
    @@yaml['organization_id']
  end

  def generate_auth_credentials
    private_key = OpenSSL::PKey::RSA.new(File.read('jwtRS256.key'))
    time = Time.now.to_i

    # ------ setup data for Files Authorization request -------
    # specify authentication type and hashing algorithm
    request_header = {
      typ: 'JWT',
      alg: 'RS256'
    }

    request_body = {
      iss: @@yaml['client_id'],
      sub: @@yaml['useremail'],
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

    { token: jwt_token, grant_type: grant_type, scope: scope }
  end

  def log_in
    credentials = generate_auth_credentials
    # "#{environment + '.' }" should be removed below when using production environments
    files_url = "https://api.#{@@yaml['environment'] + '.' }ibmaspera.com/api/v1/oauth2/#{@@yaml['organization_name']}/token"
    parameters = "assertion=#{credentials[:token]}&grant_type=#{credentials[:grant_type]}&scope=#{credentials[:scope]}"

    # setup Files request object
    client = RestClient::Resource.new(
      files_url,
      user: @@yaml['client_id'],
      password: @@yaml['client_secret'],
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
    "Bearer #{result[:access_token]}"
  end
end
