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

      def gl(gl_service_code)
        ::IIJAPI::GP::GL.new(@client, gp_service_code, gl_service_code)
      end

      def default_args
        { "GpServiceCode" => gp_service_code }
      end

      def service_code_list
        call("GetServiceCodeList")
      end

      def contract_information
        call("GetContractInformation")
      end

      def add_clone_virtual_machines(params = {})
        call("AddCloneVirtualMachines", params)
      end

      def add_virtual_machines(params = {})
        call("AddVirtualMachines", params)
      end

      def add_fw_lb_option(params = {})
        call("AddFwLbOption", params)
      end

      def get_virtual_machine_status_list(gc_list)
        call("GetVirtualMachineStatusList", "GcServiceCode" => gc_list)
      end

      def call(api_name, params = {})
        @client.post(api_name, default_args.merge(params))
      end
    end
  end
end
