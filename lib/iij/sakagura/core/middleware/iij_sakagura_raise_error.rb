# -*- coding: utf-8 -*-
require 'faraday'
require 'iij/sakagura/core/error'

module IIJ
  module Sakagura
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
              raise IIJ::Sakagura::Core::Error::BadRequest, response_values(env)
            when 401
              raise IIJ::Sakagura::Core::Error::Unauthorized, response_values(env)
            when 403
              raise IIJ::Sakagura::Core::Error::Forbidden, response_values(env)
            when 404
              raise IIJ::Sakagura::Core::Error::NotFound, response_values(env)
            when 400...500
              raise IIJ::Sakagura::Core::Error::ClientError, response_values(env)
            when 500
              raise IIJ::Sakagura::Core::Error::SystemError, response_values(env)
            when 502
              raise IIJ::Sakagura::Core::Error::BadGateway, response_values(env)
            when 503
              raise IIJ::Sakagura::Core::Error::ServiceUnavailable, response_values(env)
            when 500...600
              raise IIJ::Sakagura::Core::Error::ServerError, response_values(env)
            end

            parse_body(env)
          end

          def response_values(env)
            {:status => env[:status], :headers => env[:response_headers], :body => env[:body]}
          end

          def parse_body(env)
            if env[:body].has_key? "ErrorResponse"
              raise IIJ::Sakagura::Core::Error::BackendError, response_values(env)
            end
          end
        end

        Faraday.register_middleware :response, :iij_sakagura_raise_error => RaiseError
      end
    end
  end
end
