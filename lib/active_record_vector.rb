# frozen_string_literal: true

require_relative "active_record_vector/version"
require_relative "active_record_vector/distance"
require_relative "active_record_vector/chunker"
require_relative "active_record_vector/providers/base"
require_relative "active_record_vector/providers/openai"
require_relative "active_record_vector/providers/ollama"
require_relative "active_record_vector/providers/cohere"
require_relative "active_record_vector/providers/custom"
require_relative "active_record_vector/model"
require_relative "active_record_vector/migration_helper"

module ActiveRecordVector
  class Error < StandardError; end

  class << self
    # Provider registry lookup
    def provider_for(provider_name, options = {})
      case provider_name.to_sym
      when :openai
        Providers::Openai.new(options)
      when :ollama
        Providers::Ollama.new(options)
      when :cohere
        Providers::Cohere.new(options)
      when :custom
        Providers::Custom.new(options)
      else
        if provider_name.is_a?(Class) && provider_name < Providers::Base
          provider_name.new(options)
        elsif provider_name.respond_to?(:call) || provider_name.respond_to?(:embed)
          Providers::Custom.new(options.merge(with: provider_name))
        else
          raise Error, "Unknown embedding provider: #{provider_name.inspect}"
        end
      end
    end
  end
end

# Auto-hook into ActiveRecord if defined
ActiveRecord::Base.include(ActiveRecordVector::Model) if defined?(ActiveRecord::Base)
