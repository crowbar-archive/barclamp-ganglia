# Copyright 2012, Dell 
# 
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
# 
#  http://www.apache.org/licenses/LICENSE-2.0 
# 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License. 
# 

class GangliaService < ServiceObject
  
  def transition(inst, name, state)
    @logger.debug("Ganglia transition: make sure that network role is on all nodes: #{name} for #{state}")
    
    #
    # If we are discovering the node, make sure that we add the ganglia client or server to the node
    #
    if state == "discovered"
      @logger.debug("Ganglia transition: discovered state for #{name} for #{state}")

      prop = @barclamp.get_proposal(inst)

      return [400, "Ganglia Proposal is not active"] unless prop.active?

      nodes = prop.active_config.get_nodes_by_role("ganglia-server")
      result = true
      if nodes.empty?
        @logger.debug("Ganglia transition: make sure that ganglia-server role is on first: #{name} for #{state}")
        result = add_role_to_instance_and_node(name, inst, "ganglia-server")
        nodes = [ Node.find_by_name(name) ]
      else
        node = Node.find_by_name(name)
        unless nodes.include? node
          @logger.debug("Ganglia transition: make sure that ganglia-client role is on all nodes but first: #{name} for #{state}")
          result = add_role_to_instance_and_node(name, inst, "ganglia-client")
        end
      end
      
      # Set up the client url
      if result 
        # Get the server IP address
        node = nodes.first
        server_ip = node.address("public").addr rescue node.address.addr
        
        # The Ganglia interface expects IP addresses to be passed in the link references.
        # The background collection processes explicitly use the node IP addresses to name
        # the RRD image caching directories which are used for Ganglia graphs.
        # See /var/lib/ganglia/rrds/Crowbar PoC/* on the Ganalia server node for
        # an example. PW - 05/02/2012 
        unless server_ip.nil?
          node = Node.find_by_name(name)
          chash = prop.active_config.get_node_config_hash(node)
          chash["crowbar"] = {} if chash["crowbar"].nil?
          chash["crowbar"]["links"] = {} if chash["crowbar"]["links"].nil?
          chash["crowbar"]["links"]["Ganglia"] = "http://#{server_ip}/ganglia/?c=Crowbar PoC&h=#{node.name}&m=load_one&r=hour&s=descending&hc=4&mc=2"
          prop.active_config.set_node_config_hash(node, chash)
        end 
      end
      
      @logger.debug("Ganglia transition: leaving from discovered state for #{name} for #{state}")
      a = [200, "" ] if result
      a = [400, "Failed to add role to node"] unless result
      return a
    end
    
    @logger.debug("Ganglia transition: leaving for #{name} for #{state}")
    [200, ""]
  end
  
end
