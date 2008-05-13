require File.dirname(__FILE__) + '/spec_helper'

describe OEmbed::Providers do
  include OEmbedSpecHelper
  
  before(:all) do
    @flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/")
    @qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}")

    @flickr << "http://*.flickr.com/*"
    @qik << "http://qik.com/video/*"
    @qik << "http://qik.com/*"
  end
  
  it "should register providers" do
    OEmbed::Providers.register(@flickr, @qik)
    urls = OEmbed::Providers.urls.dup
    
    @flickr.urls.each do |regexp|
      urls.delete(regexp).should == @flickr
    end
    
     @qik.urls.each do |regexp|
      urls.delete(regexp).should == @qik
    end
    
    urls.length.should == 0
  end
  
  it "should find by URLs" do
    OEmbed::Providers.find(url(:flickr)).should == @flickr
    OEmbed::Providers.find("http://qik.com/video/9565").should == @qik
  end
  
  it "should raise error if no embeddable content is found" do
    proc { OEmbed::Providers.get("http://fake.com/") }.should raise_error(OEmbed::NotFound)
    proc { OEmbed::Providers.raw("http://fake.com/") }.should raise_error(OEmbed::NotFound)
  end
  
  it "should unregister providers" do
    OEmbed::Providers.unregister(@flickr)
    urls = OEmbed::Providers.urls.dup
    
    @qik.urls.each do |regexp|
      urls.delete(regexp).should == @qik
    end
    
    urls.length.should == 0
  end
  
  it "should bridge #get and #raw to the right provider" do
    OEmbed::Providers.register_all
    OEmbedSpecHelper::EXAMPLE.values.each do |url|
      provider = OEmbed::Providers.find(url)
      provider.should_receive(:raw).
        with(url, {})
      provider.should_receive(:get).
        with(url, {})
      OEmbed::Providers.raw(url)
      OEmbed::Providers.get(url)
    end
  end
end