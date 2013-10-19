# -*- coding: utf-8 -*-
require 'faraday'
require 'time'
require 'base64'

module IIJAPI
  module Core
    module Middleware
      class SignatureV2 < Faraday::Middleware
        SIGNATURE_KEY = "Signature".freeze
        def initialize(app, options = {})
          @access_key = options[:access_key]
          @secret_key = options[:secret_key]
          @expire_after = options[:expire_after] || 3600
          p options
          super(app)
        end

        def call(env)
          env[:body] = required_params.merge(env[:body])
          str = make_canonicalized_string(env)
          env[:body][SIGNATURE_KEY] = generate_signature(str)
          @app.call(env)
        end

        def required_params
          expire = Time.now + @expire_after

          {
            "AccessKeyId" => @access_key,
            "SignatureVersion" => "2",
            "SignatureMethod" => "HmacSHA256",
            "Expire" => expire.utc.xmlschema
          }
        end

        def make_canonicalized_string(env)
          p env
          url = env[:url]
          hh =
            if [80, 443].include? url.port
              url.host
            else
              "#{url.host}:#{url.port}"
            end
          [
           env[:method].upcase,
           hh,
           url.path,
           make_query_str(env[:body])
          ].join("\n")
        end

        def escape(str)
          CGI.escape(str).gsub('+', '%20').gsub('%7E', '~')
        end

        def generate_signature(str)
          digest_method = OpenSSL::Digest::SHA256.new
          digest = OpenSSL::HMAC.digest(digest_method, @secret_key, str)
          Base64.encode64(digest).chomp
        end

        def make_query_str(params)
          params.sort_by{|k,v| k}.map{|k,v| escape(k) + "=" + escape(v) }.join('&')
        end
      end
      Faraday.register_middleware :request, :signature_v2 => SignatureV2
    end
  end
end
