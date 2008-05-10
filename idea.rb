# Adding providers:
# The second argument defines the default format
flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/", :xml)
flickr << "http://*.flickr.com/*"
# Optional settings:
flickr.name = "Flickr"
flickr.url = "http://flickr.com/"

# Another one:
# The default format defaults to json
qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}")
qik << "http://qik.com/*"

# Get a raw XML-file from Flickr:
flickr.raw("http://flickr.com/photos/my_user/1231231312")
# Get a raw JSON-file
flickr.raw("http://flickr.com/photos/my_user/1231231312", :format => :json)

# Returns a OEmbed::Response
flickr.get("http://flickr.com/photos/my_user/1231231312")

# Register them to 
OEmbed::Providers.register(flickr, qik)

OEmbed::Providers.raw("http://qik.com/test", :format => :xml)

res.is_a?(OEmbed::Response)
res.type
res.version
res.author_name
res.author_url
res.provider.url
res.provider.name