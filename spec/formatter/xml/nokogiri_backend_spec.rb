require File.dirname(__FILE__) + '/../../spec_helper'

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

  it 'should support XML' do
    expect {
      OEmbed::Formatter.supported?(:xml)
    }.to_not raise_error
  end

  it 'should be using the Nokogiri backend' do
    expect(OEmbed::Formatter::XML.backend)
      .to eq(OEmbed::Formatter::XML::Backends::Nokogiri)
  end

  it 'should decode an XML String' do
    decoded = OEmbed::Formatter.decode(:xml, valid_response(:xml))
    # We need to compare keys & values separately because we don't expect all
    # non-string values to be recognized correctly.
    expect(decoded.keys).to eq(valid_response(:object).keys)
    expect(decoded.values.map(&:to_s))
      .to eq(valid_response(:object).values.map(&:to_s))
  end

  RSpec.shared_examples 'a backend' do
    around(:example) do |example|
      RSpec::Expectations
        .configuration.warn_about_potential_false_positives = false

      example.run

      RSpec::Expectations
        .configuration.warn_about_potential_false_positives = true
    end

    it 'should not catch that error when decoding' do
      expect {
        OEmbed::Formatter::XML::Backends::Nokogiri.decode(:xml, xml_input)
      }.to raise_error
    end
  end

  context 'given an unclosed xml continer' do
    it_behaves_like 'a backend' do
      let(:xml_input) { invalid_response('unclosed_container', :xml) }
    end
  end

  context 'given an unclosed xml tag' do
    it_behaves_like 'a backend' do
      let(:xml_input) { invalid_response('unclosed_tag', :xml) }
    end
  end

  context 'given invalid xml syntax' do
    it_behaves_like 'a backend' do
      let(:xml_input) { invalid_response('invalid_syntax', :xml) }
    end
  end

  context 'given an unexpected error when parsing xml' do
    it 'should not catch that error when decoding' do
      error_to_raise = ZeroDivisionError
      expect(OEmbed::Formatter::XML.backend.parse_error)
        .to_not be_kind_of(error_to_raise)

      expect(::Nokogiri::XML::Document).to receive(:parse)
        .and_raise(error_to_raise.new('unknown error'))

      expect {
        OEmbed::Formatter::XML::Backends::Nokogiri.decode(valid_response(:xml))
      }.to raise_error(error_to_raise)
    end
  end
end
