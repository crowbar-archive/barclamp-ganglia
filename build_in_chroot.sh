#!/bin/bash
mkdir -p /usr/src/redhat/SOURCES && cd /usr/src/redhat/SOURCES
rpm2cpio /mnt/current_os/pkgs/ganglia-3.1.7-3.fc15.src.rpm | cpio -id
rpmbuild -bb ganglia.spec
cd /usr/src/redhat/RPMS
find . -type f -name '*.rpm' -exec cp '{}' /mnt/current_os/pkgs ';'
