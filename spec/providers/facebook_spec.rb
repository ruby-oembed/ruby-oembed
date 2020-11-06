require File.join(File.dirname(__FILE__), '../spec_helper')

describe 'Facebook providers' do
  let(:access_token) { 'my-fake-access-token' }

  describe 'FacebookPost provider' do
    let(:provider) { OEmbed::Providers::FacebookPost.new(access_token: access_token) }
    let(:embed_url) { 'https://www.facebook.com/exampleuser/posts/1234567890' }

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
end
