# Patches are added so older versions of Ruby work with this gem
#
unless ''.respond_to?(:empty?)
  class String
    def empty?
      self.length == 0
    end
  end
end
