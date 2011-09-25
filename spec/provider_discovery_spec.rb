require File.dirname(__FILE__) + '/spec_helper'
require 'vcr'

VCR.config do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.stub_with :fakeweb
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end

describe OEmbed::ProviderDiscovery do
  include OEmbedSpecHelper
  
  before(:all) do
    @wordpress_url = 'http://sweetandweak.wordpress.com/2011/09/23/nothing-starts-the-morning-like-a-good-dose-of-panic/'
  end
  
  describe "discover_provider" do
    use_vcr_cassette
    
    it "should return an OEmbed::Provider" do
      OEmbed::ProviderDiscovery.discover_provider(@wordpress_url).should be_instance_of(OEmbed::Provider)
    end
    
    it "should detect the correct URL" do
      provider = OEmbed::ProviderDiscovery.discover_provider(@wordpress_url)
      provider.endpoint.should eq('http://public-api.wordpress.com/oembed/1.0/')
    end
    
    it "should return the first format it comes to" do
      provider = OEmbed::ProviderDiscovery.discover_provider(@wordpress_url)
      provider.format.should eq(:json)
    end
    
    it "should return the format requested" do
      provider = OEmbed::ProviderDiscovery.discover_provider(@wordpress_url, :format=>:xml)
      provider.endpoint.should eq('http://public-api.wordpress.com/oembed/1.0/')
      provider.format.should eq(:xml)
    end
  end # discover_provider
end