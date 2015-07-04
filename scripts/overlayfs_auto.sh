#!/bin/sh

# manages versioned filesystem changes using overlayfs

# usage: $0 mountpath basedir overlaysdir

# TODO: MAKE EVERYTHING BUT rw_upperdir BE READ-ONLY

DESTINATION="$1"
shift
BASE="$1"
shift $(($#-1))
OVERLAYSPATH="$1"

SCRIPTPATH="$(cd "$(dirname "$0")"&&pwd)"

WORKDIR1="ro_workdir"
WORKDIR2="rw_workdir"
UPPERDIR1="ro_upperdir"
MOUNTPOINT1="ro_mount"
MOUNTPOINT2="$DESTINATION"
VERSIONDIR="history"

mkdir -p "$OVERLAYSPATH" || exit 1
cd "$OVERLAYSPATH"
mkdir -p "$WORKDIR1" "$UPPERDIR1" "$MOUNTPOINT1" "$WORKDIR2" "$MOUNTPOINT2" "$VERSIONDIR" || exit 1
ln -sfn "$MOUNTPOINT2" "rw_mount"
ln -sfn "$BASE" "ro_lowerdir"

cd "$VERSIONDIR"
for overlay in *; do true; done
cd ..
if [ "$overlay" == '*' ]; then
	overlay=0
	MOUNTPOINT1="$BASE"
else
	"$SCRIPTPATH"/overlayfs_copydown.sh "$VERSIONDIR/$overlay" "$UPPERDIR1" &&
	mount -t overlay "$BASE" -o "ro,lowerdir=$BASE,upperdir=$UPPERDIR1,workdir=$WORKDIR1" "$MOUNTPOINT1" || exit 1
fi

# remove any prefixed zeros
overlay=$(echo $overlay | sed 's/^0*//')
# add 1
overlay=$((overlay+1))
# prefix 0s
UPPERDIR2="$VERSIONDIR/$(printf %0.6d $overlay)"

ln -sfn "$MOUNTPOINT1" "rw_lowerdir"
ln -sfn "$UPPERDIR2" "rw_upperdir"

mkdir -p "$UPPERDIR2" &&
mount -t overlay "$MOUNTPOINT1" -o "lowerdir=$MOUNTPOINT1,upperdir=$UPPERDIR2,workdir=$WORKDIR2" "$MOUNTPOINT2"
