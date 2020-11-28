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

  describe 'behaving like a custom OEmbed::Provider class' do
    let(:access_token) { 'my-fake-access-token' }
    let(:provider_instance) { provider.new(access_token: access_token) }
    let(:embed_url) { expected_valid_urls.first }

    it 'sets the endpoint URL' do
      expect(provider_instance.endpoint).to(
        eq("https://graph.facebook.com/v8.0/instagram_oembed?access_token=#{access_token}")
      )
    end

    it 'recognizes embed URLs' do
      expect(provider_instance).to include(embed_url)
    end
  end

  describe 'behaving like an OEmbed::Provider instance' do
    it_should_behave_like(
      "an OEmbed::Providers instance",
      expected_valid_urls,
      expected_invalid_urls
    )
  end
end
