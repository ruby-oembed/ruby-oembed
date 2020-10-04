require File.join(File.dirname(__FILE__), '../spec_helper')
require 'support/shared_examples_for_providers'

describe OEmbed::Providers::FacebookPost do
  let(:access_token) { 'my-fake-access-token' }
  let(:provider) { described_class.new(access_token: access_token) }

  it 'sets the endpoint URL' do
    expect(provider.endpoint).to(
      eq("https://graph.facebook.com/v8.0/oembed_post?access_token=#{access_token}")
    )
  end

  it 'recognizes Facebook post URLs' do
    expect(provider).to include('https://www.facebook.com/exampleuser/posts/1234567890')
  end
end
