$:.unshift File.dirname(__FILE__)

%w(json/ext json).each do |lib|
  begin
    require lib
    break
  rescue LoadError
  end
end

begin
  require 'xmlsimple'
rescue LoadError
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