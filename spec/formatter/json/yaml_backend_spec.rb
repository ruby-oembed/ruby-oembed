require File.dirname(__FILE__) + '/../../spec_helper'

describe "OEmbed::Formatter::JSON::Backends::Yaml" do
  include OEmbedSpecHelper

  before(:all) do
    lambda {
      OEmbed::Formatter::JSON.backend = 'Yaml'
    }.should_not raise_error
    
    (!!defined?(YAML)).should == true
  end

  it "should support JSON" do
    proc { OEmbed::Formatter.supported?(:json) }.
    should_not raise_error(OEmbed::FormatNotSupported)
  end
  
  it "should be using the Yaml backend" do
    OEmbed::Formatter::JSON.backend.should == OEmbed::Formatter::JSON::Backends::Yaml
  end
  
  it "should decode a JSON String" do
    decoded = OEmbed::Formatter.decode(:json, valid_response(:json))
    # We need to compare keys & values separately because we don't expect all
    # non-string values to be recognized correctly.
    decoded.keys.should == valid_response(:object).keys
    decoded.values.map{|v|v.to_s}.should == valid_response(:object).values.map{|v|v.to_s}
  end
end