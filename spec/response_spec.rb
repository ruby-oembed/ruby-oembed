require File.dirname(__FILE__) + '/spec_helper'

describe OEmbed::Response do
  before(:all) do
    data = <<-END
      {
        "type": "photo",
        "version": "1.0",
        "fields": "hello",
        "__id__": 1234
      }
    END
    @res = OEmbed::Response.new(data, OEmbed::Providers::Flickr)
  end
  
  it "should set the provider" do
    @res.provider.should == OEmbed::Providers::Flickr
  end
  
  it "should parse the data into #fields" do
    @res.fields.should == {
      "type" => "photo",
      "version" => "1.0",
      "fields" => "hello",
      "__id__" => 1234
    }
  end
  
  it "should access the data through #field" do
    @res.field(:type).should == "photo"
    @res.field(:version).should == "1.0"
    @res.field(:fields).should == "hello"
    @res.field(:__id__).should == 1234
  end
  
  it "should automagically define helpers" do
    @res.type.should == "photo"
    @res.version.should == "1.0"
  end
  
  it "should protect important methods" do
    @res.fields.should_not == @res.field(:fields)
    @res.__id__.should_not == @res.field(:__id__)
  end
end