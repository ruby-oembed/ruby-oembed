module OEmbed
  module Formatter
    # Some quick verification of Formatter Backend classes
    class BackendTest
      # Instantiate & run the confirmation
      def self.confirm(formatter_class, backend)
        new(formatter_class, backend).confirm
      end

      attr_accessor :formatter_class, :backend

      def initialize(formatter_class, backend)
        @formatter_class = formatter_class
        @backend = backend
      end

      # Ensure the given backend can correctly parse values
      # using the decode method.
      # Otherwise, raises a LoadError.
      def confirm
        confirm_decode_method
        confirm_decode_works
      end

      private

      def confirm_decode_method
        return true if backend.respond_to?(:decode)

        # rubocop:disable Metrics/LineLength
        fail LoadError,
             "The given backend must respond to the decode method: #{backend.inspect}"
        # rubocop:enable Metrics/LineLength
      end

      # rubocop:disable Metrics/AbcSize
      def confirm_decode_works
        expected = expected_decode_values
        actual = backend.decode(decode_test_values)

        # For the test to be true
        # the actual output Hash should have the exact same list of keys
        # _and_ the values should be the same if we ignoring typecasting.
        return true if
          actual.keys.sort == expected.keys.sort &&
          !actual.detect { |key, value| value.to_s != expected[key].to_s }

        msg = decode_fail_msg
        msg ||= 'The given backend failed to decode the test string correctly'
        fail LoadError, "#{msg}: #{backend.inspect}"
      end
      # rubocop:enable Metrics/AbcSize

      def expected_decode_values
        {
          'version' => 1.0,
          'string' => 'test',
          'int' => 42,
          'html' => "<i>Cool's</i>\n the \"word\"!"
        }
      end

      def decode_test_values
        formatter_class.send(:test_value)
      end

      def decode_fail_msg
        backend.decode_fail_msg
      rescue
        nil
      end
    end
  end
end
