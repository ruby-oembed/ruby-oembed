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

# Get a raw XML-file from Flickr
flickr.raw("http://flickr.com/photos/my_user/1231231312")
# Get a raw JSON-file from Flickr
flickr.raw("http://flickr.com/photos/my_user/1231231312", :format => :json)

# Register both providers
OEmbed::Providers.register(flickr, qik)

# Get a raw XML-file from whichever provider matches
OEmbed::Providers.raw("http://qik.com/video/1", :format => :xml)

# Returns a OEmbed::Response using XmlSimple library to parse the response
res = flickr.get("http://flickr.com/photos/my_user/1231231312")
# Returns a OEmbed::Response using the JSON library to parse the response
res = flickr.get("http://flickr.com/photos/my_user/1231231312", :format => :json)

res.is_a?(OEmbed::Response) # => true
res.type # => "photo"
res.version # => "1.0"
res.html # => "<img src='http://farm1.static.flickr.com/2312/3123123_123123.jpg' />"
res.author_name # => "my_user"
res.author_url # => "http://flickr.com/photos/my_user"
res.provider.url # => "http://flickr.com/"
res.provider.name # => "Flickr"
