$:.unshift File.dirname(__FILE__)

begin
  require 'json/ext'
rescue LoadError
  require 'json'
end

require 'net/http'

require 'oembed/errors'
require 'oembed/provider'
require 'oembed/providers'
require 'oembed/response'
require 'oembed/photo'
require 'oembed/video'
require 'oembed/link'