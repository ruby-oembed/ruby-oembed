# Unlike other backends, require YAML if it's not already loaded
require 'yaml' unless defined?(YAML)

module OEmbed
  module Formatter
    module JSON
      module Backends
        module Yaml
          ParseError = ::StandardError
          extend self

          # Parses a JSON string or IO and converts it into an object
          def decode(json)
            if json.respond_to?(:read)
              json = json.read
            end
            YAML.load(convert_json_to_yaml(json))
          rescue ArgumentError
            raise ParseError, "Invalid JSON string"
          end

          protected
            # Ensure that ":" and "," are always followed by a space
            def convert_json_to_yaml(json) #:nodoc:
              require 'strscan' unless defined? ::StringScanner
              scanner, quoting, marks, pos = ::StringScanner.new(json), false, [], nil
              while scanner.scan_until(/(\\['"]|['":,\\]|\\.)/)
                case char = scanner[1]
                when '"', "'"
                  if !quoting
                    quoting = char
                    pos = scanner.pos
                  elsif quoting == char
                    quoting = false
                  end
                when ":",","
                  marks << scanner.pos - 1 unless quoting
                when "\\"
                  scanner.skip(/\\/)
                end
              end

              if marks.empty?
                json.gsub(/\\([\\\/]|u[[:xdigit:]]{4})/) do
                  ustr = $1
                  if ustr.index('u') == 0
                    [ustr[1..-1].to_i(16)].pack("U")
                  elsif ustr == '\\'
                    '\\\\'
                  else
                    ustr
                  end
                end
              else
                left_pos  = [-1].push(*marks)
                right_pos = marks << scanner.pos + scanner.rest_size
                output    = []
                left_pos.each_with_index do |left, i|
                  scanner.pos = left.succ
                  chunk = scanner.peek(right_pos[i] - scanner.pos + 1)
                  chunk.gsub!(/\\([\\\/]|u[[:xdigit:]]{4})/) do
                    ustr = $1
                    if ustr.index('u') == 0
                      [ustr[1..-1].to_i(16)].pack("U")
                    elsif ustr == '\\'
                      '\\\\'
                    else
                      ustr
                    end
                  end
                  output << chunk
                end
                output = output * " "

                output.gsub!(/\\\//, '/')
                output
              end
            end
        
        end
      end
    end
  end
end

# Only allow this backend if it parses JSON strings the way we expect it to
begin
 raise unless OEmbed::Formatter::JSON::Backends::Yaml.decode(OEmbed::Formatter::JSON.test_values[0]) == OEmbed::Formatter::JSON.test_values[1]
rescue
  raise LoadError
end