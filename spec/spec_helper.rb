require 'rubygems'
require File.dirname(__FILE__) + '/../lib/oembed'

module OEmbedSpecHelper
  EXAMPLE = {
    :flickr => "http://flickr.com/photos/bees/2362225867/",
    :viddler => "http://www.viddler.com/explore/cdevroe/videos/424/",
    :qik => "http://qik.com/video/49565",
    :vimeo => "http://vimeo.com/3100878",
    :pownce => "http://pownce.com/mmalone/notes/1756545/",
    :rev3 => "http://revision3.com/diggnation/2008-04-17xsanned/",
    :hulu => "http://www.hulu.com/watch/4569/firefly-serenity#x-0,vepisode,1",
    :google_video => "http://video.google.com/videoplay?docid=8372603330420559198",
  }

  def example_url(site)
    return "http://fake.com/" if site == :fake
    EXAMPLE[site]
  end

  def all_example_urls(*fallback)
    results = EXAMPLE.values

    # By default don't return example_urls that won't be recognized by
    # the included default providers
    results.delete(example_url(:google_video))

    # If requested, return URLs that should work with various fallback providers
    fallback.each do |f|
      case f
      when OEmbed::Providers::OohEmbed
        results << example_url(:google_video)
      end
    end

    results
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
