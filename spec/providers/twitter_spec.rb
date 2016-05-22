require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'OEmbed::Providers::Twitter' do
  before(:all) do
    VCR.insert_cassette('OEmbed_Providers_Twitter')
  end
  after(:all) do
    VCR.eject_cassette
  end

  include OEmbedSpecHelper

  expected_valid_urls = %w(
    https://twitter.com/RailsGirlsSoC/status/702136612822634496
    https://www.twitter.com/bpoweski/status/71633762
  )
  expected_invalid_urls = %w(
    http://twitter.com/RailsGirlsSoC/status/702136612822634496
    https://twitter.es/FCBarcelona_es/status/734194638697959424
  )

  expected_valid_urls.each do |valid_url|
    context "given the valid URL #{valid_url}" do
      describe ".include?" do
        it "should be true" do
          expect(OEmbed::Providers::Twitter.include?(valid_url)).to be_truthy
        end
      end

      describe ".get" do
        it "should return a response" do
          response = nil
          expect {
            response = OEmbed::Providers::Twitter.get(valid_url)
          }.to_not raise_error
          expect(response).to be_a(OEmbed::Response)
        end

        context "using XML" do
          it "should encounter a 410 error" do
            expect {
              OEmbed::Providers::Twitter.get(valid_url, :format=>:xml)
            }.to raise_error(OEmbed::UnknownResponse, /\b410\b/)
          end
        end
      end
    end
  end

  expected_invalid_urls.each do |invalid_url|
    context "given the invalid URL #{invalid_url}" do
      describe ".include?" do
        it "should be false" do
          expect(OEmbed::Providers::Twitter.include?(invalid_url)).to be_falsey
        end
      end

      describe ".get" do
        it "should not find a response" do
          expect {
            OEmbed::Providers::Twitter.get(invalid_url)
          }.to raise_error(OEmbed::NotFound)
        end
      end
    end
  end
end
