require File.dirname(__FILE__) + '/spec_helper'

describe OEmbed::Response do
  include OEmbedSpecHelper

  before(:all) do
    @flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/")
    @qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}", :xml)
    @viddler = OEmbed::Provider.new("http://lab.viddler.com/services/oembed/", :json)

    @flickr << "http://*.flickr.com/*"
    @qik << "http://qik.com/video/*"
    @qik << "http://qik.com/*"
    @viddler << "http://*.viddler.com/*"

    @new_res = OEmbed::Response.new(valid_response(:object), OEmbed::Providers::OohEmbed)

    @default_res = OEmbed::Response.create_for(valid_response(:json), @flickr)
    @xml_res = OEmbed::Response.create_for(valid_response(:xml), @qik, :xml)
    @json_res = OEmbed::Response.create_for(valid_response(:json), @viddler, :json)
  end

  it "should set the provider" do
    @new_res.provider.should == OEmbed::Providers::OohEmbed

    @default_res.provider.should == @flickr
    @xml_res.provider.should == @qik
    @json_res.provider.should == @viddler
  end

  it "should parse the data into #fields" do
    @new_res.fields.keys.should == valid_response(:object).keys

    @default_res.fields.keys.should == valid_response(:object).keys
    @xml_res.fields.keys.should == valid_response(:object).keys
    @json_res.fields.keys.should == valid_response(:object).keys
  end

  it "should only allow JSON or XML" do
    lambda do
      OEmbed::Response.create_for(valid_response(:json), @flickr, :json)
    end.should_not raise_error(OEmbed::FormatNotSupported)

    lambda do
      OEmbed::Response.create_for(valid_response(:xml), @flickr, :xml)
    end.should_not raise_error(OEmbed::FormatNotSupported)

    lambda do
      OEmbed::Response.create_for(valid_response(:yml), @flickr, :yml)
    end.should raise_error(OEmbed::FormatNotSupported)
  end

  it "should not parse the incorrect format" do
    lambda do
      OEmbed::Response.create_for(valid_response(:xml), @flickr)
    end.should raise_error(JSON::ParserError)

    lambda do
      OEmbed::Response.create_for(valid_response(:xml), @viddler, :json)
    end.should raise_error(JSON::ParserError)

    lambda do
      OEmbed::Response.create_for(valid_response(:json), @viddler, :xml)
    end.should raise_error(ArgumentError)
  end

  it "should access the XML data through #field" do
    @xml_res.field(:type).should == "photo"
    @xml_res.field(:version).should == "1.0"
    @xml_res.field(:fields).should == "hello"
    @xml_res.field(:__id__).should == "1234"
  end

  it "should access the JSON data through #field" do
    @json_res.field(:type).should == "photo"
    @json_res.field(:version).should == "1.0"
    @json_res.field(:fields).should == "hello"
    @json_res.field(:__id__).should == 1234
  end

  it "should automagically define helpers" do
    @default_res.type.should == "photo"
    @default_res.version.should == "1.0"
  end

  it "should protect important methods" do
    @default_res.fields.should_not == @default_res.field(:fields)
    @default_res.__id__.should_not == @default_res.field(:__id__)
  end
end
