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
  end
end
