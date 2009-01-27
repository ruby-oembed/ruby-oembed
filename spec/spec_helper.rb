require 'rubygems'
require File.dirname(__FILE__) + '/../lib/oembed'

module OEmbedSpecHelper
  EXAMPLE = {
    :flickr => "http://flickr.com/photos/bees/2362225867/",
    :viddler => "http://www.viddler.com/explore/cdevroe/videos/424/",
    :qik => "http://qik.com/video/49565",
    :pownce => "http://pownce.com/mmalone/notes/1756545/",
    :rev3 => "http://revision3.com/diggnation/2008-04-17xsanned/",
  }
  
  def url(site)
    return "http://fake.com/" if site == :fake
    EXAMPLE[site]
  end
  
  def valid_response(format)
    case format
    when :object
      {
        "type" => "photo",
        "version" => "1.0",
        "fields" => "hello",
        "__id__" => 1234
      }
    when :json
      <<-JSON
        {
          "type": "photo",
          "version": "1.0",
          "fields": "hello",
          "__id__": 1234
        }
      JSON
    when :xml
      <<-XML
        <?xml version="1.0" encoding="utf-8" standalone="yes"?>
        <oembed>
        	<type>photo</type>
        	<version>1.0</version>
        	<fields>hello</fields>
        	<__id__>1234</__id__>
        </oembed>
      XML
    end
  end
end