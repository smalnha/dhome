#!/bin/sh

# case $HOSTNAME in
# 	$MY_LIPSMACHINE)	
# 		#xtFONTNAME="-fn 6x13" #"7x14"
# 	;;
# esac

if [ "$MY_TERM" = "mrxvt" ] || [ -z "$MY_TERM" ] && which mrxvt > /dev/null ; then
    # export MRXVT="true" # just check COLORTERM instead
	MY_TERM="mrxvt"
elif [ "$MY_TERM" = "aterm" ] || [ -z "$MY_TERM" ] && which aterm > /dev/null ; then
	MY_TERM="aterm -sh 101 -fade 50 -tint white"
elif [ "$MY_TERM" = "xterm" ] || [ -z "$MY_TERM" ] && which xterm > /dev/null ; then
	if locale -a | grep -q "en_US.utf8"; then
		# for unikey
		export LANG="en_US.UTF-8"
		export LC_ALL="en_US.UTF-8"
		which unikey > /dev/null && ! pgrep unikey && export XMODIFIERS="@im=unikey" && unikey
	fi
	#echo "LANG=$LANG XMODIFIERS=$XMODIFIERS"
	MY_TERM=xterm
else
	for T in xfce4-terminal; do
		if which $T > /dev/null ; then
			MY_TERM=$T
			break
		fi
	done

	if [ -z "$MY_TERM" ]; then 
		echo "No terms found !!!"
		sleep 10
		exit 1
	fi
fi

#echo $MY_TERM $xtFONTNAME "$@"
exec $MY_TERM $xtFONTNAME "$@"
