module DeathByCaptcha

  # Create a DeathByCaptcha API client. This is a shortcut to
  # DeathByCaptcha::Client.create.
  #
  def self.new(*args)
    DeathByCaptcha::Client.create(*args)
  end

  # DeathByCaptcha::Client is a common interface inherited by DBC clients like
  # DeathByCaptcha::Client::HTTP and DeathByCaptcha::Client::Socket.
  #
  class Client

    attr_accessor :username, :password, :timeout, :polling, :hostname

    # Create a DeathByCaptcha API client
    #
    # @param [String] username Username of the DeathByCaptcha account.
    # @param [String] password Password of the DeathByCaptcha account.
    # @param [Symbol] connection Connection type (:socket, :http)
    # @param [Hash]   options  Options hash.
    # @option options [Integer] :timeout (60) Seconds before giving up.
    # @option options [Integer] :polling (5) Seconds for polling the solution.
    #
    # @return [DeathByCaptcha::Client] A Socket or HTTP Client instance.
    #
    def self.create(username, password, connection = :socket, options = {})
      case connection
      when :socket
        DeathByCaptcha::Client::Socket.new(username, password, options)
      when :http
        DeathByCaptcha::Client::HTTP.new(username, password, options)
      else
        raise DeathByCaptcha::InvalidClientConnection
      end
    end

    # Create a DeathByCaptcha client.
    #
    # @param [String] username Username of the DeathByCaptcha account.
    # @param [String] password Password of the DeathByCaptcha account.
    # @param [Hash]   options  Options hash.
    # @option options [Integer] :timeout (60) Seconds before giving up.
    # @option options [Integer] :polling (5) Seconds for polling the solution.
    # @option options [String]  :hostname ('api.dbcapi.me') Custom API hostname.
    #
    # @return [DeathByCaptcha::Client] A Client instance.
    #
    def initialize(username, password, options = {})
      self.username   = username
      self.password   = password
      self.timeout    = options[:timeout] || 60
      self.polling    = options[:polling] || 5
      self.hostname   = options[:hostname] || 'api.dbcapi.me'
    end

    # Decode the text from an image (i.e. solve a captcha).
    #
    # @param [Hash] options Options hash.
    # @option options [String]  :url    URL of the image to be decoded.
    # @option options [String]  :path   File path of the image to be decoded.
    # @option options [File]    :file   File instance with image to be decoded.
    # @option options [String]  :raw    Binary content of the image to be decoded.
    # @option options [String]  :raw64  Binary content encoded in base64 of the image to be decoded.
    #
    # @return [DeathByCaptcha::Captcha] The captcha (with solution) or an empty hash if something goes wrong.
    #
    def decode(options = {})
      decode!(options)
    rescue DeathByCaptcha::Error
      DeathByCaptcha::Captcha.new
    end

    # Decode the text from an image (i.e. solve a captcha).
    #
    # @param [Hash] options Options hash.
    # @option options [String]  :url    URL of the image to be decoded.
    # @option options [String]  :path   File path of the image to be decoded.
    # @option options [File]    :file   File instance with image to be decoded.
    # @option options [String]  :raw    Binary content of the image to be decoded.
    # @option options [String]  :raw64  Binary content encoded in base64 of the image to be decoded.
    #
    # @return [DeathByCaptcha::Captcha] The captcha (with solution if an error is not raised).
    #
    def decode!(options = {})
      started_at = Time.now

      raw64 = load_captcha(options)
      raise DeathByCaptcha::InvalidCaptcha if raw64.to_s.empty?

      decoded_captcha = self.upload(options.merge(raw64: raw64))

      while decoded_captcha.text.to_s.empty?
        sleep(self.polling)
        decoded_captcha = self.captcha(decoded_captcha.id)
        raise DeathByCaptcha::Timeout if (Time.now - started_at) > self.timeout
      end

      raise DeathByCaptcha::IncorrectSolution if !decoded_captcha.is_correct

      decoded_captcha
    end

    # Retrieve information from an uploaded captcha.
    #
    # @param [Integer] captcha_id Numeric ID of the captcha.
    #
    # @return [DeathByCaptcha::Captcha] The captcha object.
    #
    def captcha(captcha_id)
      raise NotImplementedError
    end

    # Report incorrectly solved captcha for refund.
    #
    # @param [Integer] captcha_id Numeric ID of the captcha.
    #
    # @return [DeathByCaptcha::Captcha] The captcha object.
    #
    def report!(captcha_id)
      raise NotImplementedError
    end

    # Retrieve your user information (which has the current credit balance).
    #
    # @return [DeathByCaptcha::User] The user object.
    #
    def user
      raise NotImplementedError
    end

    # Retrieve DeathByCaptcha server status.
    #
    # @return [DeathByCaptcha::ServerStatus] The server status object.
    #
    def status
      raise NotImplementedError
    end

    # Upload a captcha to DeathByCaptcha.
    #
    # This method will not return the solution. It's only useful if you want to
    # implement your own "decode" function.
    #
    # @return [DeathByCaptcha::Captcha] The captcha object (not solved yet).
    #
    def upload(raw64)
      raise NotImplementedError
    end

    private

    # Load a captcha raw content encoded in base64 from options.
    #
    # @param [Hash] options Options hash.
    # @option options [String]  :url    URL of the image to be decoded.
    # @option options [String]  :path   File path of the image to be decoded.
    # @option options [File]    :file   File instance with image to be decoded.
    # @option options [String]  :raw    Binary content of the image to be decoded.
    # @option options [String]  :raw64  Binary content encoded in base64 of the image to be decoded.
    #
    # @return [String] The binary image base64 encoded.
    #
    def load_captcha(options)
      if options[:raw64]
        options[:raw64]
      elsif options[:raw]
        Base64.encode64(options[:raw])
      elsif options[:file]
        Base64.encode64(options[:file].read())
      elsif options[:path]
        Base64.encode64(File.open(options[:path], 'rb').read)
      elsif options[:url]
        Base64.encode64(open_url(options[:url]))
      else
        ''
      end
    rescue
      ''
    end

    def open_url(url)
      uri = URI(url)

      http = Net::HTTP.new(uri.host, uri.port)

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      res = http.get(uri.request_uri)

      if (redirect = res.header['location'])
        open_url(redirect)
      else
        res.body
      end
    end
  end
end

require 'deathbycaptcha/client/http'
require 'deathbycaptcha/client/socket'
