#!/bin/sh

# This script opens /dev/mapper partitions from a block device leaving no
# block on the device unencrypted, maximizing available storage space.

# TODO fully consider:
#   - DOS or GPT partition table
#   - crypttab format
#   - LUKS headers

# Opens a swap partition at the start of the drive, then evenly divides
# all remaining space among the given number of data areas.

SWAPMEGS=$((16*1024))
DATAS=3
DEVICE=$1
SECTORSIZE=512
DEVICESECTORS=3907029168
ALIGNMENTSECTORS=4
CRYPTSETUPARGS="--type plain -c aes-xts-plain64 -s 512"

retrkey()
{
	read -s -r PASSPHRASE
}

outputkey()
{
	echo -n "$PASSPHRASE"
	cat keyfile2
}

closekey()
{
	PASSPHRASE=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
}

# swap header is 1 memory page large, assume 4k memory pages
SWAPSECTORS=$(((SWAPMEGS * 1024 * 1024 + 4096) / SECTORSIZE ))

DATASECTORS=$(((DEVICESECTORS-SWAPSECTORS)/DATAS/ALIGNMENTSECTORS*ALIGNMENTSECTORS))
SWAPSECTORS=$((DEVICESECTORS-DATASECTORS*DATAS))
OFFSET=0

setup()
{
	label=$1
	size=$2
	outputkey | cryptsetup $CRYPTSETUPARGS -d - --shared --offset $OFFSET --skip $OFFSET --size $size open "$DEVICE" "$label"
	OFFSET=$((OFFSET+size))
}

retrkey

setup swap $SWAPSECTORS
DATA=0
while test $DATA -lt $DATAS
do
	setup data-$DATA $DATASECTORS
	DATA=$((DATA+1))
done

closekey
