require 'forwardable'
require 'iij/sakagura/core/query_client'

module IIJ
  module Sakagura
    module GP
      class Client
        extend Forwardable

        DEFAULT_OPTIONS = {
          :endpoint => 'https://gp.api.iij.jp/',
          :api_version => '20130901'
        }

        def initialize(opts = {})
          opts = DEFAULT_OPTIONS.merge(opts)
          @client = ::IIJ::Sakagura::Core::QueryClient.new(opts)
        end

        def_delegators :@client, :get, :post

        def gp(gp_service_code)
          GP.new(self, gp_service_code)
        end

        def gp_service_code_list
          post("GetGpServiceCodeList")["GpServiceCodeList"]
        end
      end
    end
  end
end
