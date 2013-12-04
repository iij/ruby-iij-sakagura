require 'forwardable'

module IIJAPI
  module GP
    class GL
      def initialize(client, gp_service_code, gl_service_code)
        @client = client
        @gp_service_code = gp_service_code
        @gl_service_code = gl_service_code
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

      def lb_info(force = false)
        @lb_info = nil if force
        @lb_info ||= describe_lb
        @lb_info
      end

      def lb_info!
        lb_info(force = true)
      end

      def set_label(label)
        @client.post("SetLabel",
                     "GpServiceCode" => gp_service_code,
                     "ServiceCode" => gl_service_code,
                     "Label" => label)
      end
      alias :label= :set_label

      def add_or_update_virtual_server(virtual_server_name, port, protocol, pool, traffic_ip_name_list = nil)
        lb_vserver = lb_info['VirtualServerList'].find{|lb_vserver| lb_vserver['Name'] == virtual_server_name }
        if lb_vserver
          # already exist
          set_lb_virtual_server(virtual_server_name, port, protocol, pool, traffic_ip_name_list)
        else
          # create a new vserver
          add_lb_virtual_server(virtual_server_name, port, protocol, pool, traffic_ip_name_list)
        end
      end

      def add_lb_virtual_server(virtual_server_name, port, protocol, pool, traffic_ip_name_list = nil)
        opts = {
          "VirtualServerName" => virtual_server_name,
          "Port" => port,
          "Protocol" => protocol,
          "Pool" => pool
        }
        opts["TrafficIpName"] = traffic_ip_name_list if traffic_ip_name_list
        call('AddLbVirtualServer', opts)
      end

      def set_lb_virtual_server(virtual_server_name, port, protocol, pool, traffic_ip_name_list = nil)
        opts = {
          "VirtualServerName" => virtual_server_name,
          "Port" => port,
          "Protocol" => protocol,
          "Pool" => pool
        }
        opts["TrafficIpName"] = traffic_ip_name_list if traffic_ip_name_list
        call('SetLbVirtualServer', opts)
      end

      def delete_lb_virtual_server(virtual_server_name)
        call('DeleteLbVirtualServer', "VirtualServerName" => virtual_server_name)
      end

      def add_or_update_pool(pool, nodes)
        lb_pool = lb_info['PoolList'].find{|lb_pool| lb_pool['Name'] == pool }
        if lb_pool
          # already exist
          set_lb_pool(pool, nodes)
        else
          # create a new pool
          add_lb_pool(pool, nodes)
        end
      end

      def add_lb_pool(pool, nodes)
        opts = {
          "Pool" => pool
        }
        nodes.each.with_index(1) do |node, i|
          opts["NodeIpAddress.#{i}"] = node[0]
          opts["NodePort.#{i}"] = node[1]
        end

        call("AddLbPool", opts)
      end

      def set_lb_pool(pool, nodes)
        opts = {
          "Pool" => pool
        }
        nodes.each.with_index(1) do |node, i|
          opts["NodeIpAddress.#{i}"] = node[0]
          opts["NodePort.#{i}"] = node[1]
        end

        call("SetLbPool", opts)
      end

      def add_lb_node(pool, node)
        opts = {
          "Pool" => pool,
          "NodeIpAddress" => node[0],
          "NodePort" => node[1]
        }

        call("AddLbNode", opts)
      end

      def delete_lb_pool(pool)
        call("DeleteLbPool", "Pool" => pool)
      end

      def delete_lb_node(pool, node)
        opts = {
          "Pool" => pool,
          "NodeIpAddress" => node[0],
          "NodePort" => node[1]
        }

        call("DeleteLbNode", opts)
      end

      def change_fw_lb_option_type(type)
        call("ChangeFwLbOptionType", "Type" => type)
      end

      def call(api_name, params = {})
        @client.post(api_name, default_args.merge(params))
      end
    end
  end
end
