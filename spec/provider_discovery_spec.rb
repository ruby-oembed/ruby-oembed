require File.dirname(__FILE__) + '/spec_helper'
require 'vcr'

VCR.config do |c|
  c.default_cassette_options = { :record => :new_episodes }
  c.cassette_library_dir = 'spec/cassettes'
  c.stub_with :fakeweb
end

describe OEmbed::ProviderDiscovery do
  before(:all) do
    VCR.insert_cassette('OEmbed_ProviderDiscovery')
  end
  after(:all) do
    VCR.eject_cassette
  end
  
  include OEmbedSpecHelper
  
  {
    'youtube' => [
      'http://www.youtube.com/watch?v=u6XAPnuFjJc',
      'http://www.youtube.com/oembed',
      :json,
    ],
    'vimeo' => [
      'http://vimeo.com/27953845',
      {:json=>'http://vimeo.com/api/oembed.json',:xml=>'http://vimeo.com/api/oembed.xml'},
      :json,
    ],
    #'noteflight' => [
    #  'http://www.noteflight.com/scores/view/09665392c94475f65dfaf5f30aadb6ed0921939d',
    #  'http://www.noteflight.com/services/oembed',
    #  :json,
    #],
    #'wordpress' => [
    #  'http://sweetandweak.wordpress.com/2011/09/23/nothing-starts-the-morning-like-a-good-dose-of-panic/',
    #  'http://public-api.wordpress.com/oembed/1.0/',
    #  :json,
    #],
  }.each do |context, urls|
    
    given_url, expected_endpoint, expected_format = urls
    
    context "with #{context} url" do
      
      describe "discover_provider" do

        before(:all) do
          @provider_default = OEmbed::ProviderDiscovery.discover_provider(given_url)
          @provider_json = OEmbed::ProviderDiscovery.discover_provider(given_url, :format=>:json)
          @provider_xml = OEmbed::ProviderDiscovery.discover_provider(given_url, :format=>:xml)
        end

        it "should return the correct Class" do
          @provider_default.should be_instance_of(OEmbed::Provider)
          @provider_json.should be_instance_of(OEmbed::Provider)
          @provider_xml.should be_instance_of(OEmbed::Provider)
        end

        it "should detect the correct URL" do
          if expected_endpoint.is_a?(Hash)
            @provider_json.endpoint.should eq(expected_endpoint[expected_format])
            @provider_json.endpoint.should eq(expected_endpoint[:json])
            @provider_xml.endpoint.should eq(expected_endpoint[:xml])
          else
            @provider_default.endpoint.should eq(expected_endpoint)
            @provider_json.endpoint.should eq(expected_endpoint)
            @provider_xml.endpoint.should eq(expected_endpoint)
          end
        end

        it "should return the correct format" do
          @provider_default.format.should eq(expected_format)
          @provider_json.format.should eq(:json)
          @provider_xml.format.should eq(:xml)
        end
      end # discover_provider

      describe "get" do
      
        before(:all) do
          @response_default = OEmbed::ProviderDiscovery.get(given_url)
          @response_json = OEmbed::ProviderDiscovery.get(given_url, :format=>:json)
          @response_xml = OEmbed::ProviderDiscovery.get(given_url, :format=>:xml)
        end
      
        it "should return the correct Class" do
          @response_default.should be_kind_of(OEmbed::Response)
          @response_json.should be_kind_of(OEmbed::Response)
          @response_xml.should be_kind_of(OEmbed::Response)
        end
      
        it "should return the correct format" do
          @response_default.format.should eq(expected_format.to_s)
          @response_json.format.should eq('json')
          @response_xml.format.should eq('xml')
        end
      
        it "should return the correct data" do
          @response_default.type.should_not be_nil
          @response_json.type.should_not be_nil
          @response_xml.type.should_not be_nil
          
          # Technically, the following values _could_ be blank, but for the 
          # examples urls we're using we expect them not to be.
          @response_default.title.should_not be_nil
          @response_json.title.should_not be_nil
          @response_xml.title.should_not be_nil
        end
      end # get
    end
    
  end # each service
  
end