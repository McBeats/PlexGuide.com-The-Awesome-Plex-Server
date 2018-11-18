#!/usr/bin/env python3
#
# GitHub:   https://github.com/Admin9705/PlexGuide.com-The-Awesome-Plex-Server
# Author:   Admin9705
# URL:      https://plexguide.com
#
# PlexGuide Copyright (C) 2018 PlexGuide.com
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################
touch /var/plexguide/pg.hetzner.stored
start=$( cat /var/plexguide/pg.hetzner )
stored=$( cat /var/plexguide/pg.hetzner.stored )

if [ "$start" != "$stored" ]; then

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⌛  INSTALLING: Hetzner's HCloud
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Assist's in generating virtual machines for Hetzner Cloud Servers!

PLEASE STANDBY!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

# Standby
sleep 5

# Execute Install
file="/bin/hcloud"
path="opt/appdata/plexguide"
version="v1.10.0"
tar="hcloud-linux-amd64-v1.10.0.tar.gz"

if [ ! -e "$file" ]; then
wget -P /$path "https://github.com/hetznercloud/cli/releases/download/$version/$tar"
else
  rm -rf /bin/hcloud
  wget -P /$path "https://github.com/hetznercloud/cli/releases/download/$version/$tar"
fi

tar -xvf /$path/$tar
mv /$path/$tar/bin/hcloud /bin/
#rm -rf /$path/$tar 1>/dev/null 2>&1

# Prevents From Repeating
cat /var/plexguide/pg.hetzner > /var/plexguide/pg.hetzner.stored

fi