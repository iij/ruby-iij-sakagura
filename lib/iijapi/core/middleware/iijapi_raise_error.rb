# -*- coding: utf-8 -*-
require 'faraday'
require 'iijapi/core/error'

module IIJAPI
  module Core
    module Middleware
      class RaiseError < Faraday::Response::Middleware
        def initialize(app)
          super(app)
        end

        def on_complete(env)
          case env[:status]
          when 200...300
            nil
          when 400
            raise IIJAPI::Core::Error::BadRequest, response_values(env)
          when 401
            raise IIJAPI::Core::Error::Unauthorized, response_values(env)
          when 403
            raise IIJAPI::Core::Error::Forbidden, response_values(env)
          when 404
            raise IIJAPI::Core::Error::NotFound, response_values(env)
          when 400...500
            raise IIJAPI::Core::Error::ClientError, response_values(env)
          when 500
            raise IIJAPI::Core::Error::SystemError, response_values(env)
          when 502
            raise IIJAPI::Core::Error::BadGateway, response_values(env)
          when 503
            raise IIJAPI::Core::Error::ServiceUnavailable, response_values(env)
          when 500...600
            raise IIJAPI::Core::Error::ServerError, response_values(env)
          end

          parse_body(env)
        end

        def response_values(env)
          {:status => env[:status], :headers => env[:response_headers], :body => env[:body]}
        end

        def parse_body(env)
          if env[:body].has_key? "ErrorResponse"
            raise IIJAPI::Core::Error::BackendError, response_values(env)
          end
        end
      end

      Faraday.register_middleware :response, :iijapi_raise_error => RaiseError
    end
  end
end
