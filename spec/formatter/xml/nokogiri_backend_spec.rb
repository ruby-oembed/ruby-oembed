require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared_formatter_backend_examples'

describe 'OEmbed::Formatter::XML::Backends::Nokogiri' do
  include OEmbedSpecHelper

  before(:all) do
    expect {
      OEmbed::Formatter::XML.backend = 'Nokogiri'
    }.to raise_error(LoadError)

    require 'nokogiri'

    expect {
      OEmbed::Formatter::XML.backend = 'Nokogiri'
    }.to_not raise_error
  end

  let(:backend_module) { OEmbed::Formatter::XML::Backends::Nokogiri }
  let(:object_for_decode) { ::Nokogiri::XML::Document }
  let(:method_for_decode) { :parse }

  it_behaves_like 'an OEmbed::Formatter::XML backend'
end
