#!/bin/bash

PRIVATEDIR=$MY_EHOMEDIR
[ -d "$PRIVATEDIR/encrypted" ] || mkdir -p $PRIVATEDIR/encrypted

# check if this was sourced
case "$0" in
	*bash) SOURCED="true";;
esac
if [ "$SOURCED" ] && [ -f "$HOME/.gpg-agent-info" ] ; then
  	source "$HOME/.gpg-agent-info"
  	eval `cut -d= -f 1 < $HOME/.gpg-agent-info | xargs echo export`
else

getAgent(){
	# Do we need to check the current environment variable settings, similar to SSH variables?
	# - Don't think so, since variables aren't being set like ssh does

	[ -s "$HOME/.gnupg/secring.gpg" ] || crypt.sh getPrivateFile secring

   # 'kill -0' checks to see if agent is responding
   if [ -f "$HOME/.gpg-agent-info" ] && kill -0 `cut -d: -f 2 $HOME/.gpg-agent-info` 2>/dev/null; then
   	echo "Connecting to existing gpg-agent"
   	source "$HOME/.gpg-agent-info"
   	eval `cut -d= -f 1 < $HOME/.gpg-agent-info | xargs echo export`
   else
   	killall gpg-agent
		[ "$VERBOSE" ] && true
		echo "Starting new gpg-agent"
   	eval `gpg-agent --daemon --write-env-file --log-file $HOME/.gpg-agent.log`
   fi
}

# go to ~/.gnupg/autosource for further help

gpg-encrypt(){
	# gpg password disables echo: stty -echo, so have to enable it
	trap "stty echo" INT

	TERM=xterm gpg -sea $GPGARGS --local-user $GPGID -r $GPGID --yes "$1"
	GPGRESULT=$?	
	echo "gpg-encrypt exit value=$GPGRESULT"
	if [ $GPGRESULT -eq 0 ] ; then
		echo "======== Removing unencrypted temporary file."
		rm -vf "$1"
		echo "======== Successfully encrypted."
	elif [ $GPGRESULT -eq 2 ]; then
		echo "======== Cancelled by user or failed password 3 times. Discarding changes."
		rm -v "$1"
	elif [ $GPGRESULT -eq 130 ]; then
		echo "======== Discarding changes."
		rm -v "$1" 
	else
		echo "errcode: $GPGRESULT"
		echo "!!!!!! Problems encrypting $1.  Needs to be encrypted using:"
		echo " 	gpg -seat --local-user $GPGID -r $GPGID $1"
	fi
}

crypt(){
	[ ! "$GPGID" ] && echo "Set GPGID first." && return 1
	if [ ! -f "$1" ] ; then	
		echo "File not found: $1"
		read -p "About to create new encrypted file $1.  Hit Ctrl-C to cancel."
		touch "$1"
		open.sh "$1"
	fi
	if [ -f "$1" ] ; then	
		if [ "${1##*.}" == "asc" ] ; then
			# In RedHat, if TERM=rxvt and rxvt is not included under /usr/share/terminfo, gpg doesn't display password prompt correctly			
			export TERM=xterm
			if TERM=xterm gpg --quiet -r $GPGID $1; then
				local DECRYPTED=${1%.*}
				open.sh $DECRYPTED
			else
				echo "Error decrypting $1"
				return 1
			fi
		else
			cp -iv "$1"{,.bak}
			local DECRYPTED="$1"
		fi
		read -p "Press key to encrypt."
		gpg-encrypt "$DECRYPTED" && [ -e "$DECRYPTED.bak" ] && rm -iv "$DECRYPTED.bak"
	fi
}

sortedText(){
	[ ! "$SNOTES" ] && local SNOTES=$PRIVATEDIR/encrypted/home/.mysnotes.asc
	: ${GPGID:=dnlambo@email.com}
	echo $GPGID $SNOTES 
	if [ "$SNOTES" ] ; then
		case "$SNOTES" in
				*Desktop*) mountEncFS Desktop 0 && trap "{ sleep 600; umountEncFS homedir; }&" TERM KILL QUIT EXIT;;
				*) mountEncFS homedir 0 && trap "{ sleep 600; umountEncFS homedir; }&" TERM KILL QUIT EXIT;;
		esac
		if [ $# -eq 0 ]; then
			local DECRYPTED=${SNOTES%.*}
			if [ ! -f "$SNOTES" ]; then
				echo "Creating $SNOTES"
				touch "$DECRYPTED"
			else
				TERM=xterm gpg --quiet -r $GPGID "$SNOTES"
			fi
			if [ -f "$DECRYPTED" ]; then
				${EDITOR:-vim -n "+set nobackup"} "$DECRYPTED"
				echo "========= Sorting ... "
				sort -o "$DECRYPTED" "$DECRYPTED"
				echo "========= About to save: "
				GPGARGS="-t" gpg-encrypt "$DECRYPTED"
				read -t 30 -p "======== Screen will be cleared in 30 seconds or keypress"
				clear
			fi
		else # find something in file
			TERM=xterm gpg --quiet -r $GPGID --decrypt $SNOTES | grep --ignore-case $*
			read -t 30 -p "======== Screen will be cleared in 30 seconds or keypress"
			clear
		fi
#	else 
  # 	# old way
  # 	local TKPASMAN=tkpasman
  # 	[ "$HOSTNAME" = "phillips.ece.utexas.edu" ] && TKPASMAN=tkpasman-redhat
  # 	if [ $# -eq 0 ]; then
  # 		$TKPASMAN
  # 	else
  # 		DISPLAY="" $TKPASMAN --dump | grep --ignore-case $*
  # 		read -t 30 -p "Screen will be cleared in 30 seconds or keypress"
  # 		clear
  # 	fi
	fi
}
findPwd(){
	[ ! "$SNOTES" ] && local SNOTES=$PRIVATEDIR/encrypted/home/.mysnotes.asc
	: ${GPGID:=dnlambo@email.com}
	if [ "$SNOTES" ] ; then
		mountEncFS homedir 0 && trap "{ umountEncFS homedir; }&" TERM KILL QUIT EXIT
		if [ "$1" ]; then # find something in file
			TERM=xterm gpg --quiet -r $GPGID --decrypt $SNOTES | grep --ignore-case "$1"
		fi
	fi
}

mountEncFS(){
	df | grep "$1/encrypted" > /dev/null && return 0
	# to allow others to see the fs, must be root: sudo encfs ~/.encryptedDesktop $HOME/Desktop/encrypted/ -- -o allow_other
	# Note that root can see the encrypted directory if changes to the user: 'su - $USER'
	# so set a time limit for the mount, unless umounting will follow in a script
   # 480 mins = 8 hours
	MOUNTTTL=${2:-540}
	if [ "$MOUNTTTL" -gt 0 ]; then
		ENCFS_ARGS="--idle=$MOUNTTTL"
	fi
	echo "mountEncFS $1"
	case "$1" in
		"homedir" | ".homedir" )  [ -d $MY_EHOMEDIR/encrypted ] || mkdir $MY_EHOMEDIR/encrypted; encfs $ENCFS_ARGS ~/.encryptedhomedir $MY_EHOMEDIR/encrypted || return ;;
		"private" | ".private" )  [ -d $MY_EPRIVATE/encrypted ] || mkdir $MY_EPRIVATE/encrypted; encfs $ENCFS_ARGS ~/online/Dropbox/.encryptedprivate $MY_EPRIVATE/encrypted || return ;;
		*) 
			[ -d "$PWD/encrypted" ] || mkdir -p "$PWD/encrypted"
			encfs $ENCFS_ARGS "$PWD"/.encrypted"$1" "$PWD"/encrypted || return
		;;
	esac
}
umountEncFS(){
   if mount | grep "encfs .*$1/encrypted" > /dev/null; then
		case "$1" in
			"homedir" | ".homedir" )  fusermount -u $MY_EHOMEDIR/encrypted && rmdir $MY_EHOMEDIR/encrypted || return ;;
			"private" | ".private" )  fusermount -u $MY_EPRIVATE/encrypted && rmdir $MY_EPRIVATE/encrypted || return ;;
		# echo "Unmounting ~/$1"
			*) fusermount -u "$PWD"/encrypted && rmdir "$PWD"/encrypted ;;
		esac
	else
		return 410
	fi

	#TODO: ?? 
   if mount | grep "encfs .*${1%/*}" > /dev/null; then
		{
			date
			echo "Could not umount: $1" 
		} >> $HOME/warning.txt
	fi
}
interactiveMount(){
	MOUNT_DIR=${1:-Desktop}
	if [ -d "$MOUNT_DIR/encrypted" ]; then
		xterm -name "mountencfs" -e "echo Already mounted: $MOUNT_DIR/encrypted && sleep 10" &
	else
		xterm -name "mountencfs" -title "Encrypted fs: $MOUNT_DIR/encrypted" -e "crypt.sh mount $MOUNT_DIR && read -p \"Press enter to umount $MOUNT_DIR/encrypted\" && crypt.sh umount $MOUNT_DIR || read -p \"!!! A problem occurred !!!\";"
	fi
}

getPrivateFile(){
	case "$1" in
		secring | secring.gpg) 
			PRIVFILE="$PRIVATEDIR/encrypted/home/gnupg/secring.gpg.asc"
			DESTFILE="$HOME/.gnupg/secring.gpg"
			PRIVTTL=480  # let this be unique
			CHECKTIMESTAMP=true
		;;
		*) 
			PRIVFILE="$1" 
			DESTFILE="$2"
			PRIVTTL="${3:-10}"
			CHECKTIMESTAMP="${4:-true}"
		;;
	esac
	mountEncFS homedir $PRIVTTL 
#&& trap "umountEncFS homedir" TERM KILL QUIT EXIT
	SLEEPERID=`pgrep -f "sleep $PRIVTTL"`  # kill existing TTL threads
	[ "$SLEEPERID" ] && kill $SLEEPERID &> /dev/null

	# remove existing file
	if [ -s "$DESTFILE" ]; then
		rm -iv "$DESTFILE"
	else
		rm -fv "$DESTFILE"
	fi
	[ -f "$DESTFILE" ] && { echo "File still exists $DESTFILE !!! Exiting."; return 901; }

	[ -f "$PRIVFILE" ] || { echo "File does not exists $PRIVFILE !!! Exiting."; return 902; }

	# place homedir file as $DESTFILE
	if file "$PRIVFILE" | grep ": PGP armored" &> /dev/null; then
		echo gpg -d --output "$DESTFILE" "$PRIVFILE" || exit 820
		TERM=xterm gpg -d --output "$DESTFILE" "$PRIVFILE" || exit 820
	else
		cp -av "$PRIVFILE" "$DESTFILE" || exit 821
	fi

	chmod go-rwx "$DESTFILE"

	# start a TTL thread for the $DESTFILE
	[ "${PRIVTTL}" ] && {
		trap "crypt.sh removePrivateFile \"$DESTFILE\"" TERM KILL QUIT EXIT
		touch "$DESTFILE.tstamp"
		sleep $PRIVTTL
	} & 
}

removePrivateFile(){
		[ -f "$1" ] || return 0
		if [ -f "$1.tstamp" ] && [ "$1" -nt "$1.tstamp" ]; then
			xmessage "File $1 has changed!  Update homedir directory and delete $1{,.tstamp}."
		else
			rm -vf "$1"{,.tstamp}
		fi
}

case "$1" in
   "m" | "mount" ) shift
		mountEncFS ${1:-Desktop}
  		;;
   "u" | "umount" | "unmount" ) shift
   	umountEncFS ${1:-Desktop}
   	;;
	"xmount" ) shift
		interactiveMount $1
		;;
	"sortedText" ) shift
		sortedText "$@"
	;;
	"find" ) shift
		findPwd "$1"
	;;
   "" )
	    echo "crypt [file | {m|mount|u|unmount|umount|tempmount} directory]"
   	 echo "  either mounts or unmounts encrypted file system"
   	 echo "  OR encrypts/decrypts a file"
   ;;
	startAgent | getAgent) getAgent ;;
	getPrivateFile) getPrivateFile "$2" ;;
	removePrivateFile) removePrivateFile "$2" ;;
	clean)
		# kill all sleeping processes, which should rm homedir files
		pkill sleep  # wake up all TTL threads
		# in case files still exist
		for PFILE in $HOME/{.gnupg/secring.gpg,.ssh/id_rsa,.gnubiff,.netrc}; do
			removePrivateFile "$PFILE"
		done

		killall gpg-agent
		# clear out gpg-agent's key list
		rm -rf $HOME/.gnupg/{sshcontrol,private-keys-v1.d/*}

		umountEncFS homedir
		umountEncFS Desktop

		pkill crypt.sh
	;;
	*)
		if mount | grep "encfs .*$1/encrypted" > /dev/null; then
			umountEncFS $1 || interactiveMount $1
		else
			echo "Calling crypt: $1"
			crypt "$@"
		fi
	;;
esac

fi

