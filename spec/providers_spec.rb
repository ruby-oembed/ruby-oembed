require File.dirname(__FILE__) + '/spec_helper'

describe OEmbed::Providers do
  include OEmbedSpecHelper

  before(:all) do
    @flickr = OEmbed::Provider.new('http://www.flickr.com/services/oembed/')
    @hulu = OEmbed::Provider.new('http://www.hulu.com/api/oembed.{format}')

    @flickr << 'http://*.flickr.com/*'
    @hulu << 'http://www.hulu.com/watch/*'
  end

  after(:each) do
    OEmbed::Providers.unregister_all
  end

  describe '.register' do
    it 'should register providers' do
      expect(OEmbed::Providers.urls).to be_empty

      OEmbed::Providers.register(@flickr, @hulu)

      expect(OEmbed::Providers.urls.keys).to eq(@flickr.urls + @hulu.urls)

      @flickr.urls.each do |regexp|
        expect(OEmbed::Providers.urls).to have_key(regexp)
        expect(OEmbed::Providers.urls[regexp]).to include(@flickr)
      end

      @hulu.urls.each do |regexp|
        expect(OEmbed::Providers.urls).to have_key(regexp)
        expect(OEmbed::Providers.urls[regexp]).to include(@hulu)
      end
    end

    it 'should find by URLs' do
      OEmbed::Providers.register(@flickr, @hulu) # tested in "should register providers"

      expect(OEmbed::Providers.find(example_url(:flickr))).to eq(@flickr)
      expect(OEmbed::Providers.find(example_url(:hulu))).to eq(@hulu)
    end
  end

  describe '.unregister' do
    it 'should unregister providers' do
      OEmbed::Providers.register(@flickr, @hulu) # tested in "should register providers"

      OEmbed::Providers.unregister(@flickr)

      @flickr.urls.each do |regexp|
        expect(OEmbed::Providers.urls).to_not have_key(regexp)
      end

      expect(OEmbed::Providers.urls.keys).to eq(@hulu.urls)

      @hulu.urls.each do |regexp|
        expect(OEmbed::Providers.urls).to have_key(regexp)
        expect(OEmbed::Providers.urls[regexp]).to include(@hulu)
      end
    end

    it 'should not unregister duplicate provider urls at first' do
      @hulu_mirror = OEmbed::Provider.new('http://mirror.qik.com/api/oembed.{format}')
      @hulu_mirror << 'http://www.hulu.com/watch/*'

      @hulu_mirror.urls.each do |regexp|
        expect(@hulu.urls).to include(regexp)
      end

      OEmbed::Providers.register(@hulu, @hulu_mirror)

      expect(OEmbed::Providers.urls.keys).to eq(@hulu.urls)

      @hulu_mirror.urls.each do |regexp|
        expect(OEmbed::Providers.urls[regexp]).to include(@hulu_mirror)
        expect(OEmbed::Providers.urls[regexp]).to include(@hulu)
      end

      expect(OEmbed::Providers.find(example_url(:hulu))).to eq(@hulu)

      OEmbed::Providers.unregister(@hulu)

      @hulu_mirror.urls.each do |regexp|
        expect(OEmbed::Providers.urls[regexp]).to include(@hulu_mirror)
      end

      expect(OEmbed::Providers.find(example_url(:hulu))).to eq(@hulu_mirror)

      OEmbed::Providers.unregister(@hulu_mirror)

      @hulu_mirror.urls.each do |regexp|
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

  describe '#get' do
    EXAMPLE_URLS.each do |url|
      context "with #{url}" do
        before { OEmbed::Providers.register_all }
        it 'should bridge #get to the right provider' do
          provider = OEmbed::Providers.find(url)
          expect(provider).to receive(:get)
            .with(url, {})
          OEmbed::Providers.get(url)
        end
      end
    end

    it 'should raise an error if no embeddable content is found' do
      OEmbed::Providers.register_all
      ['http://fake.com/', example_url(:google_video)].each do |url|
        expect { OEmbed::Providers.get(url) }.to raise_error(OEmbed::NotFound)
        expect { OEmbed::Providers.raw(url) }.to raise_error(OEmbed::NotFound)
      end
    end
  end

  describe '.register_fallback' do
    it 'should register fallback providers' do
      OEmbed::Providers.register_fallback(OEmbed::Providers::Hulu)
      OEmbed::Providers.register_fallback(OEmbed::Providers::Embedly)

      expect(OEmbed::Providers.fallback).to eq([
        OEmbed::Providers::Hulu, OEmbed::Providers::Embedly
      ])
    end

    it "should fallback to the appropriate provider when URL isn't found" do
      OEmbed::Providers.register_all
      OEmbed::Providers.register_fallback(OEmbed::Providers::Hulu)
      OEmbed::Providers.register_fallback(OEmbed::Providers::Embedly)

      url = example_url(:google_video)

      # Because OEmbed::Providers.fallback returns copies of the originals
      # We need to get a bit creative/hacky to stub
      # out the actuall fallback Provider instances.
      to_stub = OEmbed::Providers.instance_variable_get(:@fallback)
      to_stub.each_with_index do |provider, i|
        if i == to_stub.size - 1
          expect(provider).to receive(:get)
            .with(url, {})
            .and_return(valid_response(:object))
        else
          expect(provider).to receive(:get).and_raise(OEmbed::NotFound)
        end
      end

      OEmbed::Providers.get(url)
    end

    it 'should still raise an error if no embeddable content is found' do
      OEmbed::Providers.register_all
      OEmbed::Providers.register_fallback(OEmbed::Providers::Hulu)
      OEmbed::Providers.register_fallback(OEmbed::Providers::Embedly)

      ['http://fa.ke/'].each do |url|
        expect { OEmbed::Providers.get(url) }.to raise_error(OEmbed::NotFound)
        expect { OEmbed::Providers.raw(url) }.to raise_error(OEmbed::NotFound)
      end
    end
  end

  describe '.register_all' do
    after(:each) do
      OEmbed::Providers.send(:remove_const, :Fake) if defined?(OEmbed::Providers::Fake)
    end

    it 'should not register a provider that is not marked as official' do
      expect(defined?(OEmbed::Providers::Fake)).to_not be

      class OEmbed::Providers
        Fake = OEmbed::Provider.new('http://new.fa.ke/oembed/')
        Fake << 'http://new.fa.ke/*'
      end

      OEmbed::Providers.register_all
      ['http://new.fa.ke/20C285E0'].each do |url|
        provider = OEmbed::Providers.find(url)
        expect(provider).to be_nil
      end
    end

    describe 'add_official_provider' do
      it 'should register a new official provider' do
        expect(defined?(OEmbed::Providers::Fake)).to_not be

        class OEmbed::Providers
          Fake = OEmbed::Provider.new('http://official.fa.ke/oembed/')
          Fake << 'http://official.fa.ke/*'
          add_official_provider(Fake)
        end

        ['http://official.fa.ke/20C285E0'].each do |url|
          provider = OEmbed::Providers.find(url)
          expect(provider).to_not be_a(OEmbed::Provider)
        end

        OEmbed::Providers.register_all
        ['http://official.fa.ke/20C285E0'].each do |url|
          provider = OEmbed::Providers.find(url)
          expect(provider).to be_a(OEmbed::Provider)
        end
      end

      it 'should register an official sub_type provider separately' do
        expect(defined?(OEmbed::Providers::Fake)).to_not be

        class OEmbed::Providers
          Fake = OEmbed::Provider.new('http://sub.fa.ke/oembed/')
          Fake << 'http://sub.fa.ke/*'
          add_official_provider(Fake, :fakes)
        end

        OEmbed::Providers.register_all
        ['http://sub.fa.ke/20C285E0'].each do |url|
          provider = OEmbed::Providers.find(url)
          expect(provider).to_not be_a(OEmbed::Provider)
        end

        OEmbed::Providers.register_all(:fakes)
        ['http://sub.fa.ke/20C285E0'].each do |url|
          provider = OEmbed::Providers.find(url)
          expect(provider).to be_a(OEmbed::Provider)
        end
      end
    end
  end
end
