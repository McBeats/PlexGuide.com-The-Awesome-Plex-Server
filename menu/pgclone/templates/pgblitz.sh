{% raw %}
#!/bin/bash
#
# Title:      PlexGuide (Reference Title File)
# Author(s):  Admin9705 & PhysK
# URL:        https://plexguide.com - http://github.plexguide.com
# GNU:        General Public License v3.0
################################################################################
source /opt/plexguide/menu/functions/pgblitz.sh

starter
stasks

file="/var/plexguide/blitz.last"
  if [ -e "$file" ]; then
    GDSAARRAY=(`ls -la /opt/appdata/pgblitz/keys/processed | awk '{print $9}' | grep gdsa`)
    GDSACOUNT=`expr ${#GDSAARRAY[@]}`
    GDSAUSE=$(cat "/var/plexguide/blitz.last")
    GDSAUSE=${GDSAUSE:5}
    if [ "$GDSAUSE" == "" ]; then $GDSAUSE=gdsa01; fi
    if [ ${GDSAUSE} -ge ${GDSACOUNT} ]; then
        GDSAUSE="0"
        GDSAAMOUNT=0
    else
        GDSAUSE=`expr $GDSAUSE + 1`
        GDSAAMOUNT=0
fi; fi

# Run Loop
while [ 1 ]
do

  blitzdef=$(cat /var/plexguide/blitz.last)
  if [ "$blitzdef" == "" ]; then GDSAUSE=0 && echo gdsa01 > /var/plexguide/blitz.last; fi
    #Find files to transfer
    IFS=$'\n'
    files=(`find ${downloadpath}/move -type f ! -name '*partial~' ! -name '*_HIDDEN~' ! -name '*.fuse_hidden*' ! -name "*.lck" ! -name "*.version" ! -path '.unionfs-fuse/*' ! -path '.unionfs/*' ! -path '*.inProgress/*'`)
    if [[ ${#files[@]} -gt 0 ]]; then
        # If files are found loop though and upload
        log "Files found to upload"
        for i in "${files[@]}"
        do
            # If file has a lockfile skip
            if [ -e ${i}.lck ]; then
                log "Lock File found for $i"
                continue
            else
                # Check if file is still getting bigger
                FILESIZE1=`wc -c < "$i"`
                sleep 3
                FILESIZE2=`wc -c < "$i"`
                if [ "$FILESIZE1" -ne "$FILESIZE2" ]; then
                log "File is still getting bigger $i"
                    continue
                fi

                # Check if we have any upload slots available
                TRANSFERS=`ls -la /opt/appdata/pgblitz/pid/ | grep trans | wc -l`
                if [ ! $TRANSFERS -ge 8 ]; then
                    if [ -e $i ]; then
                    log "Starting upload of $i"
                        # Append filesize to GDSAAMOUNT
                        GDSAAMOUNT=`echo "$GDSAAMOUNT + $FILESIZE2" | bc`

                        # Run upload script demonised
                        /opt/appdata/pgblitz/upload.sh $i ${GDSAARRAY[$GDSAUSE]} &

                        PID=$!
                        FILEBASE=`basename $i`

                        # Add transfer to pid directory
                        echo "$PID" > /opt/appdata/pgblitz/pid/$FILEBASE.trans

                        # Increase or reset $GDSAUSE?
                        if [ "$GDSAAMOUNT" -gt "768831531520" ]; then
                            log "${GDSAARRAY[$GDSAUSE]} has hit 730GB switching to next SA"
                            if [ ${GDSAUSE} -eq ${GDSACOUNT} ]; then
                                GDSAUSE=0
                                GDSAAMOUNT=0
                            else
                                GDSAUSE=`expr $GDSAUSE + 1`
                                GDSAAMOUNT=0
                            fi
                            # Record next GDSA in case of crash/reboot
                            echo "$GDSAUSE" > /opt/appdata/pgblitz/vars/lastGDSA
                        fi
                        log "${GDSAARRAY[$GDSAUSE]} is now `echo "$GDSAAMOUNT/1024/1024" | bc` MB of 750000"
                        # Record GDSA transfered in case of crash/reboot
                        echo "$GDSAAMOUNT" > /opt/appdata/pgblitz/vars/gdsaAmount
                    else
                        log "File $i seems to have dissapeared"
                    fi
                else
                    log "Already 8 transfers running, waiting for next loop"
                    break
                fi
            fi
            log "Sleeping 30s before looking at next file"
            sleep 30
        done
        log "Finished looking for files, sleeping 30 secs"
    else
        log "Nothing to upload, sleeping 30 secs"
        log "Running Blitz Finder for files not uploaded"
        log "${GDSAARRAY[$GDSAUSE]} is now `echo "$GDSAAMOUNT/1024/1024" | bc` MB of 750000 MB"
        finder
    fi
    sleep 30
    echo "${GDSAARRAY[$GDSAUSE]}" > /var/plexguide/blitz.last
done
{% endraw %}
