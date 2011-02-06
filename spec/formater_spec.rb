require File.dirname(__FILE__) + '/spec_helper'
require 'json'
require 'xmlsimple'


describe OEmbed::Formatter do
  include OEmbedSpecHelper

  before(:all) do

  end

  it "should support JSON" do
    proc { OEmbed::Formatter.support?(:json) }.
    should_not raise_error(OEmbed::FormatNotSupported)
  end
  
  it "should default to JSON" do
    OEmbed::Formatter.default.should == 'json'
  end
  
  it "should decode a JSON String" do
    object = {'a'=>'one'}
    string = object.to_json
    OEmbed::Formatter.decode(:json, string).should == object
  end
  
  it "should support XML" do
    proc { OEmbed::Formatter.support?(:xml) }.
    should_not raise_error(OEmbed::FormatNotSupported)
  end
  
  it "should decode an XML String" do
    object = {'a'=>'one'}
    string = XmlSimple.xml_out(object)
    OEmbed::Formatter.decode(:xml, string).should == object
  end
end