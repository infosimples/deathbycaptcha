module DeathByCaptcha

  # HTTP client for DeathByCaptcha API.
  #
  class Client::HTTP < Client
    # Retrieve information from an uploaded captcha.
    #
    # @param [Integer] captcha_id Numeric ID of the captcha.
    #
    # @return [DeathByCaptcha::Captcha] The captcha object.
    #
    def captcha(captcha_id)
      response = perform("captcha/#{captcha_id}")
      DeathByCaptcha::Captcha.new(response)
    end

    # Report incorrectly solved captcha for refund.
    #
    # @param [Integer] captcha_id Numeric ID of the captcha.
    #
    # @return [DeathByCaptcha::Captcha] The captcha object.
    #
    def report!(captcha_id)
      response = perform("captcha/#{captcha_id}/report", :post)
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

    # Retrieve DeathByCaptcha server status.
    #
    # @return [DeathByCaptcha::ServerStatus] The server status object.
    #
    def status
      response = perform('status')
      DeathByCaptcha::ServerStatus.new(response)
    end

    # Upload a captcha to DeathByCaptcha.
    #
    # This method will not return the solution. It's only useful if you want to
    # implement your own "decode" function.
    #
    # @return [DeathByCaptcha::Captcha] The captcha object (not solved yet).
    #
    def upload(options = {})
      payload = {}
      payload[:captchafile] = "base64:#{options[:raw64]}"
      payload[:type] = options[:type] if options[:type].to_i > 0

      if options[:type].to_i == 3
        banner64 = load_captcha(options[:banner])
        raise DeathByCaptcha::InvalidCaptcha if banner64.to_s.empty?

        payload[:banner] = "base64:#{banner64}"
        payload[:banner_text] = options[:banner_text].to_s
      end

      response = perform('captcha', :post_multipart, payload)
      DeathByCaptcha::Captcha.new(response)
    end

    private

    # Perform an HTTP request to the DeathByCaptcha API.
    #
    # @param [String] action  API method name.
    # @param [Symbol] method  HTTP method (:get, :post, :post_multipart).
    # @param [Hash]   payload Data to be sent through the HTTP request.
    #
    # @return [Hash] Response from the DeathByCaptcha API.
    #
    def perform(action, method = :get, payload = {})
      payload.merge!(username: self.username, password: self.password)

      headers = { 'User-Agent' => DeathByCaptcha::API_VERSION }

      if method == :post
        uri = URI("http://#{self.hostname}/api/#{action}")
        req = Net::HTTP::Post.new(uri.request_uri, headers)
        req.set_form_data(payload)

      elsif method == :post_multipart
        uri = URI("http://#{self.hostname}/api/#{action}")
        req = Net::HTTP::Post.new(uri.request_uri, headers)
        boundary, body = prepare_multipart_data(payload)
        req.content_type = "multipart/form-data; boundary=#{boundary}"
        req.body = body
      else
        uri = URI("http://#{self.hostname}/api/#{action}?#{URI.encode_www_form(payload)}")
        req = Net::HTTP::Get.new(uri.request_uri, headers)
      end

      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end

      case res
      when Net::HTTPSuccess, Net::HTTPSeeOther
        Hash[URI.decode_www_form(res.body)]
      when Net::HTTPForbidden
        raise DeathByCaptcha::APIForbidden
      when Net::HTTPBadRequest
        raise DeathByCaptcha::APIBadRequest
      when Net::HTTPRequestEntityTooLarge
        raise DeathByCaptcha::APICaptchaTooLarge
      when Net::HTTPServiceUnavailable
        raise DeathByCaptcha::APIServiceUnavailable
      else
        raise DeathByCaptcha::APIResponseError.new(res.body)
      end
    end

    # Prepare the multipart data to be sent via a :post_multipart request.
    #
    # @param [Hash] payload Data to be prepared via a multipart post.
    #
    # @return [String,String] Boundary and body for the multipart post.
    #
    def prepare_multipart_data(payload)
      boundary = "infosimples" + rand(1_000_000).to_s # a random unique string

      content = []
      payload.each do |param, value|
        content << '--' + boundary
        content << "Content-Disposition: form-data; name=\"#{param}\""
        content << ''
        content << value
      end
      content << '--' + boundary + '--'
      content << ''

      [boundary, content.join("\r\n")]
    end
  end
end
