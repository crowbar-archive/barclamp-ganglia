#!/bin/bash
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
