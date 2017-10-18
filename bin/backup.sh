#!/bin/bash

function assertDirExists(){
	if [ ! -e $1/$2 ]; then
		echo "$1/$2 does not exist. Trying to mount $1 ..." | tee $HOME/backupProblem.log
#		cd -P $1		cd ..
		mount $1
		if [ ! -e $1/$2 ]; then
			echo "Could not find $1/$2.  No backups made." | tee $HOME/backupProblem.log
			exit 101
		fi
	fi
}

if [ -d "$HOME/NOBACKUP/backup" ]; then
	: ${BACKUPDIR:="$HOME/NOBACKUP/backup"}
	LOG=$BACKUPDIR/backup.lst
	MAJORBACKUP=5
	assertDirExists $BACKUPDIR backup.lst
else
	: ${BACKUPDIR:="$HOME/.my_links/rsyncBackup"}
	assertDirExists $BACKUPDIR
fi

echo "Using dir ${BACKUPDIR} as destination backup directory"

createTunnel(){
	xterm -e "ssh -o PreferredAuthentications=password -L 8022:$1:22 -L 8591:$1:5901 $2"
}

# --archive : recursive, symlinks, permissions, modification times, owner and group, re-create character and block devices (if root)
#trailing slash makes difference
# -nv : dry-run, verbose
# --delete : removes all files at the destination that do not exist on the source

# use every X times this script is run
# --backup : appends a ~ to existing destination files
# --backup-dir=DIR : combine with --backup to tell rsync where to store backups

# --exclude pattern = Exclude files matching pattern.
#	  e.g., --exclude *.bak --exclude *.tmp
# --exclude-from file = Exclude patterns listed in file.

# --one-file-system = don't cross file system boundaries
function backupPartition(){
	if [ "$USER" != "root" ]; then
		echo "!! Must be performed as root. Changing to root." 
		exec sudo $0 "$@"
		exit
	fi
	local CURRDATE=`date +%Y-%m-%d-%H.%M.%S`
	echo "$CURRDATE: backupPartition start" >> /backup.lst
	echo -e "\tBacking up partition, except NOBACKUP dirs."
	rsync --archive -u --one-file-system --delete --exclude NOBACKUP -v / $BACKUPDIR >> $BACKUPDIR/rsync-$CURRDATE.out
	echo "  `date +%Y-%m-%d-%T`: backupPartition end" >> /backup.lst
}
function backupHome(){
	local CURRDATE=`date +%Y-%m-%d-%H.%M.%S`
	echo -e "\tBacking up $1, except cache, trash, and NOBACKUP dirs."
	rsync --archive -u --delete --exclude Cache --exclude cache --exclude Trash --exclude trash --exclude NOBACKUP -v $1 $BACKUPDIR/home >> $BACKUPDIR/rsyncHome-$CURRDATE.out
}
function backupDir(){
	local CURRDATE=`date +%Y-%m-%d-%H.%M.%S`
	echo -e "\tBacking up all directories in $1 to $BACKUPDIR"
	rsync --archive -u --delete -v $1 $BACKUPDIR/$1/.. >> $BACKUPDIR/rsyncDir-$CURRDATE.out
}

MY_BINSRC=${MY_BINSRC:=$HOME/bin/online/src}
EXCLUDELIST=$MY_BINSRC/rsync-exclude.txt
RSYNCSERVER="rsync --archive -u -v --backup --no-g"
RSYNCPREFIX=$MY_BINSRC/rsync

# $1=sourceDirectory $2=server $3=includeset
# e.g., $HOME phillips:/home/$USER base
function backupToServer(){
	[ "$2" ] || { echo "Server not specified."; return 1; }
	local RSYNC_LOGFILE="$BACKUPDIR/rsyncToServer-$3-`date +%Y-%m-%d-%H.%M.%S`-${2%%:*}.out"

	local SERVER=$2
	local RSYNCOPTS=""
	case $2 in
		my-laptop.tunnel:*)
			SERVER=my-laptop.tunnel:.
			;;
		localhost:*)
			[ -d "/media/usb/dnlam" ] || exit 1
			SERVER=localhost:/media/usb/dnlam
			;;
		*)
			;;
	esac

	#echo -e "\tBacking up $1, except cache, trash, and NOBACKUP dirs."
	#RSYNCOPTS="--delete-excluded"  # don't want to delete excluded files on server
	local RSYNCOPTS="$RSYNCOPTS --delete"  # needed to initially remove excluded files on server and to rm deleted files

	 local RSYNCSERVERlocal="$RSYNCSERVER $RSYNCOPTS --backup-dir $BACKUPDIR/rsyncTrash-$3-`date +%Y-%m-%d-%H.%M.%S`-$HOSTNAME --recursive --files-from=$RSYNCPREFIX-$3-include.txt --exclude-from=$RSYNCPREFIX-$3-exclude.txt --exclude-from=$EXCLUDELIST"

	 echo "-----------------------------"
	 echo "The following that begins with 'keep_backup' will be deleted."
	 local SMSO=$(tput smso)
	 local RMSO=$(tput rmso)
	if [ -z "$AUTOMATED" ] ; then
	 echo "- - - - - - - - - DRY RUN - - - - - - - - - - - - -"
	 eval $RSYNCSERVERlocal --dry-run -v $1 $SERVER | grep -v "excluding" | grep -v "^expand" | grep -v "uptodate$" | sed "s/keep_backup/${SMSO}\0${RMSO}/gI; s/deleting/${SMSO}\0${RMSO}/gI" | tee -a $RSYNC_LOGFILE 
	 echo "===================================================" 
	 read -p "Hit Enter to actually perform the rsync: \
		  $RSYNCSERVERlocal $1 $SERVER | tee -a $RSYNC_LOGFILE"
	fi
	eval $RSYNCSERVERlocal $1 $SERVER | tee -a $RSYNC_LOGFILE
}

function restoreFromServer(){
	[ "$2" ] || { echo "Server not specified."; return 1; }

	case $2 in
		my-laptop.tunnel:*)
			local SERVER=my-laptop.tunnel:.
			#local RSYNCOPTS='-e "ssh -p 1022"'
			;;
		*:)
			local SERVER=$2.
			;;
		*:*)
			local SERVER=$2
			;;
		*)
			local SERVER=$2:.
			;;
	esac

	local RSYNCSERVERlocal="$RSYNCSERVER $RSYNCOPTS --backup-dir $BACKUPDIR/rsyncTrash-$3-`date +%Y-%m-%d-%H.%M.%S`-$HOSTNAME --recursive --files-from=$RSYNCPREFIX-$3-include.txt --exclude-from=$RSYNCPREFIX-$3-exclude.txt --exclude-from=$EXCLUDELIST"

	local RSYNC_LOGFILE="$BACKUPDIR/rsyncFromServer-$3-`date +%Y-%m-%d-%H.%M.%S`-${SERVER%%:*}.out"
	#echo -e "\tBacking up $1, except cache, trash, and NOBACKUP dirs."
	echo $RSYNCSERVERlocal $SERVER $1 
	eval $RSYNCSERVERlocal $SERVER $1 | tee -a $RSYNC_LOGFILE

	echo "==================================================="
	echo "Since don't want to --delete local files, Need to check files that are locally present but not on server."
	echo "---- Files that differ from server --------" >> $RSYNC_LOGFILE
	 local SMSO=$(tput smso)
	 local RMSO=$(tput rmso)
	local RSYNCOPTS="--delete $RSYNCOPTS" 
	echo $RSYNCSERVERlocal --dry-run -v $RSYNCOPTS $1 $SERVER | grep -v "excluding" | grep -v "^expand" | grep -v "uptodate$" | sed "s/keep_backup/${SMSO}\0${RMSO}/gI; s/deleting/${SMSO}\0${RMSO}/gI" | tee -a $RSYNC_LOGFILE
	echo "- - - - - - - - - DRY RUN - - - - - - - - - - - - -"
	eval $RSYNCSERVERlocal --dry-run -v $RSYNCOPTS $1 $SERVER | grep -v "excluding" | grep -v "^expand" | grep -v "uptodate$" | sed "s/keep_backup/${SMSO}\0${RMSO}/gI; s/deleting/${SMSO}\0${RMSO}/gI" | tee -a $RSYNC_LOGFILE
	echo "==================================================="
}

sendTgz(){
	pushd $1

	[ -f "$BACKUPDIR/archive-$3.tgz" ] && { read -p "$BACKUPDIR/archive-$3.tgz will be replaced.  Ctrl-C to cancel." || return 111; }

	# remove empty lines and comments
	sed -e '/^ *$/d' -e '/^#/d' $RSYNCPREFIX-$3-include.txt > $BACKUPDIR/tar-$3-include.txt
	tar -zvc -f $BACKUPDIR/archive-$3.tgz --exclude-from=$EXCLUDELIST --exclude-from=$RSYNCPREFIX-$3-exclude.txt --files-from=$BACKUPDIR/tar-$3-include.txt
	ls -alh $BACKUPDIR/archive-$3.tgz
	read -p "Press Enter to ftp archive-$3.tgz to $2." || exit 222
	~/bin/direct/ftp.sh init
	echo "cd www/.my_backup/
sunique
put $BACKUPDIR/archive-$3.tgz archive-$3.tgz
quit
" | ~/bin/direct/ftp.sh $2
	popd
}

getTgz(){
	pushd $1
	cd ~/.my_backup # $BACKUPDIR
	echo "cd www/.my_backup/
sunique
get $3
quit
" | ~/bin/direct/ftp.sh $2
	popd
}

if [ -d "$1" ] ; then
	backupDir "$1"
	echo "`date +%Y-%m-%d-%T`: backupDir $1 only" >> $LOG
	exit 1
elif [ "$1" ]; then
	 AUTOMATED="T"
	actionChoice="$1"
	 rsyncServerChoice="$2"
	 rsyncSetChoice="$3"
else
	. $MY_BINSRC/helperfuncs.src
	 echo "--------------------------------------------------"
	choose toServer fromServer backupTo backup2localhost restoreFromBlackhat-ssh createTunnel sendTgz getTgz home system rootpartition || exit 1
	#choose home system rootpartition homeToServer homeFromServer syncFromServer rsyncBaseToWebServer rsyncBaseToMainServer rsyncBaseFromMainServer
	 actionChoice=$CHOICE

	 case $actionChoice in
		createTunnel)
			createTunnel my-laptop ssh.someserver.utexas.edu &
			read -p "Creating tunnel to my-laptop as my-laptop.tunnel" -t 5
			exit
		;;
		getTgz )
				echo "--------------------------------------------------"
				choose "ftp.netfirms.com" || exit 1
				# echo CHOICE=$CHOICE
				rsyncServerChoice=$CHOICE
				rsyncSetChoice="pubhtml_twiki.tar.gz"
			;;
		sendTgz )
				echo "--------------------------------------------------"
				choose "ftp.netfirms.com" || exit 1
				# echo CHOICE=$CHOICE
				rsyncServerChoice=$CHOICE

				echo "--------------------------------------------------"
				choose base x11 private work webpage server || exit 1
				# echo CHOICE=$CHOICE
				rsyncSetChoice=$CHOICE
				[ -f "$RSYNCPREFIX-$rsyncSetChoice-include.txt" ] || { echo "Rsync include file $RSYNCPREFIX-$rsyncSetChoice-include.txt not found!"; exit 3; } 
		;;
		backupTo )
				echo "--------------------------------------------------"
				#echo "MAINSERVER=$MAINSERVER  MY_WEBSERVER=$MY_WEBSERVER"
				choose $MAINSERVER $MY_WEBSERVER $OTHERHOST "localhost" "my-pc" "blackhat-ssh" "my-laptop.tunnel" "blackhat" || exit 1
				# echo CHOICE=$CHOICE
				rsyncServerChoice=$CHOICE
				#ping -c 1 $rsyncServerChoice || { echo "Can't ping $rsyncServerChoice."; exit 2; }
		;;
		toServer | fromServer )
				echo "--------------------------------------------------"
				#echo "MAINSERVER=$MAINSERVER  MY_WEBSERVER=$MY_WEBSERVER"
				choose $MAINSERVER $MY_WEBSERVER $OTHERHOST "localhost" "my-laptop.tunnel" "hadoop1" "my-laptop2" || exit 1
				# echo CHOICE=$CHOICE
				rsyncServerChoice=$CHOICE
				#ping -c 1 $rsyncServerChoice || { echo "Can't ping $rsyncServerChoice."; exit 2; }

				echo "--------------------------------------------------"
				choose base x11 private work server || exit 1
				# echo CHOICE=$CHOICE
				rsyncSetChoice=$CHOICE
				[ -f "$RSYNCPREFIX-$rsyncSetChoice-include.txt" ] || { echo "Rsync include file $RSYNCPREFIX-$rsyncSetChoice-include.txt not found!"; exit 3; } 
		;;
		default)
		;;
	 esac
	 echo "=================================================="
fi


case $actionChoice in
	sendTgz | getTgz )
		$actionChoice $HOME $rsyncServerChoice $rsyncSetChoice
		echo "============= DONE $rsyncSetChoice =================="
		[ "$AUTOMATED" ] || read -p "Done.  Hit Enter."
		exit 0
	;;
	 toServer) backupToServer $HOME/ $rsyncServerChoice: $rsyncSetChoice
		echo "============= DONE $rsyncSetChoice =================="
		[ "$AUTOMATED" ] || read -p "Done.  Hit Enter."
		exit 0
	 ;;
	 fromServer) restoreFromServer $HOME/ $rsyncServerChoice: $rsyncSetChoice
		echo "============= DONE $rsyncSetChoice =================="
		[ "$AUTOMATED" ] || read -p "Done.  Hit Enter."
		exit 0
	 ;;
	 backupTo) 
		#ping -c 1 "$rsyncServerChoice" || read -p "Cannot ping $rsyncServerChoice.  Press Ctrl-C to quit."
		case "$rsyncServerChoice" in
			blackhat*) 	SETS="base x11 private server webpage";;
			my-pc) 	SETS="base x11 private server work";;
			*) 			SETS="base x11";;
		esac
		for SET in $SETS; do
			echo backup.sh toServer $rsyncServerChoice $SET
			     backup.sh toServer $rsyncServerChoice $SET
		done
		[ "$AUTOMATED" ] || read -p "Done.  Hit Enter."
		exit 0
	 ;;
	 backup2localhost)
		backup.sh toServer localhost base
		backup.sh toServer localhost x11
		backup.sh toServer localhost private
		backup.sh toServer localhost server
		backup.sh toServer localhost webpage
		[ "$AUTOMATED" ] || read -p "Done.  Hit Enter."
		exit 0
	 ;;
	restoreFromBlackhat-ssh)
		backup.sh fromServer blackhat-ssh base
		backup.sh fromServer blackhat-ssh x11
		backup.sh fromServer blackhat-ssh private
		backup.sh fromServer blackhat-ssh webpage
		[ "$AUTOMATED" ] || read -p "Done.  Hit Enter."
		exit 0
	;;

	rootpartition)
		backupPartition
		echo "Partition backup." >> $LOG
		[ "$AUTOMATED" ] || read -p "Done.  Hit Enter."
		exit 0
	;;
	home)
		backupHome $HOME
		echo "`date +%Y-%m-%d-%T`: backupHome $HOME excluding NOBACKUP, cache, and trash" >> $LOG
		[ "$AUTOMATED" ] || read -p "Done.  Hit Enter."
		exit 1
	;;
	system)
		echo "`date +%Y-%m-%d-%T`: system backup" >> $LOG
		chmod 777 $LOG
		NUMRECENTBACKUPS=`cat $LOG | wc -l`
		echo "Doing backup to $BACKUPDIR : $NUMRECENTBACKUPS since last major backup"
		#mkdir $BACKUPDIR/archives
		backupHome /home/dnlam
		backupHome /home/alam
		backupDir /root
		backupDir /etc
		# fix fstab so that the backup can boot correctly
		#mv $BACKUPDIR/etc/fstab $BACKUPDIR/etc/fstab.orig
		#cat $BACKUPDIR/etc/fstab.orig | sed -e "s/^\(LABEL=slack\) /\# from (\1)\nLABEL=slack91 /" -e "s/^\(\/dev\/hda\)/\# from (\1) \n\/dev\/hdc/" > $BACKUPDIR/etc/fstab
		# -e "s/\(.* swap *defaults .*\)/# (\1)/" 

		backupDir /usr/local/bin
		backupDir /usr/local/sbin
		backupDir /boot

		if [ $NUMRECENTBACKUPS -gt $MAJORBACKUP ]; then
			BACKUPDIR2=$BACKUPDIR/../backup2
			if [ -d "$BACKUPDIR2" ] ; then 
				echo -e "\n--------------- Doing major backup to $BACKUPDIR2 -------------\n"
				mv $LOG "$BACKUPDIR/backupMajor-`date +%Y-%m-%d-%H.%M.%S`.lst"
				touch $LOG
				chmod 777 $LOG
				rsync -v --archive --delete $BACKUPDIR/ $BACKUPDIR2
			else
				echo "Did not do major backup because $BACKUPDIR2 does not exists."
			fi
		else
			echo -e "\n($MAJORBACKUP-$NUMRECENTBACKUPS) until next major backup"
		fi
		[ "$AUTOMATED" ] || read -p "Done.  Hit Enter."
		exit 0
	;;
esac


