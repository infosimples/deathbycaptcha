module DeathByCaptcha

  # Socket client for DeathByCaptcha API.
  #
  class Client::Socket < Client

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
    def upload(options = {})
      if options[:type] && options[:type].to_i != 1
        # Socket client implementation currently supports only text captchas.
        raise DeathByCaptcha::InvalidCaptcha
      end
      response = perform('upload', captcha: options[:raw64])
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

      socket = create_socket()
      socket.puts(payload.to_json)
      response = socket.read()
      socket.close()

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

    # Create a new socket connection with DeathByCaptcha API.
    # This method is necessary because Ruby 1.9.7 doesn't support connection
    # timeout and only Ruby 2.2.0 fixes a bug with unsafe sockets threads.
    #
    # In Ruby >= 2.2.0, this could be implemented as simply as:
    # ::Socket.tcp(HOST, PORTS.sample, connect_timeout: 0)
    #
    def create_socket
      socket = ::Socket.new(::Socket::AF_INET, ::Socket::SOCK_STREAM, 0)
      sockaddr = ::Socket.sockaddr_in(PORTS.sample, self.hostname)
      begin # emulate blocking connect
        socket.connect_nonblock(sockaddr)
      rescue IO::WaitWritable
        IO.select(nil, [socket]) # wait 3-way handshake completion
        begin
          socket.connect_nonblock(sockaddr) # check connection failure
        rescue Errno::EISCONN
        end
      end
      socket
    end

    # Return a cached http client for methods that doesn't work with sockets.
    #
    def http_client
      @http_client ||= DeathByCaptcha.new(self.username, self.password, :http)
    end

  end
end
