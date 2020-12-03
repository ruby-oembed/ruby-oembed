require File.dirname(__FILE__) + '/spec_helper'

describe OEmbed::Provider do
  before(:all) do
    VCR.insert_cassette('OEmbed_Provider')
  end
  after(:all) do
    VCR.eject_cassette
  end

  include OEmbedSpecHelper

  before(:all) do
    @default = OEmbed::Formatter.default
    @flickr = OEmbed::Provider.new("http://www.flickr.com/services/oembed/")
    @qik = OEmbed::Provider.new("http://qik.com/api/oembed.{format}", format: :xml)
    @viddler = OEmbed::Provider.new("http://lab.viddler.com/services/oembed/", format: :json)

    @flickr << "http://*.flickr.com/*"
    @qik << "http://qik.com/video/*"
    @qik << "http://qik.com/*"
    @viddler << "http://*.viddler.com/*"
  end

  describe "initialize" do
    it "should by default use OEmbed::Formatter.default" do
      provider = OEmbed::Provider.new("http://foo.com/oembed/")
      expect(provider.format).to eq(OEmbed::Formatter.default)
    end

    [:xml, :json].each do |given_format|
      it "should allow #{given_format} format via positional argument" do
        provider = OEmbed::Provider.new("http://foo.com/oembed/", given_format)
        expect( provider.format ).to eq(given_format)
      end

      it "should allow #{given_format} format via named argument" do
        provider = OEmbed::Provider.new("http://foo.com/oembed/", format: given_format)
        expect( provider.format ).to eq(given_format)
      end
    end

    it "should require a valid endpoint for a new instance" do
      expect { OEmbed::Provider.new("http://foo.com/oembed/") }.
      not_to raise_error

      expect { OEmbed::Provider.new("https://foo.com/oembed/") }.
      not_to raise_error
    end

    it "should allow a {format} string in the endpoint for a new instance" do
      expect { OEmbed::Provider.new("http://foo.com/oembed.{format}/get") }.
      not_to raise_error
    end

    it "should raise an ArgumentError given an invalid endpoint for a new instance" do
      [
        "httpx://foo.com/oembed/",
        "ftp://foo.com/oembed/",
        "foo.com/oembed/",
        "http://not a uri",
        nil, 1,
      ].each do |endpoint|
        expect { OEmbed::Provider.new(endpoint) }.
        to raise_error(ArgumentError)
      end
    end

    it "should allow random formats on initialization" do
      expect {
        yaml_provider = OEmbed::Provider.new("http://foo.com/api/oembed.{format}", format: :yml)
        yaml_provider << "http://foo.com/*"
      }.
      not_to raise_error
    end

    it "should not allow random formats to be parsed" do
      yaml_provider = OEmbed::Provider.new("http://foo.com/api/oembed.{format}", format: :yml)
      yaml_provider << "http://foo.com/*"
      yaml_url = "http://foo.com/video/1"

      expect(yaml_provider).to receive(:raw).
        with(yaml_url, {:format=>:yml}).
        and_return(valid_response(:json))

      expect { yaml_provider.get(yaml_url) }.
      to raise_error(OEmbed::FormatNotSupported)
    end

    it "should allow no URI schema to be given" do
      provier = OEmbed::Provider.new("http://foo.com/oembed")

      expect(provier).to include("http://foo.com/1")
      expect(provier).to include("http://bar.foo.com/1")
      expect(provier).to include("http://bar.foo.com/show/1")
      expect(provier).to include("https://bar.foo.com/1")
      expect(provier).to include("http://asdf.com/1")
      expect(provier).to include("asdf")
    end

    describe "the required_query_params option" do
      let(:provider) {
        OEmbed::Provider.new("http://foo.com/oembed", required_query_params: { send_with_query: 'PROVIDER_ENV_VAR' })
      }

      around(:example) { |example|
        orig_value = ENV['PROVIDER_ENV_VAR']
        ENV['PROVIDER_ENV_VAR'] = env_var_value
        example.run
        ENV['PROVIDER_ENV_VAR'] = orig_value
      }

      context "with a non-blank env var" do
        let(:env_var_value) { 'non-blank-value' }

        it "has a working getter" do
          expect(provider.send_with_query).to eq(env_var_value)
        end

        it "has a working setter" do
          provider.send_with_query = env_var_value.succ
          expect(provider.send_with_query).to eq(env_var_value.succ)
        end

        it "still throws NoMethodError errors generally" do
          # puts provider.other_query

          expect { provider.other_query }
          .to raise_error(NoMethodError)

          expect { provider.other_query = 'val' }
          .to raise_error(NoMethodError)
        end

        context "but no env var name for the required_query_params" do
          let(:provider) {
            OEmbed::Provider.new("http://foo.com/oembed", required_query_params: { send_with_query: false })
          }

          it "has a working getter" do
            expect(provider.send_with_query).to be_nil
          end

          it "has a working setter" do
            provider.send_with_query = 'non-blank-value'
            expect(provider.send_with_query).to eq('non-blank-value')
          end
        end
      end

      context "with a nil env var" do
        let(:env_var_value) { nil }

        it "has a working getter" do
          expect(provider.send_with_query).to be_nil
        end

        it "has a working setter" do
          provider.send_with_query = 'a-new-val'
          expect(provider.send_with_query).to eq('a-new-val')
        end

        it "still throws NoMethodError errors generally" do
          # puts provider.other_query

          expect { provider.other_query }
          .to raise_error(NoMethodError)

          expect { provider.other_query = 'val' }
          .to raise_error(NoMethodError)
        end
      end

      context "where the required_query_param conflicts with an existing method name" do
        let(:provider) {
          OEmbed::Provider.new("http://foo.com/oembed", required_query_params: { get: 'PROVIDER_ENV_VAR' })
        }
        let(:env_var_value) { 'a-conflicted-val' }

        it "does NOT override the get method" do
          expect { provider.get }
          .to raise_error(ArgumentError) # because get requires arguments!
        end

        it "still sets up the @required_query_params internals correctly" do
          expect(provider.instance_variable_get('@required_query_params')).to eq({ get: env_var_value })
        end

        it "DOES have a working setter" do
          provider.get = 'a-new-val'
          expect(provider.instance_variable_get('@required_query_params')).to eq({ get: 'a-new-val' })
        end
      end
    end
  end

  describe "<<" do
    it "should add URL schemes" do
      expect(@flickr.urls).to eq([%r{^http://([^\.]+\.)?flickr\.com/(.*?)}])
      expect(@qik.urls).to eq([
        %r{^http://qik\.com/video/(.*?)},
        %r{^http://qik\.com/(.*?)}
      ])
    end

    it "should match URLs" do
      expect(@flickr).to include(example_url(:flickr))
      expect(@qik).to include(example_url(:qik))
    end

    it "should allow a String as a URI schema" do
      provier = OEmbed::Provider.new("http://foo.com/oembed")
      provier << "http://bar.foo.com/*"

      expect(provier).to include("http://bar.foo.com/1")
      expect(provier).to include("http://bar.foo.com/show/1")

      expect(provier).to_not include("https://bar.foo.com/1")
      expect(provier).to_not include("http://foo.com/1")
    end

    it "should allow multiple path wildcards in a String URI schema" do
      provier = OEmbed::Provider.new("http://foo.com/oembed")
      provier << "http://bar.foo.com/*/show/*"

      expect(provier).to include("http://bar.foo.com/photo/show/1")
      expect(provier).to include("http://bar.foo.com/video/show/2")
      expect(provier).to include("http://bar.foo.com/help/video/show/2")

      expect(provier).to_not include("https://bar.foo.com/photo/show/1")
      expect(provier).to_not include("http://foo.com/video/show/2")
      expect(provier).to_not include("http://bar.foo.com/show/1")
      expect(provier).to_not include("http://bar.foo.com/1")
    end

    it "should NOT allow multiple domain wildcards in a String URI schema", :pending => true do
      provier = OEmbed::Provider.new("http://foo.com/oembed")

      expect { provier << "http://*.com/*" }.
      to raise_error(ArgumentError)

      expect(provier).to_not include("http://foo.com/1")
    end

    it "should allow a sub-domain wildcard in String URI schema" do
      provier = OEmbed::Provider.new("http://foo.com/oembed")
      provier << "http://*.foo.com/*"

      expect(provier).to include("http://bar.foo.com/1")
      expect(provier).to include("http://foo.foo.com/2")
      expect(provier).to include("http://foo.com/3")

      expect(provier).to_not include("https://bar.foo.com/1")
      expect(provier).to_not include("http://my.bar.foo.com/1")

      provier << "http://my.*.foo.com/*"
    end

    it "should allow multiple sub-domain wildcards in a String URI schema" do
      provier = OEmbed::Provider.new("http://foo.com/oembed")
      provier << "http://*.my.*.foo.com/*"

      expect(provier).to include("http://my.bar.foo.com/1")
      expect(provier).to include("http://my.foo.com/2")
      expect(provier).to include("http://bar.my.bar.foo.com/3")

      expect(provier).to_not include("http://bar.foo.com/1")
      expect(provier).to_not include("http://foo.bar.foo.com/1")
    end

    it "should NOT allow a scheme wildcard in a String URI schema", :pending => true do
      provier = OEmbed::Provider.new("http://foo.com/oembed")

      expect { provier << "*://foo.com/*" }.
      to raise_error(ArgumentError)

      expect(provier).to_not include("http://foo.com/1")
    end

    it "should allow a scheme other than http in a String URI schema" do
      provier = OEmbed::Provider.new("http://foo.com/oembed")
      provier << "https://foo.com/*"

      expect(provier).to include("https://foo.com/1")

      gopher_url = "gopher://foo.com/1"
      expect(provier).to_not include(gopher_url)
      provier << "gopher://foo.com/*"
      expect(provier).to include(gopher_url)
    end

    it "should allow a Regexp as a URI schema" do
      provier = OEmbed::Provider.new("http://foo.com/oembed")
      provier << %r{^https?://([^\.]*\.)?foo.com/(show/)?\d+}

      expect(provier).to include("http://bar.foo.com/1")
      expect(provier).to include("http://bar.foo.com/show/1")
      expect(provier).to include("http://foo.com/1")
      expect(provier).to include("https://bar.foo.com/1")

      expect(provier).to_not include("http://bar.foo.com/video/1")
      expect(provier).to_not include("gopher://foo.com/1")
    end
  end

  describe "#build" do
    it "should raise error if the URL is invalid" do
      expect{ @flickr.send(:build, example_url(:fake)) }.to raise_error(OEmbed::NotFound)
      expect{ @qik.send(:build, example_url(:fake)) }.to raise_error(OEmbed::NotFound)
    end

    it "should return a proper URL" do
      uri = @flickr.send(:build, example_url(:flickr))
      expect(uri.host).to eq("www.flickr.com")
      expect(uri.path).to eq("/services/oembed/")
      expect(uri.query).to include("format=#{@flickr.format}")
      expect(uri.query).to include("url=#{CGI.escape 'http://flickr.com/photos/bees/2362225867/'}")

      uri = @qik.send(:build, example_url(:qik))
      expect(uri.host).to eq("qik.com")
      expect(uri.path).to eq("/api/oembed.xml")
      expect(uri.query).to_not include("format=#{@qik.format}")
      expect(uri.query).to eq("url=#{CGI.escape 'http://qik.com/video/49565'}")
    end

    it "should accept parameters" do
      uri = @flickr.send(:build, example_url(:flickr),
        :maxwidth => 600,
        :maxheight => 200,
        :format => :xml,
        :another => "test")

      expect(uri.query).to include("maxwidth=600")
      expect(uri.query).to include("maxheight=200")
      expect(uri.query).to include("format=xml")
      expect(uri.query).to include("another=test")
    end

    it "should build correctly when format is in the endpoint URL" do
      uri = @qik.send(:build, example_url(:qik), :format => :json)
      expect(uri.path).to eq("/api/oembed.json")
    end

    it "should build correctly with query parameters in the endpoint URL" do
      provider = OEmbed::Provider.new('http://www.youtube.com/oembed?scheme=https')
      provider << 'http://*.youtube.com/*'
      url = 'http://youtube.com/watch?v=M3r2XDceM6A'
      expect(provider).to include(url)

      uri = provider.send(:build, url)
      expect(uri.query).to include("scheme=https")
      expect(uri.query).to include("url=#{CGI.escape url}")
    end

    it "should not include the :timeout parameter in the query string" do
      uri = @flickr.send(:build, example_url(:flickr),
        :timeout => 5,
        :another => "test")

      expect(uri.query).to_not include("timeout=5")
      expect(uri.query).to include("another=test")
    end
  end

  describe "#raw" do
    it "should return the body on 200" do
      res = @flickr.send(:raw, example_url(:flickr))
      expect(res).to eq(example_body(:flickr))
    end

    it "should return the body on 200 even over https" do
      @vimeo_ssl = OEmbed::Provider.new("https://vimeo.com/api/oembed.{format}")
      @vimeo_ssl << "http://*.vimeo.com/*"
      @vimeo_ssl << "https://*.vimeo.com/*"

      res = @vimeo_ssl.send(:raw, example_url(:vimeo_ssl))
      expect(res).to eq(example_body(:vimeo_ssl).strip)
    end

    it "should raise an UnknownFormat error on 501" do
      stub_request(:get, /flickr/).to_return(status: 501)

      expect {
        result = @flickr.send(:raw, File.join(example_url(:flickr), '501'))
      }.to raise_error(OEmbed::UnknownFormat)
    end

    it "should raise a NotFound error on 404" do
      stub_request(:get, /flickr/).to_return(status: 404)

      expect {
        @flickr.send(:raw, File.join(example_url(:flickr), '404'))
      }.to raise_error(OEmbed::NotFound)
    end

    ['405', '500'].each do |status|
      it "should raise an UnknownResponse error on other responses (#{status})" do
        stub_request(:get, /flickr/).to_return(status: status)

        expect {
          @flickr.send(:raw, File.join(example_url(:flickr), status))
        }.to raise_error(OEmbed::UnknownResponse)
      end
    end
  end

  describe "#get" do
    it "should send the specified format" do
      expect(@flickr).to receive(:raw).
        with(example_url(:flickr), {:format=>:json}).
        and_return(valid_response(:json))
      @flickr.get(example_url(:flickr), :format=>:json)

      expect(@flickr).to receive(:raw).
        with(example_url(:flickr), {:format=>:xml}).
        and_return(valid_response(:xml))
      @flickr.get(example_url(:flickr), :format=>:xml)

      expect {
        expect(@flickr).to receive(:raw).
          with(example_url(:flickr), {:format=>:yml}).
          and_return(valid_response(:json))
        @flickr.get(example_url(:flickr), :format=>:yml)
      }.to raise_error(OEmbed::FormatNotSupported)
    end

    it "should return OEmbed::Response" do
      allow(@flickr).to receive(:raw).and_return(valid_response(@default))
      expect(@flickr.get(example_url(:flickr))).to be_a(OEmbed::Response)
    end

    it "should be calling OEmbed::Response#create_for internally" do
      allow(@flickr).to receive(:raw).and_return(valid_response(@default))
      expect(OEmbed::Response).to receive(:create_for).
        with(valid_response(@default), @flickr, example_url(:flickr), @default.to_s)
      @flickr.get(example_url(:flickr))

      allow(@qik).to receive(:raw).and_return(valid_response(:xml))
      expect(OEmbed::Response).to receive(:create_for).
        with(valid_response(:xml), @qik, example_url(:qik), 'xml')
      @qik.get(example_url(:qik))

      allow(@viddler).to receive(:raw).and_return(valid_response(:json))
      expect(OEmbed::Response).to receive(:create_for).
        with(valid_response(:json), @viddler, example_url(:viddler), 'json')
      @viddler.get(example_url(:viddler))
    end

    it "should send the provider's format if none is specified" do
      expect(@flickr).to receive(:raw).
        with(example_url(:flickr), :format => @default).
        and_return(valid_response(@default))
      @flickr.get(example_url(:flickr))

      expect(@qik).to receive(:raw).
        with(example_url(:qik), :format=>:xml).
        and_return(valid_response(:xml))
      @qik.get(example_url(:qik))

      expect(@viddler).to receive(:raw).
        with(example_url(:viddler), :format=>:json).
        and_return(valid_response(:json))
      @viddler.get(example_url(:viddler))
    end

    context "with require_query_params" do
      let(:provider) { OEmbed::Provider.new("http://foo.com/oembed", required_query_params: { send_with_query: 'PROVIDER_ENV_VAR' }) }

      it "should add the required_query_params to the URI" do
        provider.send_with_query = 'non-blank-value'

        expect(provider).to receive(:http_get).
          with(have_attributes(query: match(/send_with_query=non-blank-value/)), :format => @default).
          and_return(valid_response(:json))
        provider.get(example_url(:fake))
      end

      it "should claim to not match if the required_query_params are missing" do
        allow(provider).to receive(:http_get).and_return(valid_response(:json))

        expect { provider.get(example_url(:fake)) }.
        to raise_error(OEmbed::NotFound)
      end
    end

    it "handles the :timeout option", pending: true do
      expect_any_instance_of(Net::HTTP).to receive(:open_timeout=).with(5)
      expect_any_instance_of(Net::HTTP).to receive(:read_timeout=).with(5)
      @flickr.get(example_url(:flickr), :timeout => 5)
    end
  end

  describe "#set_required_query_params" do
    let(:provider) { OEmbed::Provider.new("http://foo.com/oembed", required_query_params: { send_with_query: 'PROVIDER_ENV_VAR' }) }

    around(:example) { |example|
      orig_value = ENV['PROVIDER_ENV_VAR']
      ENV['PROVIDER_ENV_VAR'] = 'a non-nil value'
      example.run
      ENV['PROVIDER_ENV_VAR'] = orig_value
    }

    it 'META: the around works as expected' do
      expect(provider.send_with_query).to eq('a non-nil value')
      expect(provider.required_query_params_set?).to be_truthy
    end

    [
      [true, 'true'],
      [false, 'false'],
      ['one two', 'one+two'],
      ['a@&?%25', 'a%40%26%3F%2525'],
    ].each do |given_value, expected_value|
      context "given #{given_value.inspect}" do
        before(:each) { provider.send_with_query = given_value }

        it "stringifies and escapes the value" do
          expect(provider.send_with_query).to eq(expected_value)
        end

        it "satisfies required_query_params_set?" do
          expect(provider.required_query_params_set?).to be_truthy
        end
      end
    end

    context "given nil" do
      before(:each) { provider.send_with_query = nil }

      it "nils the existing value" do
        expect(provider.send_with_query).to be_nil
      end

      it "sets required_query_params_set? to falsey" do
        expect(provider.required_query_params_set?).to be_falsey
      end
    end
  end
end
