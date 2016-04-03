RSpec.shared_examples 'a JSON backend' do
  let(:backend_format) { :json }
  let(:format_module)  { OEmbed::Formatter::JSON }

  it_behaves_like 'an OEmbed::Formatter backend'
end

RSpec.shared_examples 'an XML backend' do
  let(:backend_format) { :xml }
  let(:format_module)  { OEmbed::Formatter::XML }

  it_behaves_like 'an OEmbed::Formatter backend'
end

RSpec.shared_examples 'an OEmbed::Formatter backend' do
  it 'should support the format' do
    expect {
      OEmbed::Formatter.supported?(backend_format)
    }.to_not raise_error
  end

  it 'should be using the correct backend' do
    expect(format_module.backend)
      .to eq(backend_module)
  end

  it 'should decode valid input' do
    decoded = backend_module.decode(valid_response(backend_format))
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
        backend_module.decode(backend_format, given_input)
      }.to raise_error
    end
  end

  context 'given an unclosed xml continer' do
    let(:given_input) { invalid_response('unclosed_container', backend_format) }
    it_behaves_like 'a backend'
  end

  context 'given an unclosed xml tag' do
    let(:given_input) { invalid_response('unclosed_tag', backend_format) }
    it_behaves_like 'a backend'
  end

  context 'given invalid xml syntax' do
    let(:given_input) { invalid_response('invalid_syntax', backend_format) }
    it_behaves_like 'a backend'
  end

  context 'given an unexpected error when parsing xml' do
    it 'should not catch that error when decoding' do
      error_to_raise = ZeroDivisionError
      expect(format_module.backend.parse_error)
        .to_not be_kind_of(error_to_raise)

      expect(object_for_decode).to receive(method_for_decode)
        .and_raise(error_to_raise.new('unknown error'))

      expect {
        backend_module.decode(valid_response(backend_format))
      }.to raise_error(error_to_raise)
    end
  end
end
