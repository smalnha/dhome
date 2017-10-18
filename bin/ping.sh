#!/bin/bash

NETPREFIX=`ifconfig | grep -ow "Bcast:.*"`
NETPREFIX=${NETPREFIX% *}
NETPREFIX=${NETPREFIX##*:}
NETPREFIX=${NETPREFIX%.*}

iplookup(){ # looks in /etc/hosts for given hostname
	local IPADDR=`grep -w $1 /etc/hosts`
	if [ "$IPADDR" ] ; then
		IPADDR=${IPADDR%% *}
		echo ${IPADDR# *}
	else 
		IPADDR=`host $1`
		if echo "$IPADDR" | grep -q "connection timed out"; then
			# try samba
			SMB_REPLY=`nmblookup $1`
			echo "$SMB_REPLY" >&2
			# what do we do with SMB_REPLY
			echo "UNKNOWN_IP"
			return 1
		fi
		IPADDR=${IPADDR%% *}
		echo ${IPADDR##* }
	fi
}

namelookup(){ # looks in /etc/hosts for given hostname
	local IPADDR=`grep -w $1 /etc/hosts`
	if [ "$IPADDR" ] ; then
		echo ${IPADDR}
	else
		echo "Could not find name for $1 $IPADDR"
	fi
}

pingit(){
	echo "ping $1"
	if ping -c 1 "$1" > /dev/null; then
		namelookup "$1"
	fi
}

pingLAN(){
	echo "Using NETPREFIX=$NETPREFIX"
	echo "------------------------------"
	#echo GATEWAY=`iplookup mygateway`
	#pingit `iplookup mygateway` &
	{
	for (( i=1; i<255; i++ )); do
		pingit $NETPREFIX.$i &
	done;
	} # | col
	wait
}

if [ "$1" == "-l" ] ; then
	iplookup $2 
	exit $?
fi

pingLAN


