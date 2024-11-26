require 'spec_helper'

describe 'OEmbed::Providers::Spotify' do
  use_custom_vcr_casette('OEmbed_Providers_Spotify')
  include OEmbedSpecHelper

  let(:provider) { OEmbed::Providers::Spotify }

  expected_valid_urls = [
    # Track
    'https://open.spotify.com/track/7y8NWS6gR3Wz4C7W8Bh0WL?si=aa84a1d637ac4b3d',
    # Track with play.spotify.com
    'https://play.spotify.com/track/7y8NWS6gR3Wz4C7W8Bh0WL?si=aa84a1d637ac4b3d',
    # Artist
    'https://open.spotify.com/artist/1TTfuOdEtj8lin2zR4OWmP?si=NoNEzt24RtyGKIg77zXf8g',
    # Artist via Spotify URI
    'spotify:artist:1TTfuOdEtj8lin2zR4OWmP?si=NoNEzt24RtyGKIg77zXf8g',
    # Podcast: Show
    'https://open.spotify.com/show/0gWT8X6lgGuJkpcx0XJ3yr',
    # Podcast: Episode
    'https://open.spotify.com/episode/6z1oAq0SxQ6jPUiLQMEDC6?si=2DUQZ9taQuKaCXGTa48uNw',
  ]
  expected_invalid_urls = [
  ]

  describe 'behaving like an OEmbed::Provider instance' do
    it_should_behave_like(
      "an OEmbed::Providers instance",
      expected_valid_urls,
      expected_invalid_urls
    )

    it "should raise NotFound for a private playlist" do
      expect {
        # A private playlist
        provider.get('https://open.spotify.com/playlist/5HcLrk4q1DPf9CucFfGLWF')
      }.to raise_error(OEmbed::NotFound)
    end
  end
end
