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

      def call(api_name, params = {})
        @client.post(api_name, default_args.merge(params))
      end
    end
  end
end
