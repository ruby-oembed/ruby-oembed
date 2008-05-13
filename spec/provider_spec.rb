require File.dirname(__FILE__) + '/spec_helper'

describe OEmbed::Provider do
  include OEmbedSpecHelper
  
  before(:all) do
    @flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/")
    @qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}", :xml)
    
    @flickr << "http://*.flickr.com/*"
    @qik << "http://qik.com/video/*"
    @qik << "http://qik.com/*"
  end
  
  it "should add URL schemes" do
    @flickr.urls.should == [%r{^http://([^\.]+\.)?flickr\.com/(.*?)}]
    @qik.urls.should == [%r{^http://qik\.com/video/(.*?)},
                         %r{^http://qik\.com/(.*?)}]
  end
  
  it "should match URLs" do
    @flickr.include?(url(:flickr)).should be_true
    @qik.include?(url(:qik)).should be_true
  end
  
  it "should detect if the format is in the URL" do
    @flickr.format_in_url?.should be_false
    @qik.format_in_url?.should be_true
  end
  
  it "should raise error if the URL is invalid" do
    proc{ @flickr.build(url(:fake)) }.should raise_error(OEmbed::NotFound)
    proc{ @qik.build(url(:fake)) }.should raise_error(OEmbed::NotFound)
  end
  
  describe "#build" do
    it "should return a proper URL" do
      uri = @flickr.build(url(:flickr))
      uri.host.should == "www.flickr.com"
      uri.path.should == "/services/oembed/"
      uri.query.include?("format=json").should be_true
      uri.query.include?("url=http://flickr.com/photos/bees/2362225867/").should be_true

      uri = @qik.build(url(:qik))
      uri.host.should == "qik.com"
      uri.path.should == "/api/oembed.xml"
      uri.query.should == "url=http://qik.com/video/49565"
    end
    
    it "should accept parameters" do
      uri = @flickr.build(url(:flickr),
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
      uri = @qik.build(url(:qik), :format => :json)
      uri.path.should == "/api/oembed.json"
    end
  end
  
  describe "#raw" do
    it "should return the body on 200" do
      res = Net::HTTPOK.new("1.1", 200, "OK").instance_eval do
        @body = "raw content"
        @read = true
        self
      end
      Net::HTTP.stub!(:start).and_return(res)

      @flickr.raw(url(:flickr)).should == "raw content"
    end

    it "should raise error on 501" do
      res = Net::HTTPNotImplemented.new("1.1", 501, "Not Implemented")
      Net::HTTP.stub!(:start).and_return(res)

      proc do
        @flickr.raw(url(:flickr))
      end.should raise_error(OEmbed::UnknownFormat)   
    end

    it "should raise error on 404" do
      res = Net::HTTPNotFound.new("1.1", 404, "Not Found")
      Net::HTTP.stub!(:start).and_return(res)

      proc do
        @flickr.raw(url(:flickr))
      end.should raise_error(OEmbed::NotFound)   
    end

    it "should raise error on all other responses" do
      Net::HTTPResponse::CODE_TO_OBJ.delete_if do |code, res|
        ["200", "404", "501"].include?(code)
      end.each do |code, res|
        r = res.new("1.1", code, "Message")
        Net::HTTP.stub!(:start).and_return(r)

        proc do
          @flickr.raw(url(:flickr))
        end.should raise_error(OEmbed::UnknownResponse)
      end
    end                                                            
  end
  
  describe "#get" do
    it "should set the format to json" do
      @flickr.should_receive(:raw).
        with(url(:flickr), :format => :json).
        and_return('{}')
      @flickr.get(url(:flickr))
    end

    it "should return OEmbed::Response" do
      @flickr.stub!(:raw).and_return('{}')
      @flickr.get(url(:flickr)).is_a?(OEmbed::Response).should be_true
    end
  end
end