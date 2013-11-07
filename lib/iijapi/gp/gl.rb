require 'forwardable'

module IIJAPI
  module GP
    class GL
      def initialize(client, gp_service_code, gl_service_code)
        @client = client
        @gp_service_code = gp_service_code
        @gl_service_code = gl_service_code
        @cache
      end
      attr_reader :gp_service_code
      attr_reader :gl_service_code

      def inspect
        %[#<#{self.class.name} @gp_service_code="#{gp_service_code}", @gl_service_code="#{gl_service_code}">]
      end

      def default_args
        {
          "GpServiceCode" => gp_service_code,
          "GlServiceCode" => gl_service_code
        }
      end

      def get_contract_status
        call('GetContractStatus')['Status']
      end

      def describe_lb
        call('DescribeLb')
      end

      def describe_fw
        call('DescribeFw')
      end

      def set_label(label)
        @client.post("SetLabel",
                     "GpServiceCode" => gp_service_code,
                     "ServiceCode" => gl_service_code,
                     "Label" => label)
      end
      alias :label= :set_label

      def call(api_name, params = {})
        @client.post(api_name, default_args.merge(params))
      end
    end
  end
end
