require 'openssl'

module OEmbed
  # Contains helper methods for making HTTP requests.
  module HttpHelper
    private

    # Given a URI, make an HTTP request
    #
    # The options Hash recognizes the following keys:
    # :timeout:: specifies the timeout (in seconds) for the http request.
    # :max_redirects:: the number of times this request will follow
    #                  3XX redirects before throwing an error. Default: 4
    def http_get(uri, options = {})
      # rubocop:disable Lint/ShadowingOuterLocalVariable
      res = Internals.follow_redirects(uri, options) do |uri, options|
        http = Internals.get_http(uri, options)
        req = Internals.get_req(uri)
        http.request(req)
      end
      # rubocop:enable Lint/ShadowingOuterLocalVariable
      HTTPResponseHandler.handle(res, uri)
    rescue StandardError
      Internals.response_error_catch_all($!)
    end

    # An abstraction for converting various Net::HTTPResponse instances
    # into a correct OEmbed::Error class
    # or a String if everything actually worked.
    class HTTPResponseHandler
      class << self
        # Takes a Net::HTTPResponse instance
        # finds the appropriate HTTPResponseHandler sub-class
        # and handles it appropriately.
        def handle(http_response, uri)
          klass = get_matching_class(http_response)
          klass ||= UnknownResponse

          klass.new(http_response, uri)
        end

        # Get the HTTPResponseHandler sub-class matching the Net::HTTP class
        # Example
        #   Net::HTTPNotImplemented => HTTPResponseHandler::HTTPNotImplemented
        def get_matching_class(http_response)
          const = http_response.class.to_s.match(/(::)?([^:]+)$/)
          const && const_defined?(const[2]) && const_get(const[2])
        end
      end

      # Handle a Net::HTTPSuccess response
      class HTTPSuccess
        def self.new(http_response, _uri)
          http_response.body
        end
      end
      HTTPOK = HTTPSuccess

      # Handle a Net::HTTPNotImplemented response
      class HTTPNotImplemented
        def self.new(*_args)
          raise OEmbed::UnknownFormat
        end
      end

      # Handle a Net::HTTPNotFound response
      class HTTPNotFound
        def self.new(_http_response, uri)
          raise OEmbed::NotFound, uri
        end
      end

      # Handle all Net::HTTPResponse classes not otherwise specifically handled
      class UnknownResponse
        def self.new(http_response, _uri)
          code = 'Error'
          if http_response && http_response.respond_to?(:code)
            code = http_response.code
          end
          raise OEmbed::UnknownResponse, code
        end
      end
    end

    # Contains helper methods to be used internally
    # by the HttpHelper methods
    module Internals
      class << self
        def get_http(uri, options)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme == 'https'
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          if options[:timeout]
            http.read_timeout = http.open_timeout = options[:timeout]
          end
          http
        end

        def get_req(uri)
          methods = if RUBY_VERSION < '2.2'
                      %w(scheme userinfo host port registry)
                    else
                      %w(scheme userinfo host port)
                    end
          methods.each { |method| uri.send("#{method}=", nil) }

          req = Net::HTTP::Get.new(uri.to_s)
          req['User-Agent'] = \
            "Mozilla/5.0 (compatible; ruby-oembed/#{OEmbed::VERSION})"
          req
        end

        def follow_redirects(uri, options)
          remaining = options[:max_redirects] ? options[:max_redirects].to_i : 4

          while (remaining -= 1) >= 0
            res = yield(uri, options)

            if res.is_a?(Net::HTTPRedirection) && res.header['location']
              # Try again if we've found a redirect
              uri = URI.parse(res.header['location'])
            else
              # Return the response if we got a non-300 response
              break
            end
          end

          res
        end

        def response_error_catch_all(err)
          # Convert known errors into OEmbed::UnknownResponse for easy catching
          # up the line. This is important if given a URL that doesn't support
          # OEmbed. The following are known errors:
          # * Net::* errors like Net::HTTPBadResponse
          # * JSON::JSONError errors like JSON::ParserError
          if defined?(::JSON) && err.is_a?(::JSON::JSONError) ||
             err.class.to_s.start_with?('Net::')

            raise OEmbed::UnknownResponse, 'Error'
          else
            raise err
          end
        end
      end
    end
  end
end
