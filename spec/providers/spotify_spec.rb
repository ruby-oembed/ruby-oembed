require 'spec_helper'

describe 'OEmbed::Providers::Spotify' do
  use_custom_vcr_casette('OEmbed_Providers_Spotify')
  include OEmbedSpecHelper

  let(:provider) { OEmbed::Providers::Spotify }

  expected_valid_urls = [
    'https://open.spotify.com/track/7y8NWS6gR3Wz4C7W8Bh0WL?si=aa84a1d637ac4b3d',
  ]
  expected_invalid_urls = [
  ]

  describe 'behaving like an OEmbed::Provider instance' do
    it_should_behave_like(
      "an OEmbed::Providers instance",
      expected_valid_urls,
      expected_invalid_urls
    )
  end
end
