require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared_formatter_backend_examples'

describe 'OEmbed::Formatter::JSON::Backends::Yaml' do
  include OEmbedSpecHelper

  before(:all) do
    expect {
      OEmbed::Formatter::JSON.backend = 'Yaml'
    }.to_not raise_error

    expect(defined?(YAML)).to be_truthy
  end

  let(:backend_module) { OEmbed::Formatter::JSON::Backends::Yaml }
  let(:object_for_decode) { OEmbed::Formatter::JSON::Backends::Yaml }
  let(:method_for_decode) { :convert_json_to_yaml }

  it_behaves_like 'a JSON backend'
end
