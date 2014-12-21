#!/bin/sh

# manages an increasing list of overlays using aufs

BASE="$1"
OVERLAYSPATH="$2"
DESTINATION="$3"

mkdir -p "$OVERLAYSPATH" "$DESTINATION"

BRSTR="$BASE=rr"

cd "$OVERLAYSPATH"
if [ -d "0" ]; then
	for overlay in *; do
		BRSTR="$overlay=rr:$BRSTR"
	done
	# remove any prefixed zeros
	overlay=$(echo $overlay | sed 's/^0*//')
	# add 1
	overlay=$((overlay+1))
	# prefix 0s
	overlay=$(printf %0.6d $overlay)
else
	overlay=0
fi
mkdir -p "$overlay"

mount -t aufs -o "br:$overlay:$BRSTR" "$OVERLAYSPATH" "$DESTINATION"

