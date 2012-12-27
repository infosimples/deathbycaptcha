module DeathByCaptcha

  module Errors

    #
    # Custom Error class for rescuing from DeathByCaptcha API errors.
    #
    class Error < StandardError

      def initialize(message)
        super("#{message} (DEATHBYCAPTCHA API ERROR)")
      end

    end

    #
    # Raised when a method tries to access a not implemented method.
    #
    class NotImplemented < Error
      def initialize
        super('The requested functionality was not implemented')
      end
    end

    #
    # Raised when a HTTP call fails.
    #
    class CallError < Error
      def initialize
        super('HTTP call failed')
      end
    end

    #
    # Raised when the user is not allowed to access the API.
    #
    class AccessDenied < Error
      def initialize
        super('Access denied, please check your credentials and/or balance')
      end
    end

    #
    # Raised when the captcha file could not be loaded or is empty.
    #
    class CaptchaEmpty
      def initialize
        super('CAPTCHA image is empty or could not be loaded')
      end
    end

    #
    # Raised when the size of the captcha file is too big.
    #
    class CaptchaOverflow
      def initialize
        super('CAPTCHA image is too big')
      end
    end

    class ServiceOverload
      def initialize
        super('CAPTCHA was rejected due to service overload, try again later')
      end
    end

  end

end