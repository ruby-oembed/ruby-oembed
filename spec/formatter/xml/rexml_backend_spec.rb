require File.dirname(__FILE__) + '/../../spec_helper'

describe "OEmbed::Formatter::XML::Backends::REXML" do
  include OEmbedSpecHelper

  before(:all) do
    lambda {
      OEmbed::Formatter::XML.backend = 'REXML'
    }.should_not raise_error
    
    (!!defined?(REXML)).should == true
  end

  it "should support XML" do
    proc { OEmbed::Formatter.support?(:xml) }.
    should_not raise_error(OEmbed::FormatNotSupported)
  end
  
  it "should be using the XmlSimple backend" do
    OEmbed::Formatter::XML.backend.should == OEmbed::Formatter::XML::Backends::REXML
  end
  
  it "should decode an XML String" do
    decoded = OEmbed::Formatter.decode(:xml, valid_response(:xml))
    # We need to compare keys & values separately because we don't expect all
    # non-string values to be recognized correctly.
    decoded.keys.should == valid_response(:object).keys
    decoded.values.map{|v|v.to_s}.should == valid_response(:object).values.map{|v|v.to_s}
  end
end