require File.dirname(__FILE__) + '/spec_helper'
require 'vcr'

VCR.config do |c|
  c.default_cassette_options = { :record => :new_episodes }
  c.cassette_library_dir = 'spec/cassettes'
  c.stub_with :fakeweb
end

describe OEmbed::Provider do
  before(:all) do
    VCR.insert_cassette('OEmbed_Provider')
  end
  after(:all) do
    VCR.eject_cassette
  end
  
  include OEmbedSpecHelper

  before(:all) do
    @default = OEmbed::Formatter.default
    @flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/")
    @qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}", :xml)
    @viddler = OEmbed::Provider.new("http://lab.viddler.com/services/oembed/", :json)

    @flickr << "http://*.flickr.com/*"
    @qik << "http://qik.com/video/*"
    @qik << "http://qik.com/*"
    @viddler << "http://*.viddler.com/*"
  end

  it "should require a valid endpoint for a new instance" do
    proc { OEmbed::Provider.new("http://foo.com/oembed/") }.
    should_not raise_error(ArgumentError)
    
    proc { OEmbed::Provider.new("https://foo.com/oembed/") }.
    should_not raise_error(ArgumentError)
  end
  
  it "should allow a {format} string in the endpoint for a new instance" do
    proc { OEmbed::Provider.new("http://foo.com/oembed.{format}/get") }.
    should_not raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError given an invalid endpoint for a new instance" do
    [
      "httpx://foo.com/oembed/",
      "ftp://foo.com/oembed/",
      "foo.com/oembed/",
      "http://not a uri",
      nil, 1,
    ].each do |endpoint|
      proc { OEmbed::Provider.new(endpoint) }.
      should raise_error(ArgumentError)
    end
  end

  it "should allow no URI schema to be given" do
    provier = OEmbed::Provider.new("http://foo.com/oembed")
    
    provier.include?("http://foo.com/1").should be_true
    provier.include?("http://bar.foo.com/1").should be_true
    provier.include?("http://bar.foo.com/show/1").should be_true
    provier.include?("https://bar.foo.com/1").should be_true
    provier.include?("http://asdf.com/1").should be_true
    provier.include?("asdf").should be_true
  end

  it "should allow a String as a URI schema" do
    provier = OEmbed::Provider.new("http://foo.com/oembed")
    provier << "http://bar.foo.com/*"
    
    provier.include?("http://bar.foo.com/1").should be_true
    provier.include?("http://bar.foo.com/show/1").should be_true
    
    provier.include?("https://bar.foo.com/1").should be_false
    provier.include?("http://foo.com/1").should be_false
  end
  
  it "should allow multiple path wildcards in a String URI schema" do
    provier = OEmbed::Provider.new("http://foo.com/oembed")
    provier << "http://bar.foo.com/*/show/*"
    
    provier.include?("http://bar.foo.com/photo/show/1").should be_true
    provier.include?("http://bar.foo.com/video/show/2").should be_true
    provier.include?("http://bar.foo.com/help/video/show/2").should be_true
    
    provier.include?("https://bar.foo.com/photo/show/1").should be_false
    provier.include?("http://foo.com/video/show/2").should be_false
    provier.include?("http://bar.foo.com/show/1").should be_false
    provier.include?("http://bar.foo.com/1").should be_false
  end
  
  it "should NOT allow multiple domain wildcards in a String URI schema" do
    provier = OEmbed::Provider.new("http://foo.com/oembed")
    
    pending("We don't yet validate URL schema strings") do
      proc { provier << "http://*.com/*" }.
      should raise_error(ArgumentError)
    end
    
    provier.include?("http://foo.com/1").should be_false
  end
  
  it "should allow a sub-domain wildcard in String URI schema" do
    provier = OEmbed::Provider.new("http://foo.com/oembed")
    provier << "http://*.foo.com/*"
    
    provier.include?("http://bar.foo.com/1").should be_true
    provier.include?("http://foo.foo.com/2").should be_true
    provier.include?("http://foo.com/3").should be_true
    
    provier.include?("https://bar.foo.com/1").should be_false
    provier.include?("http://my.bar.foo.com/1").should be_false
    
    provier << "http://my.*.foo.com/*"
  end
  
  it "should allow multiple sub-domain wildcards in a String URI schema" do
    provier = OEmbed::Provider.new("http://foo.com/oembed")
    provier << "http://*.my.*.foo.com/*"
    
    provier.include?("http://my.bar.foo.com/1").should be_true
    provier.include?("http://my.foo.com/2").should be_true
    provier.include?("http://bar.my.bar.foo.com/3").should be_true
    
    provier.include?("http://bar.foo.com/1").should be_false
    provier.include?("http://foo.bar.foo.com/1").should be_false
  end
  
  it "should NOT allow a scheme wildcard in a String URI schema" do
    provier = OEmbed::Provider.new("http://foo.com/oembed")
    
    pending("We don't yet validate URL schema strings") do
      proc { provier << "*://foo.com/*" }.
      should raise_error(ArgumentError)
    end
    
    provier.include?("http://foo.com/1").should be_false
  end

  it "should allow a scheme other than http in a String URI schema" do
    provier = OEmbed::Provider.new("http://foo.com/oembed")
    provier << "https://foo.com/*"
    
    provier.include?("https://foo.com/1").should be_true
    
    gopher_url = "gopher://foo.com/1"
    provier.include?(gopher_url).should be_false
    provier << "gopher://foo.com/*"
    provier.include?(gopher_url).should be_true
  end

  it "should allow a Regexp as a URI schema" do
    provier = OEmbed::Provider.new("http://foo.com/oembed")
    provier << %r{^https?://([^\.]*\.)?foo.com/(show/)?\d+}
    
    provier.include?("http://bar.foo.com/1").should be_true
    provier.include?("http://bar.foo.com/show/1").should be_true
    provier.include?("http://foo.com/1").should be_true
    provier.include?("https://bar.foo.com/1").should be_true
    
    provier.include?("http://bar.foo.com/video/1").should be_false
    provier.include?("gopher://foo.com/1").should be_false
  end

  it "should by default use OEmbed::Formatter.default" do
    @flickr.format.should == @default
  end

  it "should allow xml" do
    @qik.format.should == :xml
  end

  it "should allow json" do
    @viddler.format.should == :json
  end

  it "should allow random formats on initialization" do
    proc {
      yaml_provider = OEmbed::Provider.new("http://foo.com/api/oembed.{format}", :yml)
      yaml_provider << "http://foo.com/*"
    }.
    should_not raise_error
  end
  
  it "should not allow random formats to be parsed" do
    yaml_provider = OEmbed::Provider.new("http://foo.com/api/oembed.{format}", :yml)
    yaml_provider << "http://foo.com/*"
    yaml_url = "http://foo.com/video/1"
    
    yaml_provider.should_receive(:raw).
      with(yaml_url, {:format=>:yml}).
      and_return(valid_response(:json))
    
    proc { yaml_provider.get(yaml_url) }.
    should raise_error(OEmbed::FormatNotSupported)
  end

  it "should add URL schemes" do
    @flickr.urls.should == [%r{^http://([^\.]+\.)?flickr\.com/(.*?)}]
    @qik.urls.should == [%r{^http://qik\.com/video/(.*?)},
                         %r{^http://qik\.com/(.*?)}]
  end

  it "should match URLs" do
    @flickr.include?(example_url(:flickr)).should be_true
    @qik.include?(example_url(:qik)).should be_true
  end

  it "should raise error if the URL is invalid" do
    proc{ @flickr.send(:build, example_url(:fake)) }.should raise_error(OEmbed::NotFound)
    proc{ @qik.send(:build, example_url(:fake)) }.should raise_error(OEmbed::NotFound)
  end

  describe "#build" do
    it "should return a proper URL" do
      uri = @flickr.send(:build, example_url(:flickr))
      uri.host.should == "www.flickr.com"
      uri.path.should == "/services/oembed/"
      uri.query.include?("format=#{@flickr.format}").should be_true
      uri.query.include?("url=#{CGI.escape 'http://flickr.com/photos/bees/2362225867/'}").should be_true

      uri = @qik.send(:build, example_url(:qik))
      uri.host.should == "qik.com"
      uri.path.should == "/api/oembed.xml"
      uri.query.include?("format=#{@qik.format}").should be_false
      uri.query.should == "url=#{CGI.escape 'http://qik.com/video/49565'}"
    end

    it "should accept parameters" do
      uri = @flickr.send(:build, example_url(:flickr),
        :maxwidth => 600,
        :maxheight => 200,
        :format => :xml,
        :another => "test")

      uri.query.include?("maxwidth=600").should be_true
      uri.query.include?("maxheight=200").should be_true
      uri.query.include?("format=xml").should be_true
      uri.query.include?("another=test").should be_true
    end

    it "should build correctly when format is in the endpoint URL" do
      uri = @qik.send(:build, example_url(:qik), :format => :json)
      uri.path.should == "/api/oembed.json"
    end
    
    it "should build correctly with query parameters in the endpoint URL" do
      provider = OEmbed::Provider.new('http://www.youtube.com/oembed?scheme=https')
      provider << 'http://*.youtube.com/*'
      url = 'http://youtube.com/watch?v=M3r2XDceM6A'
      provider.include?(url).should be_true
      
      uri = provider.send(:build, url)
      uri.query.include?("scheme=https").should be_true
      uri.query.include?("url=#{CGI.escape url}").should be_true
    end
  end

  describe "#raw" do
    it "should return the body on 200" do
      res = @flickr.send(:raw, example_url(:flickr))
      res.should == example_body(:flickr)
    end
    
    it "should return the body on 200 even over https" do
      @vimeo_ssl = OEmbed::Provider.new("https://vimeo.com/api/oembed.{format}")
      @vimeo_ssl << "http://*.vimeo.com/*"
      @vimeo_ssl << "https://*.vimeo.com/*"

      proc do
        @vimeo_ssl.send(:raw, example_url(:vimeo_ssl)).should == example_body(:vimeo_ssl)
      end.should_not raise_error
    end

    it "should raise an UnknownFormat error on 501" do
      # Note: This test relies on a custom-written VCR response in the
      # cassettes/OEmbed_Provider.yml file.
      
      proc do
        @flickr.send(:raw, File.join(example_url(:flickr), '501'))
      end.should raise_error(OEmbed::UnknownFormat)
    end

    it "should raise a NotFound error on 404" do
      # Note: This test relies on a custom-written VCR response in the
      # cassettes/OEmbed_Provider.yml file.
      
      proc do
        @flickr.send(:raw, File.join(example_url(:flickr), '404'))
      end.should raise_error(OEmbed::NotFound)
    end

    it "should raise an UnknownResponse error on other responses" do
      # Note: This test relies on a custom-written VCR response in the
      # cassettes/OEmbed_Provider.yml file.
      
      statuses_to_check = ['405', '500']
      
      statuses_to_check.each do |status|
        proc do
          proc do
            @flickr.send(:raw, File.join(example_url(:flickr), status))
          end.should_not raise_error(OEmbed::NotFound)
        end.should_not raise_error(OEmbed::UnknownResponse)
      end
      
      statuses_to_check.each do |status|
        proc do
          @flickr.send(:raw, File.join(example_url(:flickr), status))
        end.should raise_error(OEmbed::UnknownResponse)
      end
    end
  end

  describe "#get" do
    it "should send the specified format" do
      @flickr.should_receive(:raw).
        with(example_url(:flickr), {:format=>:json}).
        and_return(valid_response(:json))
      @flickr.get(example_url(:flickr), :format=>:json)

      @flickr.should_receive(:raw).
        with(example_url(:flickr), {:format=>:xml}).
        and_return(valid_response(:xml))
      @flickr.get(example_url(:flickr), :format=>:xml)

      lambda do
        @flickr.should_receive(:raw).
          with(example_url(:flickr), {:format=>:yml}).
          and_return(valid_response(:json))
        @flickr.get(example_url(:flickr), :format=>:yml)
      end.should raise_error(OEmbed::FormatNotSupported)
    end
    
    it "should return OEmbed::Response" do
      @flickr.stub!(:raw).and_return(valid_response(@default))
      @flickr.get(example_url(:flickr)).should be_a(OEmbed::Response)
    end

    it "should be calling OEmbed::Response#create_for internally" do
      @flickr.stub!(:raw).and_return(valid_response(@default))
      OEmbed::Response.should_receive(:create_for).
        with(valid_response(@default), @flickr, example_url(:flickr), @default.to_s)
      @flickr.get(example_url(:flickr))

      @qik.stub!(:raw).and_return(valid_response(:xml))
      OEmbed::Response.should_receive(:create_for).
        with(valid_response(:xml), @qik, example_url(:qik), 'xml')
      @qik.get(example_url(:qik))

      @viddler.stub!(:raw).and_return(valid_response(:json))
      OEmbed::Response.should_receive(:create_for).
        with(valid_response(:json), @viddler, example_url(:viddler), 'json')
      @viddler.get(example_url(:viddler))
    end

    it "should send the provider's format if none is specified" do
      @flickr.should_receive(:raw).
        with(example_url(:flickr), :format => @default).
        and_return(valid_response(@default))
      @flickr.get(example_url(:flickr))

      @qik.should_receive(:raw).
        with(example_url(:qik), :format=>:xml).
        and_return(valid_response(:xml))
      @qik.get(example_url(:qik))

      @viddler.should_receive(:raw).
        with(example_url(:viddler), :format=>:json).
        and_return(valid_response(:json))
      @viddler.get(example_url(:viddler))
    end
  end
end
