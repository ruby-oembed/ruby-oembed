module OEmbed
  # Contains info about the current Version of this library
  class Version
    MAJOR = 0
    MINOR = 10
    PATCH = 1
    STRING = "#{MAJOR}.#{MINOR}.#{PATCH}".freeze

    class << self
      # A String representing the current version of the OEmbed gem.
      def inspect
        STRING
      end
      alias to_s inspect
    end
  end

  VERSION = Version::STRING
end
