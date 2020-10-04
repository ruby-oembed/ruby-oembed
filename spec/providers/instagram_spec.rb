require File.join(File.dirname(__FILE__), '../spec_helper')

describe OEmbed::Providers::Instagram do
  let(:access_token) { 'my-fake-access-token' }
  let(:provider) { described_class.new(access_token: access_token) }
  let(:embed_url) { 'https://www.instagram.com/p/r4nd0m1mg/' }

  it 'sets the endpoint URL' do
    expect(provider.endpoint).to(
      eq("https://graph.facebook.com/v8.0/instagram_oembed?access_token=#{access_token}")
    )
  end

  it 'recognizes Instagram URLs' do
    expect(provider).to include(embed_url)
  end

  describe 'registering as default provider' do
    around(:each) do |each|
      previous_value = ENV['OEMBED_FACEBOOK_TOKEN']
      ENV['OEMBED_FACEBOOK_TOKEN'] = nil
      each.run
      ENV['OEMBED_FACEBOOK_TOKEN'] = previous_value
      OEmbed::Providers.unregister_all
    end

    subject { OEmbed::Providers.find(embed_url) }

    context 'when access token is provided to register_all' do
      before do
        OEmbed::Providers.register_all(access_tokens: { facebook: access_token })
      end

      it { is_expected.to be_a(described_class) }
    end

    context 'when access token is set as an environment variable' do
      before do
        ENV['OEMBED_FACEBOOK_TOKEN'] = access_token
        OEmbed::Providers.register_all
      end

      it { is_expected.to be_a(described_class) }
    end

    context 'without access token' do
      before { OEmbed::Providers.register_all }

      it { is_expected.to eq(nil) }
    end
  end
end
