require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'OEmbed::Providers::Instagram' do
  use_custom_vcr_casette('OEmbed_Providers_Instagram')
  include OEmbedSpecHelper

  let(:provider) { OEmbed::Providers::Instagram }

  expected_valid_urls = %w(
    https://www.instagram.com/p/B9bOM-6Ax_d/?igshid=1mn51zsvrhoiq
    https://www.instagram.com/tv/CCX-gcHArcJ/?igshid=1i0rst4jaz0j
  )
  expected_invalid_urls = %w(
    https://www.instagram.com/u/CCX-gcHArcJ/?igshid=1i0rst4jaz0j
  )

  describe 'behaving like an OEmbed::Provider instance' do
    it_should_behave_like(
      "an OEmbed::Providers instance",
      expected_valid_urls,
      expected_invalid_urls
    )
  end

  describe 'DEPRECATED: behaves like a custom OEmbed::Provider class for v0.14.0 backwards compatibility' do
    around(:each) { |example|
      # Always restore the provider's access_token to its previous value
      # so that if the OEMBED_FACEBOOK_TOKEN env var is set, it's used correctly.
      orig_access_token = provider.access_token
      example.run
      provider.access_token = orig_access_token
    }
    let(:access_token) { 'A_FAKE_TOKEN_FOR_TESTS' }
    let(:provider_instance) { provider.new(access_token: access_token) }
    let(:embed_url) { expected_valid_urls.first }

    it 'sets the access_token' do
      expect(provider_instance.access_token).to eq(access_token)
    end

    it 'recognizes embed URLs' do
      expect(provider_instance).to include(embed_url)
    end
  end
end
