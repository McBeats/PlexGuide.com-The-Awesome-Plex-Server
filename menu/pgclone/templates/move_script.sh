#!/bin/bash
#
# Title:      PlexGuide (Reference Title File)
# Author(s):  Admin9705
# URL:        https://plexguide.com - http://github.plexguide.com
# GNU:        General Public License v3.0
################################################################################
if pidof -o %PPID -x "$0"; then
   exit 1
fi

sleep 15
while true
do
## Sync, Sleep 2 Minutes, Repeat. BWLIMIT 9 Prevents Google 750GB Google Upload Ban
rclone move --config /opt/appdata/plexguide/rclone.conf --bwlimit {{bandwidth.stdout}}M \
  --tpslimit 6 --exclude='**partial~' --exclude="**_HIDDEN~" --exclude=".unionfs/**" \
  --exclude=".unionfs-fuse/**" --checkers=16 --max-size 99G --log-file=/opt/appdata/plexguide/rclone \
  --log-level INFO --stats 5s /mnt/move {{ver.stdout}}:/
sleep 30
# Remove empty directories (MrWednesday)
find "/mnt/move/" -mindepth 2 -type d -empty -delete
done
