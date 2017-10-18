#!/bin/bash

. $MY_BINSRC/helperfuncs.src

if [ "$1" ] ; then
	ARG="$1"
	shift
elif [ "$PWD" == "$HOME/.gnupg" ]; then
	if ! df | grep -q "$MY_EHOMEDIR/encrypted"; then
		CRYPT_ARG=mount
	fi
	cd "$MY_EHOMEDIR"
	echo "crypt.sh $CRYPT_ARG `basename $MY_EHOMEDIR`"
	crypt.sh $CRYPT_ARG `basename $MY_EHOMEDIR`
	exit
elif [ "$PWD" == "$HOME/Desktop" ] || [ "$PWD" == "$HOME/Desktop/_archive" ] || [ "$PWD" == "$MY_EHOMEDIR" ] || [ "$PWD" == "$MY_EPRIVATE" ]; then
	if ! df | grep -q "$PWD/encrypted"; then
		CRYPT_ARG=mount
	fi
	echo "crypt.sh $CRYPT_ARG `basename $PWD`"
	crypt.sh $CRYPT_ARG `basename $PWD`
	exit
elif [ "$PWD" == "$HOME/NOBACKUP" ] && [ -e "$PWD/hagrid" ]; then
	host=hagrid
	mountpoint=$PWD/$host
	if [ -e "$PWD/.bashrc" ]; then
		fusermount -u "$mountpoint"
	else 
		dir=$H
		sshfs "$host:$dir" "$mountpoint" -o idmap=user -o follow_symlinks
	fi
elif which getXselection > /dev/null 2>&1; then
	# better way; compile getXselection.c
	ARG=`getXselection`
	ARG=${ARG% }
	[ "$ARG" ] && echo "open.sh: Using selection as argument: $ARG"
else
	# old way;  does not always work for Netscape, (http://www.hpc.uh.edu/fvwm/archive/9903/msg00323.html)
	echo "open.sh: You should install getXselection: cd $HOME/bin/install && make getXselection"
	ARG=`xprop -root CUT_BUFFER0`
	ARG=${ARG#*=}
	ARG=${ARG% }
	echo "      using CUT_BUFFER0 (probably from term): $ARG"
fi

# resolve variables
ARG=`eval echo \"$ARG\"`
#echo "ARG=$ARG"

if which thunar &> /dev/null; then
	FILE_MGR="thunar"
elif which nemo &> /dev/null; then
	FILE_MGR="nemo"
else
	FILE_MGR="nautilus"
fi

if [ -d "$ARG" ] ; then
   ( cd "$ARG"; $FILE_MGR "$ARG"; )
elif [ ! -f "$ARG" ] ; then
	# echo "Checking prefix"
	case "$ARG" in 
		mailto:* | *@*)
			# remove 'mailto:'
			#ARG=`echo $ARG | sed 's/^mailto://'`
			ARG=${ARG#mailto:}
			# remove everything after '?'
			#EMAIL_ADDY=`echo $ARG | sed 's/\(.*\)@\(.*\)?.*/\1@\2/'`
			EMAIL_ADDY=${ARG%\?*}
		
			[ "$*" ] && EMAILER=pine

			case "$EMAILER" in
				pine)
					exec mail.sh "$EMAIL_ADDY" "$@"
					break
				;;
				* | gmail) 
					EMAIL_PARAMS=${ARG#*\?}
					if [ "$EMAIL_PARAMS" = "$ARG" ] ; then
						unset EMAIL_PARAMS
					else
						EMAIL_PARAMS=`echo "$EMAIL_PARAMS" | sed 's/subject/su/'`
					fi

					encodeForGMailURL(){
						echo $1 | sed 's/ /%20/g ; s/:/%3A/g; s/~/%7E/g ; s/\;/%3B/g ; s/\&/%26/g ; s/\?/%3F/g ; s/\@/%40/g ; s/,/%2C/g ; s/\\\$/%24/g ; s/\+/%2B/g ; s/\//%2F/g ; s/\#/%23/g ; s/\\\`/%60/g ; s/\\\\/%5C/g ; s/\{/%7B/g ; s/\}/%7D/g ; s/|/%7C/g ; s/\^/%5E/g ; s/\[/%5B/g ; s/\]/%5D/g ; s/\"//g ; s/</%3C/g ; s/>/%3E/g ; s/\\n/%0A/g ; s/=/%3D/g; s/%/%25/g;'
					}
					# NOTE: You have to double escape spaces in everything BETWEEN the "dest=" and "&". So instead of "+" or "%20", you need to use "%2520". You also have to double escape the pound symbol. So instead of this "#" it is this "%2523".
					# echo EMAIL_ADDY=$EMAIL_ADDY

					# separate each parameter separated by & 
					while [ "$EMAIL_PARAMS" ] ; do
						# echo EMAIL_PARAMS=$EMAIL_PARAMS
						# read up to next & or EOL
						EMAIL_PARAM=${EMAIL_PARAMS%%\&*}
						newEMAIL_PARAMS=${EMAIL_PARAMS#*\&}
						if [ "$newEMAIL_PARAMS" = "$EMAIL_PARAMS" ]; then
							unset EMAIL_PARAMS
						else
							EMAIL_PARAMS=$newEMAIL_PARAMS
						fi
						# separate variable and value using '='
						GMAIL_VAR=${EMAIL_PARAM%%=*}
						EMAIL_PARAM=${EMAIL_PARAM#*=}
						GMAIL_PARAMS="$GMAIL_PARAMS%26$GMAIL_VAR%3D`encodeForGMailURL "$EMAIL_PARAM"`"
					done

					#GMAIL_SUBJ="%26su%3D`encodeForGMailURL "Your Subject Line"`"
					#EMAIL_PARAMS=$GMAIL_SUBJ
					#GMAIL_BODY="%26body%3D`encodeForGMailURL "Blah blah"`"
					exec browser.sh "https://gmail.google.com/?dest=https%3A%2F%2Fgmail%2Egoogle%2Ecom%2Fgmail%3Fview%3Dcm%26fs%3D1%26tf%3D1%26to%3D$EMAIL_ADDY$GMAIL_PARAMS"
				;;
			esac
		;;
		*:/*)
			echo "open.sh: Calling browser.sh $@"
			exec browser.sh "$ARG" "$@"
		;;
		*)
			if [ -r "$TEMP/$USER-lastPWD" ]; then
				TESTFILE="`cat $TEMP/$USER-lastPWD`/$ARG"
			fi
   		if [ -f "$TESTFILE" ]; then
   			AFILE=$TESTFILE
   			echo "open.sh: Found file=$AFILE"
			else
	   		echo "File $ARG not found or unknown protocol."
				$FILE_MGR
   			exit
			fi
		;;
	esac
else
	AFILE="$ARG"
fi

# echo "AFILE=$AFILE"

showOptions(){
			let i=0
			while read MIMETYPE MAILCAPCOMMAND; do
				#echo "showOptions: $MAILCAPCOMMAND"
				MAILCAPENTRY=`echo $MAILCAPCOMMAND | sed "s/ %s//"`
				#echo "which ${MAILCAPENTRY%% *}"
				if which "${MAILCAPENTRY%% *}" &> /dev/null; then
					OPTIONS[$i]="$MAILCAPENTRY"
					#echo "MAILCAPENTRY=$MAILCAPENTRY"
					let i++
				else
					echo "Cannot find command: $MAILCAPENTRY"
				fi
			done <<EOF
$1
EOF
			#echo "OPTIONS=$OPTIONS"
			if [ "${#OPTIONS[@]}" -gt 1 ]; then
				select CHOICE in "${OPTIONS[@]}"; do break; done
				MAILCAPCOMMAND="$CHOICE"
			else
				MAILCAPCOMMAND="${OPTIONS[0]}"
			fi
			echo "found in ~/.mailcap: $MAILCAPCOMMAND"
}

if [ -f "$AFILE" ] ; then
	EXTENSION="$AFILE"
	while ` echo "$EXTENSION" | grep -q "\." - `; do
		EXTENSION=$(echo "${EXTENSION#*.}" | tr A-Z a-z)
		#	lastEXTENSION=`echo "$AFILE" | sed 's/\(.*\)\.\([^\.]*\)/\2/g' | tr [A-Z] [a-z]`
		#echo $lastEXTENSION
		MIMEdescr=`grep --max-count=1 "[[:space:]]\+${EXTENSION}" ~/.mime.types` # | cut -f 1 -d " "`
		MIMEdescr=${MIMEdescr%% *}
		echo MIMEdescr=$MIMEdescr
		# before the /
		MIMEtype=${MIMEdescr%%/*}
		# after the /
		MIMEsubtype=${MIMEdescr##*/}
		#echo "MIMEtype=$MIMEtype; MIMEsubtype=$MIMEsubtype"
		if [ "$MIMEdescr" ] ; then 
			# echo "mime type=$MIMEtype subtype=$MIMEsubtype"
			# if script doesn't exist in MIME-types, then find and execute command in .mailcap
			[ -d "$HOME/Choices/MIME-types" ] && for SCRIPT in $MIMEtype_$MIMEsubtype $MIMEtype ; do
				SCRIPT=$HOME/Choices/MIME-types/$SCRIPT
				# echo -n "$SCRIPT? "
				if [ -x $SCRIPT ] ; then
					echo "Executing $SCRIPT $AFILE $@ "
					exec $SCRIPT "$AFILE" "$@"
				fi
				SCRIPTMSG="or create script $SCRIPT"
			done

			#echo -e "mimetype=$MIMEtype"
			COMMANDS=`grep -w "${MIMEdescr};" "$HOME/.mailcap" | grep -v "^[[:space:]]*#"`
			[ -z "$COMMANDS" ] && COMMANDS=`grep -w "${MIMEtype}/\*\;" "$HOME/.mailcap" | grep -v "^[[:space:]]*#"`
			echo "found line: $COMMANDS"
			if [ "$COMMANDS" ] ; then
				showOptions "$COMMANDS"
				echo exec $MAILCAPCOMMAND "$AFILE" "$@"
				exec $MAILCAPCOMMAND "$AFILE" "$@"
			else
				echo "Add an entry '$MIMEdescr' or '$MIMEtype/*' in ~/.mailcap $SCRIPTMSG"
			fi

		elif [ "$EXTENSION" = "" ] ; then
			exec xterm.sh -e $VISUAL "$AFILE" "$@"
		fi
	done

	echo "Unknown mime type: please add $lastEXTENSION to ~/.mime.types file"
	if [ "$DISPLAY" ]; then
		ask "Open with $VISUAL in xterm? "
		[ $? -eq 0 ] && [ -e "$AFILE" ] && exec xterm.sh -e $VISUAL "$AFILE" "$@"
	elif [ "$PS1$PS2PS3$PS4" ]; then
		ask "Open with $EDITOR? "
		[ $? -eq 0 ] && [ -e "$AFILE" ] && $EDITOR "$AFILE" "$@"
	fi
fi
