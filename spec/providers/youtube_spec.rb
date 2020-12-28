require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'OEmbed::Providers::Youtube' do
  before(:all) do
    VCR.insert_cassette('OEmbed_Providers_Youtube')
  end
  after(:all) do
    VCR.eject_cassette
  end

  include OEmbedSpecHelper

  let(:provider_class) { OEmbed::Providers::Youtube }

  expected_valid_urls = %w(
    https://www.youtube.com/watch?v=pO5L6vXtxsI
    http://www.youtube.com/watch?v=pO5L6vXtxsI
    https://youtu.be/pO5L6vXtxsI
  )
  expected_invalid_urls = [
    # Unrecognized hostname
    'https://www.youtube.co.uk/watch?v=pO5L6vXtxsI',
  ]

  it_should_behave_like(
    "an OEmbed::Providers instance",
    expected_valid_urls,
    expected_invalid_urls
  )

  describe ".get" do
    context 'given the URL of a private video' do
      let(:invalid_url) { 'https://youtu.be/NHriYTkvd0g' }

      it "should throw an UnknownResponse error" do
        expect {
          provider_class.get(invalid_url)
        }.to raise_error(OEmbed::UnknownResponse, /403/)
      end
    end
  end
end
