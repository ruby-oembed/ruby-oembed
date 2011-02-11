require File.dirname(__FILE__) + '/spec_helper'

describe OEmbed::Formatter do
  include OEmbedSpecHelper

  it "should support JSON" do
    proc { OEmbed::Formatter.support?(:json) }.
    should_not raise_error(OEmbed::FormatNotSupported)
  end
  
  it "should default to JSON" do
    OEmbed::Formatter.default.should == 'json'
  end
  
  it "should decode a JSON String" do
    decoded = OEmbed::Formatter.decode(:json, valid_response(:json))
    # We need to compare keys & values separately because we don't expect all
    # non-string values to be recognized correctly.
    decoded.keys.should == valid_response(:object).keys
    decoded.values.map{|v|v.to_s}.should == valid_response(:object).values.map{|v|v.to_s}
  end
  
  it "should support XML" do
    proc { OEmbed::Formatter.support?(:xml) }.
    should_not raise_error(OEmbed::FormatNotSupported)
  end
  
  it "should decode an XML String" do
    decoded = OEmbed::Formatter.decode(:xml, valid_response(:xml))
    # We need to compare keys & values separately because we don't expect all
    # non-string values to be recognized correctly.
    decoded.keys.should == valid_response(:object).keys
    decoded.values.map{|v|v.to_s}.should == valid_response(:object).values.map{|v|v.to_s}
  end
end