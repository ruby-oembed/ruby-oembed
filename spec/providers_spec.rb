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

  after(:each) do
    OEmbed::Providers.unregister_all
  end

  describe ".register" do
    it "should register providers" do
      OEmbed::Providers.urls.should be_empty
    
      OEmbed::Providers.register(@flickr, @qik)
    
      OEmbed::Providers.urls.keys.should == @flickr.urls + @qik.urls

      @flickr.urls.each do |regexp|
        OEmbed::Providers.urls.should have_key(regexp)
        OEmbed::Providers.urls[regexp].should include(@flickr)
      end

      @qik.urls.each do |regexp|
        OEmbed::Providers.urls.should have_key(regexp)
        OEmbed::Providers.urls[regexp].should include(@qik)
      end
    end

    it "should find by URLs" do
      OEmbed::Providers.register(@flickr, @qik) # tested in "should register providers"
    
      OEmbed::Providers.find(example_url(:flickr)).should == @flickr
      OEmbed::Providers.find(example_url(:qik)).should == @qik
    end
  end

  describe ".unregister" do
    it "should unregister providers" do
      OEmbed::Providers.register(@flickr, @qik) # tested in "should register providers"
    
      OEmbed::Providers.unregister(@flickr)
    
      @flickr.urls.each do |regexp|
        OEmbed::Providers.urls.should_not have_key(regexp)
      end
    
      OEmbed::Providers.urls.keys.should == @qik.urls

      @qik.urls.each do |regexp|
        OEmbed::Providers.urls.should have_key(regexp)
        OEmbed::Providers.urls[regexp].should include(@qik)
      end
    end

    it "should not unregister duplicate provider urls at first" do
      @qik_mirror = OEmbed::Provider.new("http://mirror.qik.com/api/oembed.{format}")
      @qik_mirror << "http://qik.com/*"
    
      @qik_mirror.urls.each do |regexp|
        @qik.urls.should include(regexp)
      end
    
      OEmbed::Providers.register(@qik, @qik_mirror)
    
      OEmbed::Providers.urls.keys.should == @qik.urls

      @qik_mirror.urls.each do |regexp|
        OEmbed::Providers.urls[regexp].should include(@qik_mirror)
        OEmbed::Providers.urls[regexp].should include(@qik)
      end
    
      OEmbed::Providers.find(example_url(:qik)).should == @qik
    
      OEmbed::Providers.unregister(@qik)
    
      urls = OEmbed::Providers.urls.dup

      @qik_mirror.urls.each do |regexp|
        OEmbed::Providers.urls[regexp].should include(@qik_mirror)
      end
    
      OEmbed::Providers.find(example_url(:qik)).should == @qik_mirror
    
      OEmbed::Providers.unregister(@qik_mirror)
    
      @qik_mirror.urls.each do |regexp|
        OEmbed::Providers.urls.should_not have_key(regexp)
      end
    end
  end

  #it "should use the OEmbed::ProviderDiscovery fallback provider correctly" do
	#  url = example_url(:vimeo)
  #
	#  # None of the registered providers should match
	#  all_example_urls.each do |url|
	#    provider = OEmbed::Providers.find(url)
	#    if provider
	#      provider.should_not_receive(:raw)
	#      provider.should_not_receive(:get)
  #    end
	#  end
  #
	#  # Register the fallback
	#  OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery)
  #
	#  provider = OEmbed::ProviderDiscovery
	#  provider.should_receive(:raw).
	#    with(url, {}).
	#    and_return(valid_response(:raw))
	#  provider.should_receive(:get).
	#    with(url, {}).
	#    and_return(valid_response(:object))
  #end

  describe "#raw and #get" do
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
      OEmbed::Providers.register_all
      ["http://fake.com/", example_url(:google_video)].each do |url|
        proc { OEmbed::Providers.get(url) }.should raise_error(OEmbed::NotFound)
        proc { OEmbed::Providers.raw(url) }.should raise_error(OEmbed::NotFound)
      end
    end
  end

  describe ".register_fallback" do
    it "should register fallback providers" do
      OEmbed::Providers.register_fallback(OEmbed::Providers::Hulu)
      OEmbed::Providers.register_fallback(OEmbed::Providers::OohEmbed)

      OEmbed::Providers.fallback.should == [ OEmbed::Providers::Hulu, OEmbed::Providers::OohEmbed]
    end

    it "should fallback to the appropriate provider when URL isn't found" do
      OEmbed::Providers.register_all
      OEmbed::Providers.register_fallback(OEmbed::Providers::Hulu)
      OEmbed::Providers.register_fallback(OEmbed::Providers::OohEmbed)
    
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
      OEmbed::Providers.register_all
      OEmbed::Providers.register_fallback(OEmbed::Providers::Hulu)
      OEmbed::Providers.register_fallback(OEmbed::Providers::OohEmbed)
    
      ["http://fa.ke/"].each do |url|
        proc { OEmbed::Providers.get(url) }.should raise_error(OEmbed::NotFound)
        proc { OEmbed::Providers.raw(url) }.should raise_error(OEmbed::NotFound)
      end
    end
  end

  describe ".register_all" do
    after(:each) do
      OEmbed::Providers.send(:remove_const, :Fake) if defined?(OEmbed::Providers::Fake)
    end
    
    it "should not register a provider that is not marked as official" do
      defined?(OEmbed::Providers::Fake).should_not be
      
      class OEmbed::Providers
        Fake = OEmbed::Provider.new("http://new.fa.ke/oembed/")
        Fake << "http://new.fa.ke/*"
      end
      
      OEmbed::Providers.register_all
      ["http://new.fa.ke/20C285E0"].each do |url|
        provider = OEmbed::Providers.find(url)
        provider.should be_nil
      end
    end
    
    describe 'add_official_provider' do
      it "should register a new official provider" do
        defined?(OEmbed::Providers::Fake).should_not be
        
        class OEmbed::Providers
          Fake = OEmbed::Provider.new("http://official.fa.ke/oembed/")
          Fake << "http://official.fa.ke/*"
          add_official_provider(Fake)
        end

        ["http://official.fa.ke/20C285E0"].each do |url|
          provider = OEmbed::Providers.find(url)
          provider.should_not be_a(OEmbed::Provider)
        end
        
        OEmbed::Providers.register_all
        ["http://official.fa.ke/20C285E0"].each do |url|
          provider = OEmbed::Providers.find(url)
          provider.should be_a(OEmbed::Provider)
        end
      end

      it "should register an official sub_type provider separately" do
        defined?(OEmbed::Providers::Fake).should_not be
        
        class OEmbed::Providers
          Fake = OEmbed::Provider.new("http://sub.fa.ke/oembed/")
          Fake << "http://sub.fa.ke/*"
          add_official_provider(Fake, :fakes)
        end

        OEmbed::Providers.register_all
        ["http://sub.fa.ke/20C285E0"].each do |url|
          provider = OEmbed::Providers.find(url)
          provider.should_not be_a(OEmbed::Provider)
        end
        
        OEmbed::Providers.register_all(:fakes)
        ["http://sub.fa.ke/20C285E0"].each do |url|
          provider = OEmbed::Providers.find(url)
          provider.should be_a(OEmbed::Provider)
        end
      end
    end
  end
end
