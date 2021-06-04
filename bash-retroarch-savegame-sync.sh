# BASH Retroarch Savegame SyncThingie by @pitto
# https://github.com/ltpitt
#
# This script keeps to keep savegames in sync between
# Retroarch devices (e.g. a Raspberry Pi 3 and a PS Vita) that have
# an FTP or SCP connection available.
#

# Customize the following variables according to your setup

declare -A CONSOLES=(
                     ["/home/pi"]="local"
                     ["pi@retropie:/home/pi"]="pitendo"
                     ["ftp://nintendowii/sd/retroarch"]="nintendowii"
                     ["ftp://psvita:1337/ux0:/data/retroarch"]="psvita"
                    )

START=`date +%s`
BACKUP="/home/pi/Backup/savegames/"
MAX_NUMBER_OF_BACKUPS_KEPT=15
TMP="/tmp"


# No need to change anything below for setup
NOW=`date +"%Y%m%d%H%M"`

rm -Rf $TMP/savefiles || echo "Could not delete ${TMP}/savefiles"
rm -Rf $TMP/savestates || echo "Could not delete ${TMP}/savestates"
mkdir -p $TMP/savefiles
mkdir -p $TMP/savestates

for CONSOLE in "${!CONSOLES[@]}";
    do
        mkdir -p $BACKUP$NOW/${CONSOLES[$CONSOLE]}/savefiles
        mkdir -p $BACKUP$NOW/${CONSOLES[$CONSOLE]}/savestates
        if [[ $CONSOLE == "ftp"* ]]; then
            echo 
            echo "*************************************************************************"
            echo "Getting savefiles and savestates data for ${CONSOLES[$CONSOLE]}"
            echo "Source 1: ${CONSOLE}/savefiles"
            echo "Target 1: ${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savefiles"
            echo "Source 2: ${CONSOLE}/savestates"
            echo "Target 2: ${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savestates"
            echo "*************************************************************************"
            echo
            read ip < <(echo $CONSOLE | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+')
            read path < <(echo $CONSOLE | awk -F $ip '{print $2}')
            ftp_command="set ftp:passive-mode off; mirror --use-pget-n=10 ${CONSOLE}/savefiles/ ${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savefiles/; mirror --use-pget-n=10 ${CONSOLE}/savestates/ $BACKUP$NOW/${CONSOLES[$CONSOLE]}/savestates; bye"
            lftp -e "${ftp_command}" $ip
        else
            echo 
            echo "*************************************************************************"
            echo "Getting savefiles data for ${CONSOLES[$CONSOLE]}"
            echo "Source: ${CONSOLE}/savefiles"
            echo "Target: ${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savefiles"
            echo "*************************************************************************"
            echo
            rsync -actzp $CONSOLE/savefiles $BACKUP$NOW/${CONSOLES[$CONSOLE]}
            echo 
            echo "*************************************************************************"
            echo "Getting savestates data for ${CONSOLES[$CONSOLE]}"
            echo "Source: ${CONSOLE}/savestates"
            echo "Target: ${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savestates"
            echo "*************************************************************************"
            echo
            rsync -actzp $CONSOLE/savestates $BACKUP$NOW/${CONSOLES[$CONSOLE]}
        fi
        echo 
        echo "*************************************************************************"
        echo "Putting savefiles data for ${CONSOLES[$CONSOLE]} in /tmp"
        echo "Source: ${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savefiles"
        echo "Target: ${TMP}/savefiles"
        echo "*************************************************************************"
        echo
        rsync -actzp --update $BACKUP$NOW/${CONSOLES[$CONSOLE]}/savefiles $TMP
        echo 
        echo "*************************************************************************"
        echo "Putting savestates data for ${CONSOLES[$CONSOLE]} in /tmp"
        echo "Source: ${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savestates"
        echo "Target: ${TMP}/savestates"
        echo "*************************************************************************"
        echo
        rsync -actzp --update $BACKUP$NOW/${CONSOLES[$CONSOLE]}/savestates $TMP
    done

rm -rf $TMP/savefiles/*.lftp-pget-status
rm -rf $TMP/savestates/*.lftp-pget-status

for CONSOLE in "${!CONSOLES[@]}";
    do
        if [[ $CONSOLE == "ftp"* ]]; then
            echo
            echo "*************************************************************************"
            echo "Sending updated savefiles and savestates data to ${CONSOLES[$CONSOLE]}"
            echo "Source 1: ${TMP}/savefiles"
            echo "Target 1: ${CONSOLE}/savefiles"
            echo "Source 2: ${TMP}/savestates"
            echo "Target 2: ${CONSOLE}/savestates"
            echo "*************************************************************************"
            echo
            read ip < <(echo $CONSOLE | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+')
            read path < <(echo $CONSOLE | awk -F $ip '{print $2}')
            ftp_command="set ftp:passive-mode off; mirror -R ${TMP}/savefiles ${CONSOLE}/savefiles; mirror -R ${TMP}/savestates ${CONSOLE}/savestates; bye"
            lftp -e "${ftp_command}" $ip
        else
            echo 
            echo "*************************************************************************"
            echo "Sending updated savefiles data to ${CONSOLES[$CONSOLE]}"
            echo "Source: ${TMP}/savefiles"
            echo "Target: ${CONSOLE}/savefiles"
            echo "*************************************************************************"
            echo
            rsync -actzp $TMP/savefiles $CONSOLE
            echo 
            echo "*************************************************************************"
            echo "Sending updated savestates data to ${CONSOLES[$CONSOLE]}"
            echo "Source: ${TMP}/savestates"
            echo "Target: ${CONSOLE}/savestates"
            echo "*************************************************************************"
            echo
            rsync -actzp $TMP/savestates $CONSOLE
        fi
    done


ITEMS_IN_BACKUP_FOLDER=$(ls $BACKUP  | wc -l)
if [ "$ITEMS_IN_BACKUP_FOLDER" -gt $MAX_NUMBER_OF_BACKUPS_KEPT ]; then
    echo "Deleting oldest backup"
    cd $BACKUP
    ls $BACKUP -A1t | tail -n -1 | xargs rm -R
fi

END=`date +%s`
RUNTIME=$((END-START))
echo $RUNTIME
