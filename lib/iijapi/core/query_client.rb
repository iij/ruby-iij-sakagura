require 'faraday'
require 'faraday_middleware'
require 'iijapi/core/hash_to_query'
require 'iijapi/core/middleware/signature_v2'
require 'iijapi/core/middleware/iijapi_raise_error'

module IIJAPI
  module Core
    class QueryClient
      def initialize(opts = {})
        @endpoint = opts[:endpoint]
        @access_key = opts[:access_key]
        @secret_key = opts[:secret_key]
        @api_version = opts[:api_version]
        @expire_after = opts[:expire_after]
      end

      attr_reader :endpoint

      def agent
        @agent ||= Faraday.new(:url => @endpoint) do |builder|
          builder.request :signature_v2, :access_key => @access_key, :secret_key => @secret_key, :expire_after => @expire_after
          builder.request :url_encoded
          builder.response :iijapi_raise_error
          builder.response :json, :content_type => /\bjson$/
          builder.adapter Faraday.default_adapter
        end
      end

      def make_request(action, params = {})
        {
          "Action" => action,
          "APIVersion" => @api_version
        }.merge(IIJAPI::Core.hash_to_query(params))
      end

      def post(action, params = {})
        res = agent.post('/json') do |req|
          req.body = make_request(action, params)
        end
        res.body[action + 'Response']
      end
    end
  end
end
