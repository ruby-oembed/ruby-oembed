module OEmbed
  
  # A generic OEmbed-related Error. The OEmbed library does its best to capture all internal
  # errors and wrap them in an OEmbed::Error class so that the error-handling code in your
  # application can more easily identify the source of errors.
  #
  # The following Classes inherit from OEmbed::Error
  # * OEmbed::FormatNotSupported
  # * OEmbed::NotFound
  # * OEmbed::ParseError
  # * OEmbed::UnknownFormat
  # * OEmbed::UnknownResponse
  class Error < StandardError
  end

  # @api hidden
  class NotFound < OEmbed::Error
    def to_s
      "No embeddable content at '#{super}'"
    end
  end

  # @api hidden
  class UnknownFormat < OEmbed::Error
    def to_s
      "The provider doesn't support the '#{super}' format"
    end
  end

  # @api hidden
  class FormatNotSupported < OEmbed::Error
    def to_s
      "This server doesn't have the correct libraries installed to support the '#{super}' format"
    end
  end

  # @api hidden
  class UnknownResponse < OEmbed::Error
    def to_s
      "Got unknown response (#{super}) from server"
    end
  end

  # @api hidden
  class ParseError < OEmbed::Error
    def to_s
      "There was an error parsing the server response (#{super})"
    end
  end
    
end
