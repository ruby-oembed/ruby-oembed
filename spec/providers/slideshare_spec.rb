require File.join(File.dirname(__FILE__), '../spec_helper')
require 'support/shared_examples_for_providers'

describe 'OEmbed::Providers::Slideshare' do
  before(:all) do
    VCR.insert_cassette('OEmbed_Providers_Slideshare')
  end
  after(:all) do
    VCR.eject_cassette
  end

  include OEmbedSpecHelper

  let(:provider_class) { OEmbed::Providers::Slideshare }

  expected_valid_urls = (
    %w(https:// http://).map do |protocol|
      %w(slideshare.net www.slideshare.net de.slideshare.net).map do |host|
        %w(
          /gabriele.lana/the-magic-of-elixir
          /mobile/gabriele.lana/the-magic-of-elixir
        ).map do |path|
          File.join(protocol, host, path)
        end
      end
    end
  ).flatten

  expected_invalid_urls = %w(
    http://twitter.com/RailsGirlsSoC/status/702136612822634496
    https://twitter.es/FCBarcelona_es/status/734194638697959424
  )

  it_should_behave_like(
    "an OEmbed::Proviers instance",
    expected_valid_urls,
    expected_invalid_urls
  )
end
