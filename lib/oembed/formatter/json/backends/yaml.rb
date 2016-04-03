# Unlike other backends, require YAML if it's not already loaded
require 'yaml' unless defined?(YAML)

module OEmbed
  module Formatter
    module JSON
      module Backends
        # Use the YAML library, part of the standard library,
        # to parse JSON values that has been converted to YAML.
        module Yaml
          # Parses a JSON string or IO and converts it into an object.
          def decode(json)
            json = json.read if json.respond_to?(:read)
            YAML.load(Internal.convert_json_to_yaml(json))
          rescue ArgumentError, Psych::SyntaxError
            raise parse_error, 'Invalid JSON string'
          end

          def decode_fail_msg
            'The version of the YAML library you have installed' \
              'isn\'t parsing JSON like ruby-oembed expected.'
          end

          def parse_error
            ::StandardError
          end

          public_instance_methods.each { |method| module_function(method) }

          # Methods to be used only internally by Backends::Yaml
          class Internal
            # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
            # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
            # rubocop:disable Lint/UselessAssignment
            def self.convert_json_to_yaml(json) #:nodoc:
              require 'strscan' unless defined? ::StringScanner
              scanner = ::StringScanner.new(json)
              quoting = false
              marks = []
              pos = nil
              scanner.scan_until(/\{/)
              while scanner.scan_until(/(\\['"]|['":,\\]|\\.)/)
                case char = scanner[1]
                when '"', "'"
                  if !quoting
                    quoting = char
                    pos = scanner.pos
                  elsif quoting == char
                    quoting = false
                  end
                when ':', ','
                  marks << scanner.pos - 1 unless quoting
                when '\\'
                  scanner.skip(/\\/)
                end
              end
              raise parse_error unless scanner.scan_until(/\}/)
              raise parse_error if marks.empty?

              left_pos  = [-1].push(*marks)
              right_pos = marks << scanner.pos + scanner.rest_size
              output    = []
              left_pos.each_with_index do |left, i|
                scanner.pos = left.succ
                chunk = scanner.peek(right_pos[i] - scanner.pos + 1)
                chunk.gsub!(%r'\\([\\/]|u[[:xdigit:]]{4})') do
                  ustr = Regexp.last_match(1)
                  if ustr.index('u') == 0
                    [ustr[1..-1].to_i(16)].pack('U')
                  elsif ustr == '\\'
                    '\\\\'
                  else
                    ustr
                  end
                end
                output << chunk
              end
              output *= ' '

              output.gsub!(%r{\\/}, '/')
              output
            end
            # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
            # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity
            # rubocop:enable Lint/UselessAssignment
          end
        end
      end
    end
  end
end
