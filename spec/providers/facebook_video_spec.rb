require "spec_helper"

describe "OEmbed::Providers::FacebookVideo" do
  use_custom_vcr_casette("OEmbed_Providers_FacebookVideo")
  include OEmbedSpecHelper

  let(:provider) { OEmbed::Providers::FacebookVideo }

  expected_valid_urls = %w[
    https://www.facebook.com/381763475170840/videos/474308113397163/
    https://www.facebook.com/osherove/videos/10157895173751223/
  ]
  expected_invalid_urls = %w[
    https://www.instagram.com/p/B9bOM-6Ax_d/?igshid=1mn51zsvrhoiq
    https://www.facebook.com/rubyonrailstogo/posts/3610333842332884
    https://www.facebook.com/groups/rordevelopers/permalink/1675022489341591/
    https://www.facebook.com/business/news/tips-small-business-digital-tools-in-crisis-and-recovery-report-deloitte/
  ]

  describe "behaving like an OEmbed::Provider instance" do
    it_should_behave_like(
      "an OEmbed::Providers instance",
      expected_valid_urls,
      expected_invalid_urls
    )
  end

  describe "DEPRECATED: behaves like a custom OEmbed::Provider class for v0.14.0 backwards compatibility" do
    around(:each) { |example|
      # Always restore the provider's access_token to its previous value
      # so that if the OEMBED_FACEBOOK_TOKEN env var is set, it's used correctly.
      orig_access_token = provider.access_token
      example.run
      provider.access_token = orig_access_token
    }
    let(:access_token) { "A_FAKE_TOKEN_FOR_TESTS" }
    let(:provider_instance) { provider.new(access_token: access_token) }
    let(:embed_url) { expected_valid_urls.first }

    it "sets the access_token" do
      expect(provider_instance.access_token).to eq(access_token)
    end

    it "recognizes embed URLs" do
      expect(provider_instance).to include(embed_url)
    end
  end
end
