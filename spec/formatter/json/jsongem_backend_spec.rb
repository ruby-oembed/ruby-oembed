require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared_formatter_backend_examples'
require 'json'

describe "Setting JSON.backend = 'JSONGem'" do
  context 'without the JSON object defined' do
    it 'should fail' do
      expect(OEmbed::Formatter::JSON)
        .to receive(:already_loaded?).with('JSONGem').and_return(false)
      expect(Object)
        .to receive(:const_defined?).with('JSON').and_return(false)

      expect {
        OEmbed::Formatter::JSON.backend = 'JSONGem'
      }.to raise_error(LoadError)
    end
  end

  context 'with the JSON object loaded' do
    it 'should work' do
      expect(OEmbed::Formatter::JSON)
        .to receive(:already_loaded?).with('JSONGem').and_return(false)

      expect {
        OEmbed::Formatter::JSON.backend = 'JSONGem'
      }.to_not raise_error
    end
  end
end

describe 'OEmbed::Formatter::JSON::Backends::JSONGem' do
  include OEmbedSpecHelper

  let(:backend_module) { OEmbed::Formatter::JSON::Backends::JSONGem }
  let(:object_for_decode) { ::JSON }
  let(:method_for_decode) { :parse }

  it_behaves_like 'a JSON backend'
end
