module OEmbed
  class Providers
    # Provider for nfb.ca
    NFBCanada = OEmbed::Provider.new('http://www.nfb.ca/remote/services/oembed/')
    NFBCanada << 'http://*.nfb.ca/film/*'
    add_official_provider(NFBCanada)
  end
end
