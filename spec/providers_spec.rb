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
    OEmbed::Providers.find(example_url(:flickr)).should == @flickr
    OEmbed::Providers.find(example_url(:qik)).should == @qik
  end

  it "should unregister providers" do
    OEmbed::Providers.unregister(@flickr)
    urls = OEmbed::Providers.urls.dup

    @qik.urls.each do |regexp|
      urls.delete(regexp).should == @qik
    end

    urls.length.should == 0
  end

  it "should use the OEmbed::ProviderDiscovery fallback provider correctly" do
    url = example_url(:vimeo)

    # None of the registered providers should match
    all_example_urls.each do |url|
      provider = OEmbed::Providers.find(url)
      provider.should_not_receive(:raw)
      provider.should_not_receive(:get)
    end

    # Register the fallback
    OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery)

    provider = OEmbed::ProviderDiscovery
    provider.should_receive(:raw).
      with(url, {}).
      and_return(valid_response(:raw))
    provider.should_receive(:get).
      with(url, {}).
      and_return(valid_response(:object))
    #asdf


  end

  it "should bridge #get and #raw to the right provider" do
    OEmbed::Providers.register_all
    all_example_urls.each do |url|
      provider = OEmbed::Providers.find(url)
      provider.should_receive(:raw).
        with(url, {})
      provider.should_receive(:get).
        with(url, {})
      OEmbed::Providers.raw(url)
      OEmbed::Providers.get(url)
    end
  end

  it "should raise an error if no embeddable content is found" do
    ["http://fake.com/", example_url(:google_video)].each do |url|
      proc { OEmbed::Providers.get(url) }.should raise_error(OEmbed::NotFound)
      proc { OEmbed::Providers.raw(url) }.should raise_error(OEmbed::NotFound)
    end
  end

  it "should register fallback providers" do
    OEmbed::Providers.register_fallback(OEmbed::Providers::Hulu)
    OEmbed::Providers.register_fallback(OEmbed::Providers::OohEmbed)

    OEmbed::Providers.fallback.should == [OEmbed::ProviderDiscovery, OEmbed::Providers::Hulu, OEmbed::Providers::OohEmbed]
  end

  it "should fallback to the appropriate provider when URL isn't found" do
    url = example_url(:google_video)

    provider = OEmbed::Providers.fallback.last
    provider.should_receive(:raw).
      with(url, {}).
      and_return(valid_response(:raw))
    provider.should_receive(:get).
      with(url, {}).
      and_return(valid_response(:object))

    OEmbed::Providers.fallback.each do |p|
      next if p == provider
      p.should_receive(:raw).and_raise(OEmbed::NotFound)
      p.should_receive(:get).and_raise(OEmbed::NotFound)
    end

    OEmbed::Providers.raw(url)
    OEmbed::Providers.get(url)
  end

  it "should still raise an error if no embeddable content is found" do
    ["http://fake.com/"].each do |url|
      proc { OEmbed::Providers.get(url) }.should raise_error(OEmbed::NotFound)
      proc { OEmbed::Providers.raw(url) }.should raise_error(OEmbed::NotFound)
    end
  end
end
