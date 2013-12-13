module IIJ
  module Sakagura
    module Core
      module Error
        class APIError < StandardError
          def initialize(message = nil, *args)
            if message and message.kind_of? Hash
              @details = message
              if res = @details.fetch(:body, {})["ErrorResponse"]
                @error_type = res["ErrorType"]
                message = res["ErrorMessage"] if res["ErrorMessage"]
              end
            end

            super
          end

          attr_reader :details
          attr_reader :error_type

          [:status, :headers, :body].each do |key|
            define_method(key) do
              details[key]
            end
          end
        end

        class BadRequest < APIError; end
        class Unauthorized < APIError; end
        class Forbidden < APIError; end
        class NotFound < APIError; end
        class ClientError < APIError; end
        class SystemError < APIError; end
        class BadGateway < APIError; end
        class ServiceUnavailable < APIError; end
        class ServerError < APIError; end
        class BackendError < APIError; end
      end
    end
  end
end
