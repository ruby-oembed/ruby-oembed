require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared_formatter_backend_examples'

describe 'OEmbed::Formatter::XML::Backends::REXML' do
  include OEmbedSpecHelper

  before(:all) do
    expect {
      OEmbed::Formatter::XML.backend = 'REXML'
    }.to_not raise_error

    expect(defined?(REXML)).to be_truthy
  end

  let(:backend_module) { OEmbed::Formatter::XML::Backends::REXML }
  let(:object_for_decode) { ::REXML::Document }
  let(:method_for_decode) { :new }

  it_behaves_like 'an XML backend'
end
