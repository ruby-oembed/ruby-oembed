require File.join(File.dirname(__FILE__), '../spec_helper')
require 'support/shared_examples_for_providers'

describe 'OEmbed::Providers::Noembed' do
  before(:all) do
    VCR.insert_cassette('OEmbed_Providers_Noembed')
  end
  after(:all) do
    VCR.eject_cassette
  end

  include OEmbedSpecHelper

  let(:provider_class) { OEmbed::Providers::Noembed }

  expected_valid_urls = [
    'https://twitter.com/RailsGirlsSoC/status/702136612822634496',
    'https://mobile.twitter.com/bpoweski/status/71633762',
    # Note: Real-world Onion articles are now https and use "/article/" singular
    # but Noembed doesn't currently support that URL parttern.
    'http://www.theonion.com/articles/new-poll-finds-majority-of-americans-thought-wed-l-33412',
    'http://amzn.com/B00X4WHP5E',
    # Note: Real-world Instagram URLs appear to always use the www subdomain
    # but Noembed doesn't currently support that URL pattern.
    'https://instagram.com/p/BCJslIGxvfB/',
    'http://instagr.am/p/BCJslIGxvfB'
  ]
  expected_invalid_urls = %w(
    https://twitter.es/FCBarcelona_es/status/734194638697959424
  )

  it_should_behave_like(
    'an OEmbed::Proviers instance',
    expected_valid_urls,
    expected_invalid_urls
  )
end
