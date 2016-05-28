$LOAD_PATH.unshift File.dirname(__FILE__)

require 'English'
require 'net/http'

require 'oembed/version'
require 'oembed/errors'
require 'oembed/formatter'
require 'oembed/provider'
require 'oembed/provider_discovery'
require 'oembed/providers'
require 'oembed/response'
require 'oembed/response/photo'
require 'oembed/response/video'
require 'oembed/response/link'
require 'oembed/response/rich'

# Use the top-level OEmbed methods
# as if you were using OEmbed::Providers
module OEmbed
  class << self
    extend Forwardable
    def_delegators ::OEmbed::Providers, *Providers.public_methods(false)
  end
end
