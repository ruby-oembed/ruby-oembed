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
end