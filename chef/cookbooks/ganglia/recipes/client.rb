# GANLIA monitoring client recipe
# Copyright 2011, Dell
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

# Work around some packaging bugs in ganglia and nagios.
user "ganglia" do
  system true
  shell "/bin/false"
end

group "ganglia" do
  members "ganglia"
end

user "ganglia" do
  action :modify
  gid "ganglia"
end

case node[:platform]
when "ubuntu","debian"
  pkg_name = "ganglia-monitor"
  config_file = "/etc/ganglia/gmond.conf"
  svc_name = "ganglia-monitor"
when "redhat","centos"
  pkg_name = "ganglia-gmond"
  config_file = "/etc/ganglia/gmond.conf"
  svc_name = "gmond"
end

package pkg_name

# Begin recipe transactions
Chef::Log.debug("BEGIN ganlia-client")

if ["delete","reset"].member?(node[:state])
  service "ganglia-monitor" do
    pattern "gmond"
    action [:stop, :disable]
  end

  file config_file do
    action :delete
  end
else
  admin_interface = Ganglia::Evaluator.get_value_by_type(node,:interface_eval)

  template config_file do
    source "gmond.conf.erb" 
    variables( :admin_interface => admin_interface )
    notifies :restart, "service[ganglia-monitor]"
  end

  service "ganglia-monitor" do
    service_name svc_name
    supports :restart => true
    pattern "gmond"
    running true
    enabled true
    action [ :enable, :start ]
  end
end

# End of recipe transactions
Chef::Log.debug("END ganglia-client")

