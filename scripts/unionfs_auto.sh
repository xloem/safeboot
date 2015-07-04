#!/bin/sh

# TODO: the top overlay should be on a different partition from the bottom overlays (move them over)
# the partition containing the bottom overlays should be remounted read-only prior to mount

if let "$# < 3"; then
	echo "Usage: $0 mountpath basedir overlaysdir [overlaysdir ...]"
	echo "Manages an increasing list of overlays using unionfs-fuse."
	exit 1
fi

DESTINATION="$1"
shift
BASE="$1"
shift
for RWOVERLAYSPATH in "$@"; do true; done

CHROOT_PATH="$RWOVERLAYSPATH/.unionfs-chroot"

mkdir -p "$CHROOT_PATH/0" "$DESTINATION" || exit 1

mount --bind "$BASE" "$CHROOT_PATH/0" || exit 1
BRSTR="/0=RO"

overlays=0
for OVERLAYSPATH in "$@"; do
	overlays=$((overlays+1))
	mkdir -p "$OVERLAYSPATH" "$CHROOT_PATH/$overlays" || continue
	mount --bind "$OVERLAYSPATH" "$CHROOT_PATH/$overlays" || continue

	cd "$OVERLAYSPATH"
	for overlay in *; do
		if [ "$overlay" = '*' ]; then
			overlay=0
		else
			BRSTR="/$overlays/$overlay=RO:$BRSTR"
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
BRSTR="/$overlays/$overlay=RW:$BRSTR"

unionfs -o allow_other,use_ino,suid,dev,nonempty -ocow,chroot="$CHROOT_PATH",max_files=32768 "$BRSTR" "$DESTINATION"

