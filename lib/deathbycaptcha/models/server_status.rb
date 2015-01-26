module DeathByCaptcha

  # Model of a server status returned by DeathByCaptcha API.
  #
  class ServerStatus < DeathByCaptcha::Model
    attr_accessor :todays_accuracy, :solved_in, :is_service_overloaded

    def todays_accuracy=(value)
      @todays_accuracy = value.to_f
    end

    def solved_in=(value)
      @solved_in = value.to_i
    end

    def is_service_overloaded=(value)
      @is_service_overloaded = ['1', true].include?(value)
    end
  end
end
