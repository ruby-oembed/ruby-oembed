module OEmbed
  class ProviderDiscovery
    def raw(url, options = {})
      provider = discover_provider(url, options)
      provider.raw(url, options)
    end
    
    def get(url, options = {})
      provider = discover_provider(url, options)
      provider.get(url, options)
    end
    
    def discover_provider(url, options = {})
      uri = URI.parse(url)
      
      res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.get(uri.request_uri)
      end
      
      provider_endpoint = get_provider_endpoint(res, options[:format])
      Provider.new(provider_endpoint, options[:format])
    end
    
    # get the oembed info from an HTML document
    # for example:
    #   ...
    #   <link rel="alternate" href="http://vimeo.com/api/oembed.json?url=http%3A%2F%2Fvimeo.com%2F3100878" type="application/json+oembed" />
    #   ...
    #   => http://vimeo.com/api/oembed.json
    #
    # only_detect can force detection of :json or :xml endpoints
    def get_provider_endpoint(html, only_detect=nil)
      unless only_detect && only_detect != :json
        md ||= /<link.*href=['"]*([^\s'"]+)['"]*.*application\/json\+oembed.*>/.match(html) 
        md ||= /<link.*application\/json\+oembed.*href=['"]*([^\s'"]+)['"]*.*>/.match(html) 
      end
      unless only_detect && only_detect != :xml
        md ||= /<link.*href=['"]*([^\s'"]+)['"]*.*application\/xml\+oembed.*>/.match(html) 
        md ||= /<link.*application\/xml\+oembed.*href=['"]*([^\s'"]+)['"]*.*>/.match(html) 
      end
      
      uri = URI.parse(md && md[1])
      uri.query = nil
      uri.to_s
    end
  
  end
end