require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'OEmbed::Providers::Twitter' do
  use_custom_vcr_casette('OEmbed_Providers_Twitter')
  include OEmbedSpecHelper

  subject { OEmbed::Providers::Twitter }

  expected_valid_urls = %w(
    https://twitter.com/RailsGirlsSoC/status/702136612822634496
    https://www.twitter.com/bpoweski/status/71633762
  )
  expected_invalid_urls = %w(
    http://twitter.com/RailsGirlsSoC/status/702136612822634496
    https://twitter.es/FCBarcelona_es/status/734194638697959424
  )

  it_should_behave_like(
    "an OEmbed::Proviers instance",
    expected_valid_urls,
    expected_invalid_urls
  )

  context "using XML" do
    expected_valid_urls.each do |valid_url|
      context "given the valid URL #{valid_url}" do
        describe ".get" do
          it "should encounter a 400 error" do
            expect {
              subject.get(valid_url, :format=>:xml)
            }.to raise_error(OEmbed::UnknownResponse, /\b400\b/)
          end
        end
      end
    end
  end
end
