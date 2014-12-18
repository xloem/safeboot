#!/bin/sh

# opens nested loop images, echo'ing the path of the final one

MOUNTPATHPREFIX=/mnt/image/

if [ "$1" = "--undo" ]; then
	shift
	for path in $(ls -rd "$MOUNTPATHPREFIX"*)
	do
		umount "$path" &&
		rm -rf "$path" || exit 1
	done
fi

lastpath=
count=0
for image in "$@"
do
	mountpath=$MOUNTPATHPREFIX$count
	mkdir -p $mountpath &&
	mount "$lastpath$image" "$mountpath" -o ro || exit 1
	count=$((count+1))
	lastpath="$mountpath/"
done

echo "$lastpath"
