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
    expect(OEmbed::Formatter::XML.backend).to eq(OEmbed::Formatter::XML::Backends::Nokogiri)
  end

  it 'should decode an XML String' do
    decoded = OEmbed::Formatter.decode(:xml, valid_response(:xml))
    # We need to compare keys & values separately because we don't expect all
    # non-string values to be recognized correctly.
    expect(decoded.keys).to eq(valid_response(:object).keys)
    expect(decoded.values.map(&:to_s)).to eq(valid_response(:object).values.map(&:to_s))
  end

  it 'should raise an OEmbed::ParseError when decoding an invalid XML String' do
    expect {
      decode = OEmbed::Formatter.decode(:xml, invalid_response('unclosed_container', :xml))
    }.to raise_error(OEmbed::ParseError)
    expect {
      decode = OEmbed::Formatter.decode(:xml, invalid_response('unclosed_tag', :xml))
    }.to raise_error(OEmbed::ParseError)
    expect {
      decode = OEmbed::Formatter.decode(:xml, invalid_response('invalid_syntax', :xml))
    }.to raise_error(OEmbed::ParseError)
  end

  it 'should raise an OEmbed::ParseError when decoding fails with an unexpected error' do
    error_to_raise = ArgumentError
    expect(OEmbed::Formatter::XML.backend.parse_error).to_not be_kind_of(error_to_raise)

    expect(::Nokogiri::XML::Document).to receive(:parse)
      .and_raise(error_to_raise.new('unknown error'))

    expect {
      decode = OEmbed::Formatter.decode(:xml, valid_response(:xml))
    }.to raise_error(OEmbed::ParseError)
  end
end
