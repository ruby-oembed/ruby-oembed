begin
  require 'json/ext'
rescue LoadError
  require 'json'
end

require 'net/http'

require 'oembed/provider'