# BASH Retroarch Savegame Sync
# https://github.com/ltpitt
#
# This script keeps savefiles and savestates in sync between
# Retroarch devices (e.g. a Raspberry Pi 3 and a PS Vita) that have
# an FTP or SCP connection available.

###
# Customize the following variables according to your setup
###
declare -A CONSOLES=(
                     ["/home/pi"]="local"
                     ["pi@192.168.1.170:/home/pi"]="pitendo"
                     ["ftp://192.168.1.171/sd/retroarch"]="nintendowii"
                     ["ftp://192.168.1.172:1337/ux0:/data/retroarch"]="psvita"
                    )


readonly START=`date +%s`
readonly BACKUP="/home/pi/Backup/savegames/"
readonly MAX_NUMBER_OF_BACKUPS_KEPT=15
readonly TMP="/tmp"
readonly NOW=`date +"%Y%m%d%H%M"`

###
# Script logic, no need to change anything below for setup
###
check_requirements () {
    requirements=( rsync lftp )
    for requirement in "${requirements[@]}"
    do
        if ! command -v $requirement &> /dev/null
        then
            echo "${requirement} command is not available, please install it before running this script."
            exit
        fi
    done
    mkdir -p $TMP/savefiles
    mkdir -p $TMP/savestates    
}


check_hosts () {
    for CONSOLE in "${!CONSOLES[@]}";
    do
        if [[ ${CONSOLES[$CONSOLE]} == "local" ]]; then
            continue
        fi
        read ip < <(echo $CONSOLE | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+')
        if [[ $CONSOLE == "ftp"* ]]; then
            local port=21
        else
            local port=22
        fi
        echo
        echo Checking $CONSOLE - ${CONSOLES[$CONSOLE]} availability...
        if nc -z -w1 "$ip" "$port"; then
            echo "Port ${port} on ip ${ip} is listening."
        else
            echo "Port ${port} on ip ${ip} is not listening, skipping host. Please verify its status or the Retroarch Sync's configuration."
            unset CONSOLES[$CONSOLE]
        fi
    done
}


log_status () {
    local status=$1
    local source=$2
    local target=$3
    echo
    echo "*************************************************************************"
    echo "Status: ${status}"
    echo "Source: ${source}"
    echo "Target: ${target}"
    echo "*************************************************************************"
    echo
}


clean_up () {
    echo "Cleaning up data saved in $TMP"
    rm -rf $TMP/savefiles/*.lftp-pget-status
    rm -rf $TMP/savestates/*.lftp-pget-status
    rm -Rf $TMP/savefiles
    rm -Rf $TMP/savestates
    ITEMS_IN_BACKUP_FOLDER=$(ls $BACKUP  | wc -l)
    if [ "$ITEMS_IN_BACKUP_FOLDER" -gt $MAX_NUMBER_OF_BACKUPS_KEPT ]; then
        echo "Deleting oldest backup"
        cd $BACKUP
        ls $BACKUP -A1t | tail -n -1 | xargs rm -R
    fi
}


check_requirements
check_hosts


###
# Getting existing savefiles and savegames for every available device
###
for CONSOLE in "${!CONSOLES[@]}";
    do
        mkdir -p $BACKUP$NOW/${CONSOLES[$CONSOLE]}/savefiles
        mkdir -p $BACKUP$NOW/${CONSOLES[$CONSOLE]}/savestates
        if [[ $CONSOLE == "ftp"* ]]; then
            read ip < <(echo $CONSOLE | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+')
        
            status="Getting savefiles data and backing it up locally for ${CONSOLES[$CONSOLE]}"
            source="${CONSOLE}/savefiles/"
            target="${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savefiles/"
            log_status "$status" "$source" "$target"

            ftp_command="set ftp:passive-mode off; mirror --use-pget-n=10 ${CONSOLE}/savefiles/ ${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savefiles/; bye"
            lftp -e "${ftp_command}" $ip
            
            status="Getting savestates data and backing it up locally for ${CONSOLES[$CONSOLE]}"
            source="${CONSOLE}/savestates/"
            target="${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savestates"
            log_status "$status" "$source" "$target"
            
            ftp_command="set ftp:passive-mode off; mirror --use-pget-n=10 ${CONSOLE}/savestates/ $BACKUP$NOW/${CONSOLES[$CONSOLE]}/savestates; bye"
            lftp -e "${ftp_command}" $ip
        else
            status="Getting savefiles data and backing it up locally for ${CONSOLES[$CONSOLE]}"
            source="${CONSOLE}/savefiles/"
            target="${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savefiles/"
            log_status "$status" "$source" "$target"
            
            rsync -actzp $CONSOLE/savefiles $BACKUP$NOW/${CONSOLES[$CONSOLE]}
            
            status="Getting savestates data and backing it up locally for ${CONSOLES[$CONSOLE]}"
            source="${CONSOLE}/savestates/"
            target="${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savestates"
            log_status "$status" "$source" "$target"
            
            rsync -actzp $CONSOLE/savestates $BACKUP$NOW/${CONSOLES[$CONSOLE]}
        fi
        
        status="Putting savefiles data (in order to keeping the most recent ones from any device) for ${CONSOLES[$CONSOLE]} in /tmp"
        source="${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savefiles"
        target="${TMP}/savefiles"
        log_status "$status" "$source" "$target"
        
        rsync -actzp --update $BACKUP$NOW/${CONSOLES[$CONSOLE]}/savefiles $TMP
        
        status="Putting savestates data (in order to keeping the most recent ones from any device) for ${CONSOLES[$CONSOLE]} in /tmp"
        source="${BACKUP}${NOW}/${CONSOLES[$CONSOLE]}/savestates"
        target="${TMP}/savestates"
        log_status "$status" "$source" "$target"
        
        rsync -actzp --update $BACKUP$NOW/${CONSOLES[$CONSOLE]}/savestates $TMP
    done


###
# Sending most recent savefiles and savegames to every available device
###
for CONSOLE in "${!CONSOLES[@]}";
    do
        if [[ $CONSOLE == "ftp"* ]]; then
            read ip < <(echo $CONSOLE | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+')

            status="Sending updated savefiles data to ${CONSOLES[$CONSOLE]}"
            source="${TMP}/savefiles"
            target="${CONSOLE}/savefiles"
            log_status "$status" "$source" "$target"
            
            ftp_command="set ftp:passive-mode off; mirror -R ${TMP}/savefiles ${CONSOLE}/savefiles; bye"
            lftp -e "${ftp_command}" $ip
            
            status="Sending updated savestates data to ${CONSOLES[$CONSOLE]}"
            source="${TMP}/savestates"
            target="${CONSOLE}/savestates"
            log_status "$status" "$source" "$target"
            
            ftp_command="set ftp:passive-mode off; mirror -R ${TMP}/savestates ${CONSOLE}/savestates; bye"
            lftp -e "${ftp_command}" $ip
        else
            status="Sending updated savefiles data to ${CONSOLES[$CONSOLE]}"
            source="${TMP}/savefiles"
            target="${CONSOLE}/savefiles"
            log_status "$status" "$source" "$target"
            
            rsync -actzp $TMP/savefiles $CONSOLE
            
            status="Sending updated savestates data to ${CONSOLES[$CONSOLE]}"
            source="${TMP}/savestates"
            target="${CONSOLE}/savestates"
            log_status "$status" "$source" "$target"
            
            rsync -actzp $TMP/savestates $CONSOLE
        fi
    done

clean_up

END=`date +%s`
RUNTIME=$((END-START))
echo "The full run took ${RUNTIME} seconds."
