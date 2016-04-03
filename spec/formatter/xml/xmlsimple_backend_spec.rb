require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared_formatter_backend_examples'

describe 'OEmbed::Formatter::XML::Backends::XmlSimple' do
  include OEmbedSpecHelper

  before(:all) do
    expect {
      OEmbed::Formatter::XML.backend = 'XmlSimple'
    }.to raise_error(LoadError)

    require 'xmlsimple'

    expect {
      OEmbed::Formatter::XML.backend = 'XmlSimple'
    }.to_not raise_error
  end

  let(:backend_module) { OEmbed::Formatter::XML::Backends::XmlSimple }
  let(:object_for_decode) { ::XmlSimple }
  let(:method_for_decode) { :xml_in }

  it_behaves_like 'an XML backend'
end
