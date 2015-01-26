module DeathByCaptcha

  # Base class of a model object returned by DeathByCaptcha API.
  #
  class Model
    def initialize(values = {})
      values.each do |key, value|
        self.send("#{key}=", value) if self.respond_to?("#{key}=")
      end
    end
  end
end

require 'deathbycaptcha/models/captcha'
require 'deathbycaptcha/models/server_status'
require 'deathbycaptcha/models/user'
