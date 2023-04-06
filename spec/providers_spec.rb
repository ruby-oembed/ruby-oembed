require "spec_helper"

describe OEmbed::Providers do
  include OEmbedSpecHelper

  before(:all) do
    @flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/")
    @qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}")

    @flickr << "http://*.flickr.com/*"
    @qik << "http://qik.com/video/*"
    @qik << "http://qik.com/*"
  end

  after(:each) do
    OEmbed::Providers.unregister_all
  end

  describe ".register" do
    it "should register multiple providers at once" do
      expect(OEmbed::Providers.urls).to be_empty

      OEmbed::Providers.register(@flickr, @qik)

      expect(OEmbed::Providers.urls.keys).to eq(@flickr.urls + @qik.urls)

      @flickr.urls.each do |regexp|
        expect(OEmbed::Providers.urls).to have_key(regexp)
        expect(OEmbed::Providers.urls[regexp]).to include(@flickr)
      end

      @qik.urls.each do |regexp|
        expect(OEmbed::Providers.urls).to have_key(regexp)
        expect(OEmbed::Providers.urls[regexp]).to include(@qik)
      end
    end

    it "should register providers with missing required_query_params" do
      expect(OEmbed::Providers.urls).to be_empty

      provider = OEmbed::Provider.new("http://foo.com/oembed", required_query_params: {send_with_query: nil})
      provider << "http://media.foo.com/*"

      OEmbed::Providers.register(provider)

      expect(OEmbed::Providers.urls.keys).to eq(provider.urls)

      provider.urls.each do |regexp|
        expect(OEmbed::Providers.urls).to have_key(regexp)
        expect(OEmbed::Providers.urls[regexp]).to include(provider)
      end
    end
  end

  describe ".unregister" do
    it "should unregister providers" do
      OEmbed::Providers.register(@flickr, @qik) # tested in "should register providers"

      OEmbed::Providers.unregister(@flickr)

      @flickr.urls.each do |regexp|
        expect(OEmbed::Providers.urls).to_not have_key(regexp)
      end

      expect(OEmbed::Providers.urls.keys).to eq(@qik.urls)

      @qik.urls.each do |regexp|
        expect(OEmbed::Providers.urls).to have_key(regexp)
        expect(OEmbed::Providers.urls[regexp]).to include(@qik)
      end
    end

    it "should not unregister duplicate provider urls at first" do
      @qik_mirror = OEmbed::Provider.new("http://mirror.qik.com/api/oembed.{format}")
      @qik_mirror << "http://qik.com/*"

      @qik_mirror.urls.each do |regexp|
        expect(@qik.urls).to include(regexp)
      end

      OEmbed::Providers.register(@qik, @qik_mirror)

      expect(OEmbed::Providers.urls.keys).to eq(@qik.urls)

      @qik_mirror.urls.each do |regexp|
        expect(OEmbed::Providers.urls[regexp]).to include(@qik_mirror)
        expect(OEmbed::Providers.urls[regexp]).to include(@qik)
      end

      expect(OEmbed::Providers.find(example_url(:qik))).to eq(@qik)

      OEmbed::Providers.unregister(@qik)

      @qik_mirror.urls.each do |regexp|
        expect(OEmbed::Providers.urls[regexp]).to include(@qik_mirror)
      end

      expect(OEmbed::Providers.find(example_url(:qik))).to eq(@qik_mirror)

      OEmbed::Providers.unregister(@qik_mirror)

      @qik_mirror.urls.each do |regexp|
        expect(OEmbed::Providers.urls).to_not have_key(regexp)
      end
    end
  end

  # it "should use the OEmbed::ProviderDiscovery fallback provider correctly" do
  #  url = example_url(:vimeo)
  #
  #  # None of the registered providers should match
  #  all_example_urls.each do |url|
  #    provider = OEmbed::Providers.find(url)
  #    if provider
  #      provider.should_not_receive(:raw)
  #      provider.should_not_receive(:get)
  #    end
  #  end
  #
  #  # Register the fallback
  #  OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery)
  #
  #  provider = OEmbed::ProviderDiscovery
  #  expect(provider).to receive(:raw).
  #    with(url, {}).
  #    and_return(valid_response(:raw))
  #  expect(provider).to receive(:get).
  #    with(url, {}).
  #    and_return(valid_response(:object))
  # end

  describe "#find" do
    let(:url_scheme) { "http://media.foo.com/*" }
    let(:providerA) {
      p = OEmbed::Provider.new("http://a.foo.com/oembed")
      p << url_scheme
      p
    }
    let(:providerB) {
      p = OEmbed::Provider.new("http://b.foo.com/oembed")
      p << url_scheme
      p
    }

    let(:url_to_find) { "http://media.foo.com/which-one?" }
    subject { OEmbed::Providers.find(url_to_find) }

    context "when there registered providers are distinct" do
      before { OEmbed::Providers.register(@flickr, @qik, providerA) }

      it "should find providerA" do
        should eq(providerA)
      end

      it "should find by any of the registered providers by URL" do
        expect(OEmbed::Providers.find(example_url(:flickr))).to eq(@flickr)
        expect(OEmbed::Providers.find(example_url(:qik))).to eq(@qik)
      end
    end

    context "when the registered provider has missing required_query_params" do
      let(:providerA) {
        p = OEmbed::Provider.new("http://a.foo.com/oembed", required_query_params: {send_with_query: false})
        p << url_scheme
        p
      }
      before { OEmbed::Providers.register(providerA) }

      it "should NOT find the provider" do
        should be_nil
      end

      context "but then later has the required_query_param set" do
        it "should find providerA" do
          providerA.send_with_query = "a non-blank val"

          should eq(providerA)
        end
      end
    end

    context "when multiple providers match the same URL" do
      it "should find one match" do
        OEmbed::Providers.register(providerA, providerB)

        should eq(providerA).or eq(providerB)
      end

      context "when providerA has missing required_query_params" do
        let(:providerA) {
          p = OEmbed::Provider.new("http://a.foo.com/oembed", required_query_params: {send_with_query: false})
          p << url_scheme
          p
        }

        it "should find the provider with satisfied required_query_params" do
          OEmbed::Providers.register(providerA, providerB)

          should eq(providerB)
        end

        it "should find the provider with satisfied required_query_params, regardless of register order" do
          OEmbed::Providers.register(providerB, providerA)

          should eq(providerB)
        end
      end

      context "when providerA has satisfied required_query_params" do
        let(:providerA) {
          p = OEmbed::Provider.new("http://a.foo.com/oembed", required_query_params: {send_with_query: false})
          p.send_with_query = "a non-blank value"
          p << url_scheme
          p
        }

        it "should find one match" do
          OEmbed::Providers.register(providerA, providerB)

          should eq(providerA).or eq(providerB)
        end

        it "should find one match, regardless of register order" do
          OEmbed::Providers.register(providerB, providerA)

          should eq(providerA).or eq(providerB)
        end
      end

      context "but with slightly different URL schemes" do
        let(:url_to_find) { "http://media.foo.com/video/which-one?" }
        let(:broad_url_scheme) { "http://media.foo.com/*" }
        let(:specific_url_scheme) { "http://media.foo.com/video/*" }
        let(:providerA) {
          p = OEmbed::Provider.new("http://a.foo.com/oembed")
          p << broad_url_scheme
          p
        }
        let(:providerB) {
          p = OEmbed::Provider.new("http://a.foo.com/oembed")
          p << specific_url_scheme
          p
        }

        it "should find one match" do
          OEmbed::Providers.register(providerA, providerB)

          should eq(providerA).or eq(providerB)
        end

        it "should find one match, regardless of register order" do
          OEmbed::Providers.register(providerB, providerA)

          should eq(providerA).or eq(providerB)
        end
      end
    end
  end

  describe "#raw and #get" do
    it "should bridge #get and #raw to the right provider" do
      OEmbed::Providers.register_all
      all_example_urls.each do |url|
        provider = OEmbed::Providers.find(url)
        expect(provider).to receive(:raw)
          .with(url, {})
        expect(provider).to receive(:get)
          .with(url, {})
        OEmbed::Providers.raw(url)
        OEmbed::Providers.get(url)
      end
    end

    it "should raise an error if no embeddable content is found" do
      OEmbed::Providers.register_all
      ["http://fake.com/", example_url(:google_video)].each do |url|
        expect { OEmbed::Providers.get(url) }.to raise_error(OEmbed::NotFound)
        expect { OEmbed::Providers.raw(url) }.to raise_error(OEmbed::NotFound)
      end
    end
  end

  describe ".register_fallback" do
    it "should register fallback providers" do
      OEmbed::Providers.register_fallback(OEmbed::Providers::Hulu)
      OEmbed::Providers.register_fallback(OEmbed::Providers::OohEmbed)

      expect(OEmbed::Providers.fallback).to eq([OEmbed::Providers::Hulu, OEmbed::Providers::OohEmbed])
    end

    it "should fallback to the appropriate provider when URL isn't found" do
      OEmbed::Providers.register_all
      OEmbed::Providers.register_fallback(OEmbed::Providers::Hulu)
      OEmbed::Providers.register_fallback(OEmbed::Providers::OohEmbed)

      url = example_url(:google_video)

      provider = OEmbed::Providers.fallback.last
      expect(provider).to receive(:raw)
        .with(url, {})
        .and_return(valid_response(:raw))
      expect(provider).to receive(:get)
        .with(url, {})
        .and_return(valid_response(:object))

      OEmbed::Providers.fallback.each do |p|
        next if p == provider
        expect(p).to receive(:raw).and_raise(OEmbed::NotFound)
        expect(p).to receive(:get).and_raise(OEmbed::NotFound)
      end

      OEmbed::Providers.raw(url)
      OEmbed::Providers.get(url)
    end

    it "should still raise an error if no embeddable content is found" do
      OEmbed::Providers.register_all
      OEmbed::Providers.register_fallback(OEmbed::Providers::Hulu)
      OEmbed::Providers.register_fallback(OEmbed::Providers::OohEmbed)

      ["http://fa.ke/"].each do |url|
        expect { OEmbed::Providers.get(url) }.to raise_error(OEmbed::NotFound)
        expect { OEmbed::Providers.raw(url) }.to raise_error(OEmbed::NotFound)
      end
    end
  end

  describe ".register_all" do
    after(:each) do
      OEmbed::Providers.send(:remove_const, :Fake) if defined?(OEmbed::Providers::Fake)
    end

    it "should not register a provider that is not marked as official" do
      expect(defined?(OEmbed::Providers::Fake)).to_not be

      class OEmbed::Providers
        Fake = OEmbed::Provider.new("http://new.fa.ke/oembed/")
        Fake << "http://new.fa.ke/*"
      end

      OEmbed::Providers.register_all
      ["http://new.fa.ke/20C285E0"].each do |url|
        provider = OEmbed::Providers.find(url)
        expect(provider).to be_nil
      end
    end

    describe "register_access_token_providers" do
      describe "tokens[:facebook]" do
        let(:access_token) { "my-fake-access-token" }
        let(:provider) { OEmbed::Providers::FacebookPost }
        let(:embed_url) { "https://www.facebook.com/exampleuser/posts/1234567890" }

        around(:each) do |each|
          @previous_oembed_facebook_token = ENV["OEMBED_FACEBOOK_TOKEN"]
          ENV["OEMBED_FACEBOOK_TOKEN"] = nil
          provider.access_token = nil
          each.run
          ENV["OEMBED_FACEBOOK_TOKEN"] = @previous_oembed_facebook_token
          provider.access_token = @previous_oembed_facebook_token
          OEmbed::Providers.unregister_all
        end

        subject { OEmbed::Providers.find(embed_url) }

        context "when NO access token is provided" do
          before do
            OEmbed::Providers.register_all
          end

          it { is_expected.to_not eql(provider) }
          it { is_expected.to eq(nil) }
        end

        context "when access token is provided to register_all" do
          before do
            OEmbed::Providers.register_all(access_tokens: {facebook: access_token})
          end

          it { is_expected.to eql(provider) }

          after do
            OEmbed::Providers.register_all(access_tokens: {facebook: @previous_oembed_facebook_token})
          end
        end

        context "when access token is set ahead of time" do
          before do
            provider.access_token = access_token
            OEmbed::Providers.register_all
          end

          it { is_expected.to eql(provider) }
        end
      end
    end

    describe "add_official_provider" do
      it "should register a new official provider" do
        expect(defined?(OEmbed::Providers::Fake)).to_not be

        class OEmbed::Providers
          Fake = OEmbed::Provider.new("http://official.fa.ke/oembed/")
          Fake << "http://official.fa.ke/*"
          add_official_provider(Fake)
        end

        ["http://official.fa.ke/20C285E0"].each do |url|
          provider = OEmbed::Providers.find(url)
          expect(provider).to_not be_a(OEmbed::Provider)
        end

        OEmbed::Providers.register_all
        ["http://official.fa.ke/20C285E0"].each do |url|
          provider = OEmbed::Providers.find(url)
          expect(provider).to be_a(OEmbed::Provider)
        end
      end

      it "should register an official sub_type provider separately" do
        expect(defined?(OEmbed::Providers::Fake)).to_not be

        class OEmbed::Providers
          Fake = OEmbed::Provider.new("http://sub.fa.ke/oembed/")
          Fake << "http://sub.fa.ke/*"
          add_official_provider(Fake, :fakes)
        end

        OEmbed::Providers.register_all
        ["http://sub.fa.ke/20C285E0"].each do |url|
          provider = OEmbed::Providers.find(url)
          expect(provider).to_not be_a(OEmbed::Provider)
        end

        OEmbed::Providers.register_all(:fakes)
        ["http://sub.fa.ke/20C285E0"].each do |url|
          provider = OEmbed::Providers.find(url)
          expect(provider).to be_a(OEmbed::Provider)
        end
      end
    end
  end
end
