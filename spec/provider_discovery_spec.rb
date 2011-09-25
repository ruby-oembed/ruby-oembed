require File.dirname(__FILE__) + '/spec_helper'
require 'vcr'

VCR.config do |c|
  c.default_cassette_options = { :record => :new_episodes }
  c.cassette_library_dir = 'spec/cassettes'
  c.stub_with :fakeweb
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end

describe OEmbed::ProviderDiscovery do
  include OEmbedSpecHelper
  
  {
    'youtube' => [
      'http://www.youtube.com/watch?v=u6XAPnuFjJc',
      'http://www.youtube.com/oembed',
      :json,
    ],
    #'noteflight' => 'http://www.noteflight.com/scores/view/09665392c94475f65dfaf5f30aadb6ed0921939d',
    #'wordpress' => 'http://sweetandweak.wordpress.com/2011/09/23/nothing-starts-the-morning-like-a-good-dose-of-panic/',
  }.each do |context, urls|
    
    given_url, expected_endpoint, expected_format = urls
    
    context "with #{context} url" do
      describe "discover_provider" do
        use_vcr_cassette

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
          @provider_default.endpoint.should eq(expected_endpoint)
          @provider_json.endpoint.should eq(expected_endpoint)
          @provider_xml.endpoint.should eq(expected_endpoint)
        end

        it "should return the correct format" do
          @provider_default.format.should eq(expected_format)
          @provider_json.format.should eq(:json)
          @provider_xml.format.should eq(:xml)
        end
      end # discover_provider

      describe "get" do

        before(:all) do
          use_vcr_cassette
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
    
  end
  
  #before(:all) do
  #  @wordpress_url = 'http://sweetandweak.wordpress.com/2011/09/23/nothing-starts-the-morning-like-a-good-dose-of-panic/'
  #end
  
  
end