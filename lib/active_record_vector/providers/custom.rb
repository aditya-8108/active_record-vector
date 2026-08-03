# frozen_string_literal: true

module ActiveRecordVector
  module Providers
    # Custom provider allowing any Proc, Lambda, or custom object responding to #call or #embed
    class Custom < Base
      def embed(text)
        callable = options[:with] || options[:proc]
        raise Error, "Custom provider requires options[:with] to be a Proc or object responding to #call" unless callable

        if callable.respond_to?(:call)
          callable.call(text)
        elsif callable.respond_to?(:embed)
          callable.embed(text)
        else
          raise Error, "Custom provider options[:with] must respond to #call or #embed"
        end
      end
    end
  end
end
