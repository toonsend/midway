module ActiveSupport
  module JSON
    class << self
      def decode(json)
        ::JSON.parse(json)
      end
    end
  end
end
