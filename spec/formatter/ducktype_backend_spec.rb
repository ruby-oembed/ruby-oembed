require File.dirname(__FILE__) + '/../spec_helper'

class WorkingDuck
  # The WorkingDuck Class should work as a Backend
  class << self
    # Fakes a correct deocde response
    def decode(value)
      {"version"=>1.0, "string"=>"test", "int"=>42, "html"=>"<i>Cool's</i>\n the \"word\"!",}
    end
    def parse_error; RuntimeError; end
  end
  
  # A WorkingDuck instance should work as a Backend
  def decode(value)
    self.class.decode(value)
  end
  def parse_error; RuntimeError; end
end

class FailingDuckDecode
  # Fakes an incorrect decode response
  def decode(value)
    {}
  end
  def parse_error; RuntimeError; end
end

describe "OEmbed::Formatter::JSON::Backends::DuckType" do
  include OEmbedSpecHelper

  it "should work with WorkingDuck Class" do
    lambda {
      OEmbed::Formatter::JSON.backend = WorkingDuck
    }.should_not raise_error
    OEmbed::Formatter::JSON.backend.should equal(WorkingDuck)
  end
  
  it "should work with a WorkingDuck instance" do
    instance = WorkingDuck.new
    lambda {
      OEmbed::Formatter::JSON.backend = instance
    }.should_not raise_error
    OEmbed::Formatter::JSON.backend.should equal(instance)
  end
  
  it "should fail with FailingDuckDecode Class" do
    lambda {
      OEmbed::Formatter::JSON.backend = FailingDuckDecode
    }.should raise_error(LoadError)
    OEmbed::Formatter::JSON.backend.should_not equal(FailingDuckDecode)
  end
  
  it "should fail with a FailingDuckDecode instance" do
    instance = FailingDuckDecode.new
    lambda {
      OEmbed::Formatter::JSON.backend = instance
    }.should raise_error(LoadError)
    OEmbed::Formatter::JSON.backend.should_not equal(instance)
  end
end

describe "OEmbed::Formatter::XML::Backends::DuckType" do
  include OEmbedSpecHelper

  it "should work with WorkingDuck Class" do
    lambda {
      OEmbed::Formatter::XML.backend = WorkingDuck
    }.should_not raise_error
    OEmbed::Formatter::XML.backend.should equal(WorkingDuck)
  end
  
  it "should work with a WorkingDuck instance" do
    instance = WorkingDuck.new
    lambda {
      OEmbed::Formatter::XML.backend = instance
    }.should_not raise_error
    OEmbed::Formatter::XML.backend.should equal(instance)
  end
  
  it "should fail with FailingDuckDecode Class" do
    lambda {
      OEmbed::Formatter::XML.backend = FailingDuckDecode
    }.should raise_error(LoadError)
    OEmbed::Formatter::XML.backend.should_not equal(FailingDuckDecode)
  end
  
  it "should fail with a FailingDuckDecode instance" do
    instance = FailingDuckDecode.new
    lambda {
      OEmbed::Formatter::XML.backend = instance
    }.should raise_error(LoadError)
    OEmbed::Formatter::XML.backend.should_not equal(instance)
  end
end