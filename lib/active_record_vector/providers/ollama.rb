# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module ActiveRecordVector
  module Providers
    # Ollama Embedding Provider for 100% free, local, private offline AI embeddings
    class Ollama < Base
      DEFAULT_MODEL = "nomic-embed-text"
      DEFAULT_HOST = "http://localhost:11434"

      def embed(text)
        base_host = options[:host] || ENV["OLLAMA_HOST"] || DEFAULT_HOST
        uri = URI.parse("#{base_host.chomp('/')}/api/embeddings")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        http.open_timeout = options[:timeout] || 15
        http.read_timeout = options[:timeout] || 15

        payload = {
          model: options[:model] || DEFAULT_MODEL,
          prompt: text
        }

        request = Net::HTTP::Post.new(uri.request_uri, {
                                        "Content-Type" => "application/json"
                                      })
        request.body = payload.to_json

        response = http.request(request)
        raise Error, "Ollama API Error (#{response.code}): #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        data = JSON.parse(response.body)
        data["embedding"] || []
      end
    end
  end
end
