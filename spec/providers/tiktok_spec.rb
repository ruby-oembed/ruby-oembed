require 'spec_helper'

describe 'OEmbed::Providers::TikTok' do
  use_custom_vcr_casette('OEmbed_Providers_TikTok')
  include OEmbedSpecHelper

  let(:provider) { OEmbed::Providers::TikTok }

  expected_valid_urls = [
    'https://www.tiktok.com/@shmemmmy/video/7005293332821822726',
    # video via iOS share card doesn't work
    # 'https://vm.tiktok.com/TTPdMy6pFT/',
  ]
  expected_invalid_urls = [
    'https://tiktok.com/@shmemmmy/video/7005293332821822726', # www is required
    'https://www.tiktok.com/@shmemmmy',
    'https://www.tiktok.com/tag/softwaredeveloper',
    # hastag via iOS share card
    'https://vm.tiktok.com/TTPdMyY42G/',
  ]

  describe 'behaving like an OEmbed::Provider instance' do
    it_should_behave_like(
      "an OEmbed::Providers instance",
      expected_valid_urls,
      expected_invalid_urls
    )
  end
end
