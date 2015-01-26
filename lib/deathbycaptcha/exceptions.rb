module DeathByCaptcha

  # This is the base DeathByCaptcha exception class. Rescue it if you want to
  # catch any exception that might be raised.
  #
  class Error < Exception
  end

  class InvalidClientConnection < Error
    def initialize
      super('You have specified an invalid client connection (valid connections are :socket, :http)')
    end
  end

  class InvalidCaptcha < Error
    def initialize
      super('The captcha is empty or invalid')
    end
  end

  class Timeout < Error
    def initialize
      super('The captcha was not solved in the expected time')
    end
  end

  class IncorrectSolution < Error
    def initialize
      super('CAPTCHA was not solved by DeathByCaptcha. Try again.')
    end
  end

  class APIResponseError < Error
    def initialize(info)
      super("Invalid API response: #{info}")
    end
  end

  class APIForbidden < Error
    def initialize
      super('Access denied, please check your credentials and/or balance')
    end
  end

  class APIServiceUnavailable < Error
    def initialize
      super('CAPTCHA was rejected due to service overload, try again later')
    end
  end

  class APIBadRequest < Error
    def initialize
      super('CAPTCHA was rejected by the service, check if it\'s a valid image')
    end
  end

  class APICaptchaTooLarge < Error
    def initialize
      super('CAPTCHA image size is too large')
    end
  end
end
