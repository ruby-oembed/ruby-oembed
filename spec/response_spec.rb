require File.dirname(__FILE__) + '/spec_helper'

describe OEmbed::Response do
  include OEmbedSpecHelper

  let(:flickr) {
    flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/")
    flickr << "http://*.flickr.com/*"
    flickr
  }

  let(:skitch) {
    OEmbed::Provider.new("https://skitch.com/oembed")
  }

  let(:qik) {
    qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}", :xml)
    qik << "http://qik.com/video/*"
    qik << "http://qik.com/*"
    qik
  }

  let(:viddler) {
    viddler = OEmbed::Provider.new("http://lab.viddler.com/services/oembed/", :json)
    viddler << "http://*.viddler.com/*"
    viddler
  }

  let(:new_res) {
    OEmbed::Response.new(valid_response(:object), OEmbed::Providers::OohEmbed)
  }

  let(:default_res) {
    OEmbed::Response.create_for(valid_response(:json), @flickr, example_url(:flickr), :json)
  }

  let(:xml_res) {
    OEmbed::Response.create_for(valid_response(:xml), @qik, example_url(:qik), :xml)
  }

  let(:json_res) {
    OEmbed::Response.create_for(valid_response(:json), @viddler, example_url(:viddler), :json)
  }

  let(:expected_helpers) {
    {
      "type" => "random",
      "version" => "1.0",
      "html" => "&lt;em&gt;Hello world!&lt;/em&gt;",
      "url" => "http://foo.com/bar",
    }
  }
  
  let(:expected_skipped) {
    {
      "fields" => "hello",
      "__id__" => 1234,
      "provider" => "oohEmbed",
      "to_s" => "random string",
    }
  }
  
  let(:all_expected) {
    expected_helpers.merge(expected_skipped)
  }

  describe "#initialize" do
    it "should parse the data into fields" do
      # We need to compare keys & values separately because we don't expect all
      # non-string values to be recognized correctly.

      new_res.fields.keys.should == valid_response(:object).keys
      new_res.fields.values.map{|v|v.to_s}.should == valid_response(:object).values.map{|v|v.to_s}

      default_res.fields.keys.should == valid_response(:object).keys
      default_res.fields.values.map{|v|v.to_s}.should == valid_response(:object).values.map{|v|v.to_s}

      xml_res.fields.keys.should == valid_response(:object).keys
      xml_res.fields.values.map{|v|v.to_s}.should == valid_response(:object).values.map{|v|v.to_s}

      json_res.fields.keys.should == valid_response(:object).keys
      json_res.fields.values.map{|v|v.to_s}.should == valid_response(:object).values.map{|v|v.to_s}
    end

    it "should set the provider" do
      new_res.provider.should == OEmbed::Providers::OohEmbed
      default_res.provider.should == @flickr
      xml_res.provider.should == @qik
      json_res.provider.should == @viddler
    end

    it "should set the format" do
      new_res.format.should be_nil
      default_res.format.to_s.should == 'json'
      xml_res.format.to_s.should == 'xml'
      json_res.format.to_s.should == 'json'
    end

    it "should set the request_url" do
      new_res.request_url.should be_nil
      default_res.request_url.to_s.should == example_url(:flickr)
      xml_res.request_url.to_s.should == example_url(:qik)
      json_res.request_url.to_s.should == example_url(:viddler)
    end
  end

  describe "create_for" do
    it "should only allow JSON or XML" do
      lambda do
        OEmbed::Response.create_for(valid_response(:json), flickr, example_url(:flickr), :json)
      end.should_not raise_error(OEmbed::FormatNotSupported)

      lambda do
        OEmbed::Response.create_for(valid_response(:xml), flickr, example_url(:flickr), :xml)
      end.should_not raise_error(OEmbed::FormatNotSupported)

      lambda do
        OEmbed::Response.create_for(valid_response(:yml), flickr, example_url(:flickr), :yml)
      end.should raise_error(OEmbed::FormatNotSupported)
    end

    it "should not parse the incorrect format" do
      lambda do
        OEmbed::Response.create_for(valid_response(:object), example_url(:flickr), flickr, :json)
      end.should raise_error(OEmbed::ParseError)

      lambda do
        OEmbed::Response.create_for(valid_response(:xml), example_url(:flickr), viddler, :json)
      end.should raise_error(OEmbed::ParseError)

      lambda do
        OEmbed::Response.create_for(valid_response(:json), example_url(:flickr), viddler, :xml)
      end.should raise_error(OEmbed::ParseError)
    end
  end

  it "should access the XML data through #field" do
    xml_res.field(:type).should == "photo"
    xml_res.field(:version).should == "1.0"
    xml_res.field(:fields).should == "hello"
    xml_res.field(:__id__).should == "1234"
  end

  it "should access the JSON data through #field" do
    json_res.field(:type).should == "photo"
    json_res.field(:version).should == "1.0"
    json_res.field(:fields).should == "hello"
    json_res.field(:__id__).should == "1234"
  end

  describe "#define_methods!" do
    it "should automagically define helpers" do
      local_res = OEmbed::Response.new(all_expected, OEmbed::Providers::OohEmbed)

      all_expected.each do |method, value|
        local_res.should respond_to(method)
      end
      expected_helpers.each do |method, value|
        local_res.send(method).should == value
      end
      expected_skipped.each do |method, value|
        local_res.send(method).should_not == value
      end
    end

    it "should protect most already defined methods" do
      Object.new.should respond_to('__id__')
      Object.new.should respond_to('to_s')

      all_expected.keys.should include('__id__')
      all_expected.keys.should include('to_s')

      local_res = OEmbed::Response.new(all_expected, OEmbed::Providers::OohEmbed)

      local_res.__id__.should_not == local_res.field('__id__')
      local_res.to_s.should_not == local_res.field('to_s')
    end

    it "should not protect already defined methods that are specifically overridable" do
      class Object
        def version
          "two point oh"
        end
      end

      Object.new.should respond_to('version')
      String.new.should respond_to('version')

      all_expected.keys.should include('version')
      all_expected['version'].should_not == String.new.version

      local_res = OEmbed::Response.new(all_expected, OEmbed::Providers::OohEmbed)

      local_res.version.should == local_res.field('version')
      local_res.version.should_not == String.new.version
    end
  end

  describe "OEmbed::Response::Photo" do
    describe "#html" do
      it "should include the title, if given" do
        response = OEmbed::Response.create_for(example_body(:flickr), example_url(:flickr), flickr, :json)
        response.should respond_to(:title)
        response.title.should_not be_empty
        
        response.html.should_not be_nil
        response.html.should match(/alt='#{response.title}'/)
      end

      it "should work just fine, without a title" do
        response = OEmbed::Response.create_for(example_body(:skitch), example_url(:skitch), skitch, :json)
        response.should_not respond_to(:title)
        
        response.html.should_not be_nil
        response.html.should match(/alt=''/)
      end
    end
  end

end
