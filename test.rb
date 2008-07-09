require 'rubygems'
require 'lib/oembed'

OEmbed::Providers.register_all
puts OEmbed::Providers.get('http://www.viddler.com/explore/kyleslat/videos/127/', :maxwidth => 153).html_code