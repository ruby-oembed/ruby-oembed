module OEmbed
  class Error < StandardError
  end

  class NotFound < OEmbed::Error
    def to_s
      "No embeddable content at '#{super}'"
    end
  end

  class UnknownFormat < OEmbed::Error
    def to_s
      "The provider doesn't support the '#{super}' format"
    end
  end

  class FormatNotSupported < OEmbed::Error
    def to_s
      "This server doesn't have the correct libraries installed to support the '#{super}' format"
    end
  end

  class UnknownResponse < OEmbed::Error
    def to_s
      "Got unknown response (#{super}) from server"
    end
  end
end
