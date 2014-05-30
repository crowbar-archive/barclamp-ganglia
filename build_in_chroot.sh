#!/bin/bash
#
# Copyright 2011-2013, Dell
# Copyright 2013-2014, SUSE LINUX Products GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

mkdir -p /usr/src/redhat/SOURCES && cd /usr/src/redhat/SOURCES
rpm2cpio /mnt/current_os/pkgs/ganglia-3.1.7-3.fc15.src.rpm | cpio -id
rpmbuild -bb ganglia.spec
cd /usr/src/redhat/RPMS
find . -type f -name '*.rpm' -exec cp '{}' /mnt/current_os/pkgs ';'
