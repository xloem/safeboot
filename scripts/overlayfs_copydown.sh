#!/bin/sh

# usage: $0 upperdir lowerdir
# Hardlinks the changes from an upperdir down onto a lowerdir
# This facilitates storing versioned changes while only using 2 stacked overlays.

upperdir="$1"
lowerdir="$2"
lowerdir="$(cd "$lowerdir"&&pwd)"

cd "$upperdir"

echo "Scanning changes in $upperdir ..." 1>&2
find | while read upper; do
	lower="$lowerdir/$upper"
	if ! [ -e "$lower" ]; then continue; fi
	if [ -d "$upper" ]; then
		if [ -d "$lower" ]; then
			opaque="$(getfattr --only-values -n trusted.overlay.opaque "$upper" 2>/dev/null)"
			if [ "y" == "$opaque" ]; then
				echo "OpaqueDir: $upper" 1>&2
				rm -rf "$lower"
			fi
		else
			echo "File->Dir: $upper" 1>&2
			rm -rf "$lower"
		fi
	elif [ -d "$lower" ]; then
		echo "Dir->File: $upper" 1>&2
		rm -rf "$lower"
	fi
done

echo "Hardlinking into $lowerdir ..." 1>&2
cp -alf . "$lowerdir"/.
