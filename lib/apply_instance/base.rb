module ApplyInstance
  class Base
    def initialize
      raise 'ApplyInstance base class cannot be initialized' if self.class == Base
    end

    attr_reader :type

    def url; end

    def ping_url; end
  end
end
