require 'json'
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
    # 'name' => [
    #   'given_page_url',
    #   'expected_endpoint' || {:json=>'expected_json_endpoint', :xml=>'expected_xml_endpoint},
    #   :expected_format,
    # ]
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
    'facebook-photo' => [
      'https://www.facebook.com/Federer/photos/pb.64760994940.-2207520000.1456668968./10153235368269941/?type=3&theater',
      'https://www.facebook.com/plugins/post/oembed.json/',
      :json,
    ],
    'tumblr' => [
      'http://kittehkats.tumblr.com/post/140525169406/katydid-and-the-egg-happy-forest-family',
      'https://www.tumblr.com/oembed/1.0',
      :json
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
    expected_endpoints = expected_endpoint.is_a?(Hash) ? expected_endpoint.keys : [expected_format]

    context "with #{context} url" do

      describe ".discover_provider" do

        before(:all) do
          @provider_default = OEmbed::ProviderDiscovery.discover_provider(given_url)
          if expected_endpoints.include?(:json)
            @provider_json = OEmbed::ProviderDiscovery.discover_provider(given_url, :format=>:json)
          end
          if expected_endpoints.include?(:xml)
            @provider_xml = OEmbed::ProviderDiscovery.discover_provider(given_url, :format=>:xml)
          end
        end

        it "should return the correct Class" do
          expect(@provider_default).to be_instance_of(OEmbed::Provider)
          if expected_endpoints.include?(:json)
            expect(@provider_json).to be_instance_of(OEmbed::Provider)
          end
          if expected_endpoints.include?(:xml)
            expect(@provider_xml).to be_instance_of(OEmbed::Provider)
          end
        end

        it "should detect the correct URL" do
          if expected_endpoint.is_a?(Hash)
            expect(@provider_json.endpoint).to eq(expected_endpoint[expected_format])
            expect(@provider_json.endpoint).to eq(expected_endpoint[:json])
            expect(@provider_xml.endpoint).to eq(expected_endpoint[:xml])
          else
            expect(@provider_default.endpoint).to eq(expected_endpoint)
            if expected_endpoints.include?(:json)
              expect(@provider_json.endpoint).to eq(expected_endpoint)
            end
            if expected_endpoints.include?(:xml)
              expect(@provider_xml.endpoint).to eq(expected_endpoint)
            end
          end
        end

        it "should return the correct format" do
          expect(@provider_default.format).to eq(expected_format)
          if expected_endpoints.include?(:json)
            expect(@provider_json.format).to eq(:json)
          end
          if expected_endpoints.include?(:xml)
            expect(@provider_xml.format).to eq(:xml)
          end
        end
      end # discover_provider

      describe ".get" do

        before(:all) do
          @response_default = OEmbed::ProviderDiscovery.get(given_url)
          if expected_endpoints.include?(:json)
            @response_json = OEmbed::ProviderDiscovery.get(given_url, :format=>:json)
          end
          if expected_endpoints.include?(:xml)
            @response_xml = OEmbed::ProviderDiscovery.get(given_url, :format=>:xml)
          end
        end

        it "should return the correct Class" do
          expect(@response_default).to be_kind_of(OEmbed::Response)
          if expected_endpoints.include?(:json)
            expect(@response_json).to be_kind_of(OEmbed::Response)
          end
          if expected_endpoints.include?(:xml)
            expect(@response_xml).to be_kind_of(OEmbed::Response)
          end
        end

        it "should return the correct format" do
          expect(@response_default.format).to eq(expected_format.to_s)
          if expected_endpoints.include?(:json)
            expect(@response_json.format).to eq('json')
          end
          if expected_endpoints.include?(:xml)
            expect(@response_xml.format).to eq('xml')
          end
        end

        it "should return the correct data" do
          expect(@response_default.type).to_not be_nil
          if expected_endpoints.include?(:json)
            expect(@response_json.type).to_not be_nil
          end
          if expected_endpoints.include?(:xml)
            expect(@response_xml.type).to_not be_nil
          end

          # Technically, the following values _could_ be blank, but for the
          # examples urls we're using we expect them not to be.
          expect(@response_default.title).to_not be_nil
          if expected_endpoints.include?(:json)
            expect(@response_json.title).to_not be_nil
          end
          if expected_endpoints.include?(:xml)
            expect(@response_xml.title).to_not be_nil
          end
        end
      end # get
    end

  end # each service

  context "when returning 404" do
    let(:url) { 'https://www.youtube.com/watch?v=123123123' }

    it "raises OEmbed::NotFound" do
      expect{ OEmbed::ProviderDiscovery.discover_provider(url) }.to raise_error(OEmbed::NotFound)
    end
  end

  context "when returning 301" do
    let(:url) { 'http://www.youtube.com/watch?v=dFs9WO2B8uI' }

    it "does redirect http to https" do
      expect{ OEmbed::ProviderDiscovery.discover_provider(url) }.not_to raise_error
    end
  end

  it "does passes the timeout option to Net::Http" do
    expect_any_instance_of(Net::HTTP).to receive(:open_timeout=).with(5)
    expect_any_instance_of(Net::HTTP).to receive(:read_timeout=).with(5)
    OEmbed::ProviderDiscovery.discover_provider('https://www.youtube.com/watch?v=dFs9WO2B8uI', :timeout => 5)
  end
end
