require 'spec_helper'

describe 'OEmbed::Providers::Matterport' do
  use_custom_vcr_casette('OEmbed_Providers_Matterport')
  include OEmbedSpecHelper

  let(:provider) { OEmbed::Providers::Matterport }

  expected_valid_urls = %w(
    https://my.matterport.com/show/?m=FmDYedjofjo
  )
  expected_invalid_urls = %w(
    https://matterport.com/discover/space/7ffnfBNamei
  )

  describe 'behaving like an OEmbed::Provider instance' do
    it_should_behave_like(
      "an OEmbed::Providers instance",
      expected_valid_urls,
      expected_invalid_urls
    )
  end
end
