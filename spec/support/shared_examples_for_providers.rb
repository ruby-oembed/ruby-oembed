RSpec.shared_examples "an OEmbed::Providers instance" do |expected_valid_urls, expected_invalid_urls|
  subject { provider }

  expected_valid_urls.each do |valid_url|
    context "given the valid URL #{valid_url}" do
      it { should include(valid_url) }

      describe ".get" do
        subject { provider.get(valid_url) }

        it { should be_a(OEmbed::Response) }
      end
    end
  end

  expected_invalid_urls.each do |invalid_url|
    context "given the invalid URL #{invalid_url}" do
      it { should_not include(invalid_url) }

      describe ".get" do
        subject { provider.get(invalid_url) }

        it "should raise an OEmbed::NotFound error" do
          expect { subject }.to raise_error(OEmbed::NotFound)
        end
      end
    end
  end

  describe "OEmbed::Providers.register(provider)" do
    before(:each) { OEmbed::Providers.register(provider) }
    after(:each) { OEmbed::Providers.unregister_all }

    describe(".get") do
      expected_valid_urls.each do |valid_url|
        context "given the valid URL #{valid_url}" do
          subject { OEmbed::Providers.get(valid_url) }
          it { should be_a(OEmbed::Response) }
        end
      end
      expected_invalid_urls.each do |invalid_url|
        context "given the invalid URL #{invalid_url}" do
          let(:url) { invalid_url }
          it "should raise an OEmbed::NotFound error" do
            expect { expect(OEmbed::Providers.get(url)) }.to raise_error(OEmbed::NotFound)
          end
        end
      end
    end
  end
end
