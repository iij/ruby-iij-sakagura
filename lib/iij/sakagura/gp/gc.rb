require 'forwardable'

module IIJ
  module Sakagura
    module GP
      class GC
        def initialize(client, gp_service_code, gc_service_code)
          @client = client
          @gp_service_code = gp_service_code
          @gc_service_code = gc_service_code
        end
        attr_reader :gp_service_code
        attr_reader :gc_service_code

        def inspect
          %[#<#{self.class.name} @gp_service_code="#{gp_service_code}", @gc_service_code="#{gc_service_code}">]
        end

        def default_args
          {
            "GpServiceCode" => gp_service_code,
            "GcServiceCode" => gc_service_code
          }
        end

        def describe_virtual_machine
          call('DescribeVirtualMachine')
        end

        def info(opts = {})
          @info = nil if opts[:force]
          @info ||= describe_virtual_machine
          @info
        end

        def info!
          info(:force => true)
        end

        def [](attr)
          info[attr]
        end

        def get_contract_status
          call('GetContractStatus')['Status']
        end

        def contract_status(opts = {})
          @contract_status = nil if opts[:force]
          @contract_status ||= get_contract_status
          @contract_status
        end

        def contract_status!
          contract_status(:force => true)
        end

        def get_virtual_machine_status
          call('GetVirtualMachineStatus')['Status']
        end

        def status(opts = {})
          @status = nil if opts[:force]
          @status ||= get_virtual_machine_status
          @status
        end

        def status!
          status(:force => true)
        end

        def start
          call('StartVirtualMachine')
        end

        def stop(force = false)
          call('StopVirtualMachine', { "Force" => force ? "Yes" : "No" })
        end

        def reboot
          call('RebootVirtualMachine')
        end

        def initialize_vm(var_device_name = nil)
          opts = {}
          opts["VarDeviceName"] = var_device_name if var_device_name
          call('InitializeVirtualMachine', opts)
        end

        def import_ssh_public_key(public_key)
          call('ImportRootSshPublicKey', "PublicKey" => public_key)
        end

        def set_label(label)
          @client.post("SetLabel",
                       "GpServiceCode" => gp_service_code,
                       "ServiceCode" => gc_service_code,
                       "Label" => label)
        end
        alias :label= :set_label

        def change_vm_type(vm_type)
          call('ChangeVirtualMachineType', "VirtualMachineType" => vm_type)
        end

        def attach_fwlb(gl_service_code)
          call('AttachFwLb', "GlServiceCode" => gl_service_code)
        end

        def detach_fwlb(gl_service_code)
          call('DetachFwLb', "GlServiceCode" => gl_service_code)
        end

        def wait_for_start(opts = {}, &block)
          wait_while(proc { status! == "Starting" }, opts, &block)
        end

        def wait_for_stop(opts = {}, &block)
          wait_while(proc { status! == "Stopping" }, opts, &block)
        end

        def wait_while(checker, opts = {}, &block)
          opts[:wait_sec] ||= 10
          catch(:abort) do
            while checker.call
              block.call if block
              sleep opts[:wait_sec]
            end
          end
        end

        def call(api_name, params = {})
          @client.post(api_name, default_args.merge(params))
        end
      end
    end
  end
end
