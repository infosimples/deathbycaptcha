module DeathByCaptcha

  # Model of a Captcha returned by DeathByCaptcha API.
  #
  class Captcha < DeathByCaptcha::Model
    attr_accessor :captcha, :is_correct, :text

    def id
      @captcha
    end

    def is_correct=(value)
      @is_correct = ['1', true].include?(value)
    end

    def captcha=(value)
      @captcha = value.to_i
    end

    def parsed_text
      JSON.parse(text)
    rescue
      []
    end
    alias_method :coordinates, :parsed_text
    alias_method :indexes, :parsed_text
  end
end
