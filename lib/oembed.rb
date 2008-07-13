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
require 'oembed/response/photo'
require 'oembed/response/video'
require 'oembed/response/link'
require 'oembed/response/rich'