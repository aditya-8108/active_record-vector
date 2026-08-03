# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module ActiveRecordVector
  module Providers
    # Cohere Embedding Provider
    class Cohere < Base
      DEFAULT_MODEL = "embed-english-v3.0"
      API_ENDPOINT = "https://api.cohere.com/v1/embed"

      def embed(text)
        api_key = options[:api_key] || ENV.fetch("COHERE_API_KEY", nil)
        raise Error, "Cohere API key missing. Set ENV['COHERE_API_KEY'] or pass api_key: '...'" unless api_key

        uri = URI.parse(options[:endpoint] || API_ENDPOINT)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")

        payload = {
          texts: [text],
          model: options[:model] || DEFAULT_MODEL,
          input_type: options[:input_type] || "search_document"
        }

        request = Net::HTTP::Post.new(uri.request_uri, {
                                        "Content-Type" => "application/json",
                                        "Authorization" => "Bearer #{api_key}"
                                      })
        request.body = payload.to_json

        response = http.request(request)
        raise Error, "Cohere API Error (#{response.code}): #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        data = JSON.parse(response.body)
        data.dig("embeddings", 0) || []
      end
    end
  end
end
