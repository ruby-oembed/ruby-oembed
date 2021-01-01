require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'OEmbed::Providers::TikTok' do
  use_custom_vcr_casette('OEmbed_Providers_TikTok')
  include OEmbedSpecHelper

  let(:provider) { OEmbed::Providers::TikTok }

  expected_valid_urls = [
    # Specific videos
    'https://www.tiktok.com/@sowylie/video/6903556111169899781',
    'https://www.tiktok.com/@cassidoo/video/6841722789502749957',
  ]
  expected_invalid_urls = [
    # An author's page
    'https://www.tiktok.com/@sowylie',
    # The safety page/docs
    'https://www.tiktok.com/safety?lang=en',
  ]

  it_should_behave_like(
    "an OEmbed::Providers instance",
    expected_valid_urls,
    expected_invalid_urls
  )
end
