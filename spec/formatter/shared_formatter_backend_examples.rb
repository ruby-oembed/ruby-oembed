RSpec.shared_examples 'an OEmbed::Formatter::XML backend' do
  it 'should support XML' do
    expect {
      OEmbed::Formatter.supported?(:xml)
    }.to_not raise_error
  end

  it 'should be using the correct backend' do
    expect(OEmbed::Formatter::XML.backend)
      .to eq(backend_module)
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
        backend_module.decode(:xml, xml_input)
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

      expect(object_for_decode).to receive(method_for_decode)
        .and_raise(error_to_raise.new('unknown error'))

      expect {
        backend_module.decode(valid_response(:xml))
      }.to raise_error(error_to_raise)
    end
  end
end
