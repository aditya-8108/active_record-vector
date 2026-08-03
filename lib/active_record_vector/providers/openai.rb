# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module ActiveRecordVector
  module Providers
    # OpenAI Embedding Provider (supports text-embedding-3-small, text-embedding-3-large, text-embedding-ada-002)
    class Openai < Base
      DEFAULT_MODEL = "text-embedding-3-small"
      API_ENDPOINT = "https://api.openai.com/v1/embeddings"

      def embed(text)
        api_key = options[:api_key] || ENV.fetch("OPENAI_API_KEY", nil)
        raise Error, "OpenAI API key missing. Set ENV['OPENAI_API_KEY'] or pass api_key: '...' to has_vector" unless api_key

        uri = URI.parse(options[:endpoint] || API_ENDPOINT)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        http.open_timeout = options[:timeout] || 10
        http.read_timeout = options[:timeout] || 10

        payload = {
          input: text,
          model: options[:model] || DEFAULT_MODEL
        }
        payload[:dimensions] = options[:dimensions] if options[:dimensions]

        request = Net::HTTP::Post.new(uri.request_uri, {
                                        "Content-Type" => "application/json",
                                        "Authorization" => "Bearer #{api_key}"
                                      })
        request.body = payload.to_json

        response = http.request(request)
        raise Error, "OpenAI API Error (#{response.code}): #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        data = JSON.parse(response.body)
        data.dig("data", 0, "embedding") || []
      end
    end
  end
end
