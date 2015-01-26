module DeathByCaptcha

  # Model of a User returned by DeathByCaptcha API.
  #
  class User < DeathByCaptcha::Model
    attr_accessor :is_banned, :balance, :rate, :user

    def id
      @user
    end

    def is_banned=(value)
      @is_banned = ['1', true].include?(value)
    end

    def balance=(value)
      @balance = value.to_f
    end

    def rate=(value)
      @rate = value.to_f
    end

    def user=(value)
      @user = value.to_i
    end
  end
end
