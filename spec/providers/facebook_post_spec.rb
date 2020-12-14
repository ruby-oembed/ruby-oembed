require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'OEmbed::Providers::FacebookPost' do
  use_custom_vcr_casette('OEmbed_Providers_FacebookPost')
  include OEmbedSpecHelper

  let(:provider) { OEmbed::Providers::FacebookPost }

  expected_valid_urls = [
    # A public "post" by a "page"
    'https://www.facebook.com/rubyonrailstogo/posts/3610333842332884',
    # A public "note"
    'https://www.facebook.com/notes/facebook-app/welcome-to-the-facebook-blog/2207517130/',
    # A specific photo
    'https://www.facebook.com/tumocenter/photos/bc.AbpR7-R7Lu6GodUph_UNg1Ttn-k7Ni-M8X89Io4cWsYkK0OPde6MTVKHSiTNDEanWYkwQGyu-YwpNnS4MXUqeYen_ovuiBPQixaA-tjNBcVUFAMWPaxX-NU1mm2ovExEORQOdohcH339Xmxch3kbSPcJ/1084373708267461/',
    # A photo in slideshow view
    'https://www.facebook.com/photo/?fbid=3348617585198325&set=gm.1675022489341591',
  ]
  expected_invalid_urls = %w(
    https://www.instagram.com/p/B9bOM-6Ax_d/?igshid=1mn51zsvrhoiq
    https://www.facebook.com/381763475170840/videos/474308113397163/
    https://www.facebook.com/groups/rordevelopers/permalink/1675022489341591/
    https://www.facebook.com/business/news/tips-small-business-digital-tools-in-crisis-and-recovery-report-deloitte/
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
