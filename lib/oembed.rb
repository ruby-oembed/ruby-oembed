$:.unshift File.dirname(__FILE__)

begin
  require 'json/ext'
rescue LoadError
  require 'json'
end

require 'net/http'

require 'oembed/provider'
require 'oembed/response'