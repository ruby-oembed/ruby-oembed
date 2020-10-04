require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'Facebook providers' do
  let(:access_token) { 'my-fake-access-token' }
  let(:embed_url) { 'https://www.facebook.com/exampleuser/posts/1234567890' }

  describe 'FacebookPost provider' do
    let(:provider) { OEmbed::Providers::FacebookPost.new(access_token: access_token) }

    it 'sets the endpoint URL' do
      expect(provider.endpoint).to(
        eq("https://graph.facebook.com/v8.0/oembed_post?access_token=#{access_token}")
      )
    end

    it 'recognizes embed URLs' do
      expect(provider).to include(embed_url)
    end
  end

  describe 'FacebookVideo provider' do
    let(:provider) { OEmbed::Providers::FacebookVideo.new(access_token: access_token) }
    let(:embed_url) { 'https://www.facebook.com/exampleuser/videos/1234567890' }

    it 'sets the endpoint URL' do
      expect(provider.endpoint).to(
        eq("https://graph.facebook.com/v8.0/oembed_video?access_token=#{access_token}")
      )
    end

    it 'recognizes embed URLs' do
      expect(provider).to include(embed_url)
    end
  end

  describe 'Instagram provider' do
    let(:provider) { OEmbed::Providers::Instagram.new(access_token: access_token) }
    let(:embed_url) { 'https://www.instagram.com/p/r4nd0m1mg/' }

    it 'sets the endpoint URL' do
      expect(provider.endpoint).to(
        eq("https://graph.facebook.com/v8.0/instagram_oembed?access_token=#{access_token}")
      )
    end

    it 'recognizes embed URLs' do
      expect(provider).to include(embed_url)
    end
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

      it { is_expected.to be_a(OEmbed::Providers::FacebookPost) }
    end

    context 'when access token is set as an environment variable' do
      before do
        ENV['OEMBED_FACEBOOK_TOKEN'] = access_token
        OEmbed::Providers.register_all
      end

      it { is_expected.to be_a(OEmbed::Providers::FacebookPost) }
    end

    context 'without access token' do
      before { OEmbed::Providers.register_all }

      it { is_expected.to eq(nil) }
    end
  end
end
