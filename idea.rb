require "rubygems"
require "lib/oembed"
# Adding providers:
# The second argument defines the default format
flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/", :xml)
flickr << "http://*.flickr.com/*"
# Optional settings:
flickr.name = "Flickr"
flickr.url = "http://flickr.com/"

# Another one:
# The default format is json
qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}")
qik << "http://qik.com/*"

# Get a raw XML-file from Flickrr
flickr.raw("http://www.flickr.com/photos/varius/4537325286/")

# Get a raw JSON-file from Flickr
flickr.raw("http://www.flickr.com/photos/varius/4537325286/", :format => :json)


OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery, OEmbed::Providers::Embedly, OEmbed::Providers::OohEmbed)
#Testing embedly 

# Register both providers
OEmbed::Providers.register_all()

# Get a raw XML-file from whichever provider matches
res = OEmbed::Providers.raw("http://www.escapistmagazine.com/videos/view/apocalypse-lane/1687-Episode-47-Dirty-Rotten-Cyborgs", :format => :xml)
puts res

res = OEmbed::Providers.raw("http://www.ustream.tv/recorded/6724045/highlight/72611#utm_campaign=fhighlights&utm_source=2&utm_medium=music", :format => :json)
puts res

res = OEmbed::Providers.raw("http://www.thedailyshow.com/collection/271554/steve-carell-s-best-daily-show-returns/269838", :format => :json)
puts res


begin
  res = OEmbed::Providers.raw("http://www.example.com", :format => :json)
rescue OEmbed::NotFound
  puts "not a supported url"
end


# Returns a OEmbed::Response using XmlSimple library to parse the response
res = flickr.get("http://www.flickr.com/photos/varius/4537325286/", :format => :xml)
# Returns a OEmbed::Response using the JSON library to parse the response
res = flickr.get("http://www.flickr.com/photos/varius/4537325286/", :format => :json)

puts res.is_a?(OEmbed::Response) # => true
puts res.type # => "photo"
puts res.version # => "1.0"
puts res.html # => "<img src='http://farm1.static.flickr.com/2312/3123123_123123.jpg' />"
puts res.author_name # => "my_user"
puts res.author_url # => "http://flickr.com/photos/my_user"
puts res.provider.url # => "http://flickr.com/"
puts res.provider.name # => "Flickr"
