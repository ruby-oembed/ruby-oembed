require File.dirname(__FILE__) + '/spec_helper'
require 'json'
require 'xml_simple'


describe OEmbed::Formatter do
  include OEmbedSpecHelper

  before(:all) do

  end

  it "should support JSON" do
    proc { OEmbed::Formatter.support?(:json) }.
    should_not raise_error(OEmbed::FormatNotSupported)
  end
  
  it "should decode a JSON String" do
    object = {'a'=>'one'}
    string = JSON.encode(object)
    OEmbed::Formatter.decode(:json, string).should equal object
  end
  
  it "should support XML" do
    proc { OEmbed::Formatter.support?(:xml) }.
    should_not raise_error(OEmbed::FormatNotSupported)
  end
end