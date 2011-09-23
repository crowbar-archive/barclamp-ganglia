#
# Default attributes for system.
#
def redhat_platform?
  ["redhat","centos","fedora"].include?(platform)
end

default[:ganglia][:module_path] = "/usr/lib/ganglia/"
default[:ganglia][:module_path] = "" if redhat_platform?
default[:ganglia][:interface_eval] = '#{"eth0"}'

