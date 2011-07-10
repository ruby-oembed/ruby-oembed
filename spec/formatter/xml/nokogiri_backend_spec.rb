require File.dirname(__FILE__) + '/../../spec_helper'

describe "OEmbed::Formatter::XML::Backends::Nokogiri" do
  include OEmbedSpecHelper

  before(:all) do
    lambda {
      OEmbed::Formatter::XML.backend = 'Nokogiri'
    }.should raise_error(LoadError)
    
    require 'nokogiri'
    
    lambda {
      OEmbed::Formatter::XML.backend = 'Nokogiri'
    }.should_not raise_error
  end

  it "should support XML" do
    proc { OEmbed::Formatter.supported?(:xml) }.
    should_not raise_error(OEmbed::FormatNotSupported)
  end
  
  it "should be using the Nokogiri backend" do
    OEmbed::Formatter::XML.backend.should == OEmbed::Formatter::XML::Backends::Nokogiri
  end
  
  it "should decode an XML String" do
    decoded = OEmbed::Formatter.decode(:xml, valid_response(:xml))
    # We need to compare keys & values separately because we don't expect all
    # non-string values to be recognized correctly.
    decoded.keys.should == valid_response(:object).keys
    decoded.values.map{|v|v.to_s}.should == valid_response(:object).values.map{|v|v.to_s}
  end
  
  it "should raise an OEmbed::ParseError when decoding an invalid XML String" do
    lambda {
      decode = OEmbed::Formatter.decode(:xml, invalid_response('unclosed_container', :xml))
    }.should raise_error(OEmbed::ParseError)
    lambda {
      decode = OEmbed::Formatter.decode(:xml, invalid_response('unclosed_tag', :xml))
    }.should raise_error(OEmbed::ParseError)
    lambda {
      decode = OEmbed::Formatter.decode(:xml, invalid_response('invalid_syntax', :xml))
    }.should raise_error(OEmbed::ParseError)
  end
  
  it "should raise an OEmbed::ParseError when decoding fails with an unexpected error" do
    error_to_raise = ArgumentError
    OEmbed::Formatter::XML.backend.parse_error.should_not be_kind_of(error_to_raise)
    
    ::Nokogiri::XML::Document.should_receive(:parse).
      and_raise(error_to_raise.new("unknown error"))
    
    lambda {
      decode = OEmbed::Formatter.decode(:xml, valid_response(:xml))
    }.should raise_error(OEmbed::ParseError)
  end
end