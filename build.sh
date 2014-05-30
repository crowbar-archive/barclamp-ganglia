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

GANGLIA_RPMS=(ganglia-gmetad-3.1.7-3.x86_64.rpm \
    ganglia-gmond-3.1.7-3.x86_64.rpm \
    ganglia-gmond-python-3.1.7-3.x86_64.rpm \
    ganglia-3.1.7-3.x86_64.rpm \
    ganglia-web-3.1.7-3.x86_64.rpm \
    ganglia-devel-3.1.7-3.x86_64.rpm)

bc_needs_build() {
    for pkg in ${GANGLIA_RPMS[@]}; do
	[[ -f $BC_CACHE/$OS_TOKEN/pkgs/$pkg ]] && continue
	return 0
    done
    return 1
}

bc_build() {
    sudo cp "$BC_DIR/build_in_chroot.sh" "$CHROOT/tmp"
    in_chroot /tmp/build_in_chroot.sh
    local pkg
    for pkg in "${GANGLIA_RPMS[@]}"; do
	[[ -f $BC_CACHE/$OS_TOKEN/pkgs/$pkg ]] || \
	    die "Ganglia build process did not build $pkg!"
	if [[ $CURRENT_CACHE_BRANCH ]]; then
	    (cd "$BC_CACHE/$OS_TOKEN/pkgs"; git add "$pkg")
	fi
    done
}
