#!/bin/sh

# manages an increasing list of overlays using aufs

# usage: $0 mountpath basedir overlaysdir [overlaysdir ...]

# TODO: the top overlay should be on a different partition from the bottom overlays (move them over)
# the partition containing the bottom overlays should be remounted read-only prior to mount

DESTINATION="$1"
shift
BASE="$1"
shift

mkdir -p "$DESTINATION"

BRSTR="$BASE=rr"

for OVERLAYSPATH in "$@"; do
	mkdir -p "$OVERLAYSPATH" || continue

	cd "$OVERLAYSPATH"
	for overlay in *; do
		if [ "$overlay" = '*' ]; then
			overlay=0
		else
			BRSTR="$(pwd)/$overlay=rr+wh:$BRSTR"
		fi
	done
done

# remove any prefixed zeros
overlay=$(echo $overlay | sed 's/^0*//')
# add 1
overlay=$((overlay+1))
# prefix 0s
overlay=$(printf %0.6d $overlay)

mkdir -p "$overlay"

mount -t aufs -o "br:$overlay:$BRSTR" "$OVERLAYSPATH" "$DESTINATION"

