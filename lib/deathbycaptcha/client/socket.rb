module DeathByCaptcha

  # Socket client for DeathByCaptcha API.
  #
  class Client::Socket < Client

    HOST  = 'api.dbcapi.me'
    PORTS = (8123..8130).to_a

    # Retrieve information from an uploaded captcha.
    #
    # @param [Integer] captcha_id Numeric ID of the captcha.
    #
    # @return [DeathByCaptcha::Captcha] The captcha object.
    #
    def captcha(captcha_id)
      response = perform('captcha', captcha: captcha_id)
      DeathByCaptcha::Captcha.new(response)
    end

    # Report incorrectly solved captcha for refund.
    #
    # @param [Integer] captcha_id Numeric ID of the captcha.
    #
    # @return [DeathByCaptcha::Captcha] The captcha object.
    #
    def report!(captcha_id)
      response = perform('report', captcha: captcha_id)
      DeathByCaptcha::Captcha.new(response)
    end

    # Retrieve your user information (which has the current credit balance)
    #
    # @return [DeathByCaptcha::User] The user object.
    #
    def user
      response = perform('user')
      DeathByCaptcha::User.new(response)
    end

    # Retrieve DeathByCaptcha server status. This method won't use a Socket
    # connection, it will use an HTTP connection.
    #
    # @return [DeathByCaptcha::ServerStatus] The server status object.
    #
    def status
      http_client.status
    end

    # Upload a captcha to DeathByCaptcha.
    #
    # This method will not return the solution. It's only useful if you want to
    # implement your own "decode" function.
    #
    # @return [DeathByCaptcha::Captcha] The captcha object (not solved yet).
    #
    def upload(raw64)
      response = perform('upload', captcha: raw64)
      DeathByCaptcha::Captcha.new(response)
    end

    private

    # Perform a Socket communication with the DeathByCaptcha API.
    #
    # @param [String] action  API method name.
    # @param [Hash]   payload Data to be exchanged in the communication.
    #
    # @return [Hash] Response from the DeathByCaptcha API.
    #
    def perform(action, payload = {})
      payload.merge!(
        cmd: action,
        version: DeathByCaptcha::API_VERSION,
        username: self.username,
        password: self.password
      )

      response = ::Socket.tcp(HOST, PORTS.sample) do |socket|
        socket.puts payload.to_json
        socket.read
      end

      begin
        response = JSON.parse(response)
      rescue
        raise DeathByCaptcha::APIResponseError.new("invalid JSON: #{response}")
      end

      if !(error = response['error'].to_s).empty?
        case error
        when 'not-logged-in', 'invalid-credentials', 'banned', 'insufficient-funds'
          raise DeathByCaptcha::APIForbidden
        when 'invalid-captcha'
          raise DeathByCaptcha::APIBadRequest
        when 'service-overload'
          raise DeathByCaptcha::APIServiceUnavailable
        else
          raise DeathByCaptcha::APIResponseError.new(error)
        end
      end

      response
    end

    # Return a cached http client for methods that doesn't work with sockets.
    #
    def http_client
      @http_client ||= DeathByCaptcha.new(self.username, self.password, :http)
    end

  end
end
