require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'OEmbed::Providers::Slideshare' do
  use_custom_vcr_casette('OEmbed_Providers_Slideshare')
  include OEmbedSpecHelper

  let(:provider) { OEmbed::Providers::Slideshare }

  expected_valid_urls = (
    %w(https:// http://).map do |protocol|
      %w(slideshare.net www.slideshare.net de.slideshare.net).map do |host|
        [
          '/gabriele.lana/the-magic-of-elixir',
          # Even though Slideshare's oEmbed endpoint
          # is supposed to /mobile/ URLs,
          # as of 2016-05-21 it's returning 404 results for these URLs.
          #'/mobile/gabriele.lana/the-magic-of-elixir',
        ].map do |path|
          File.join(protocol, host, path)
        end
      end
    end
  ).flatten

  expected_invalid_urls = %w(
    http://www.slideshare.net
    http://www.slideshare.net/gabriele.lana
  )

  it_should_behave_like(
    "an OEmbed::Providers instance",
    expected_valid_urls,
    expected_invalid_urls
  )
end
