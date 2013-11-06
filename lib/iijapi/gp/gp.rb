require 'forwardable'

module IIJAPI
  module GP
    class GP
      def initialize(client, gp_service_code)
        @client = client
        @gp_service_code = gp_service_code
      end
      attr_reader :gp_service_code

      def inspect
        %[#<#{self.class.name} @gp_service_code="#{gp_service_code}">]
      end

      def gc(gc_service_code)
        ::IIJAPI::GP::GC.new(@client, gp_service_code, gc_service_code)
      end

      def default_args
        { "GpServiceCode" => gp_service_code }
      end

      def service_code_list
        @client.post("GetServiceCodeList", default_args)
      end

      def contract_information
        @client.post("GetContractInformation", default_args)
      end

      def add_clone_virtual_machines(params = {})
        @client.post("AddCloneVirtualMachines", default_args.merge(params))
      end

      def add_virtual_machines(params = {})
        @client.post("AddVirtualMachines", default_args.merge(params))
      end

      def add_fw_lb_option(params = {})
        @client.post("AddFwLbOption", default_args.merge(params))
      end
    end
  end
end
