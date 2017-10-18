#!/bin/sh

# uncomment the following line to be quiet
# VERBOSE=":"

# $VERBOSE echo $0 $1
if [ -z "$1" ] ; then 
	if [ "$WWW_HOME" ] ; then
		URL=${WWW_HOME}
	elif [ -f $HOME/public_html/index.html ] ; then
		URL="file://$HOME/public_html/links/index.html"
	else
		URL="http://www.google.com"
	fi
else
	encodeForBrowserURL(){
		echo $1 | sed 's/%/%25/g ; s/ /%20/g ; s/:/%3A/g; s/\;/%3B/g ; s/\@/%40/g ; s/,/%2C/g ; s/\\\$/%24/g ; s/\+/%2B/g ; s/\#/%23/g ; s/\\`/%60/g ; s/\\\\/%5C/g ; s/\\{/%7B/g ; s/\\}/%7D/g ; s/|/%7C/g ; s/\^/%5E/g ; s/\[/%5B/g ; s/\]/%5D/g ; s/\"//g ; s/</%3C/g ; s/>/%3E/g ; s/\\n/%0A/g ;'
#		s/\?/%3F/g ;  s/~/%7E/g ; s/=/%3D/g; s/\&/%26/g ;
	}

	case "$1" in
		lastdir)
			URL=`encodeForBrowserURL "$(cat "$TEMP/$USER-lastPWD")"`
		;;
		www*)
			URL=`encodeForBrowserURL "$1"`			
		;;
		*:/*)			
			# protocol=${1%%://*} # http
			# wwwaddress=${1#*://} # www.google.com/...
			# URL="$protocol://`encodeForBrowserURL "$wwwaddress"`"
			URL="$1"
		;;
		/* | ~* )
			enc1=`encodeForBrowserURL "$1"`
			URL="file://$enc1"
		;;
		* )
			enc1=`encodeForBrowserURL "$PWD/$1"`
			URL="file://$enc1"
		;;
	esac
fi

ask(){
    echo -n "$1" '[y/N] ' ; read ans
    case "$ans" in
      y*|Y*) return 0 ;;
		n*|N*) return 1 ;;
      *) return ${2:-0} ;;
    esac
}

getConsoleBrowser(){
    for CBROWSER in elinks lynx; do
        if which $CBROWSER > /dev/null 2>&1; then
            echo "$CBROWSER"
            return 0;
        fi
    done
    read -p "Enter a console web browser:" CBROWSER >&2
    echo "$CBROWSER"
    return 1
}

$VERBOSE echo Opening $URL

case "$BROWSER" in
	text)
		 CBROWSER=`getConsoleBrowser`
		 if [ -z "$DISPLAY" ]; then  # use text browser
			  exec $CBROWSER "$URL"
		 else
			  exec xterm -e $CBROWSER $URL
		 fi
	;;
	"" | */browser.sh) ;;
	*)
	#if [[ "${BROWSER:-browser.sh}" != *browser.sh ]] ; then  # if $BROWSER != this file; then use it instead
		 #echo $BROWSER $URL > ~/browser.log
		if [ "$ASK" ] ; then
			if ! ask "Run: $BROWSER $URL ?" ; then 
				exec $BROWSER $URL &
				$VERBOSE echo "  pausing ..."; sleep 5
				exit 0
			else
				$VERBOSE echo "Will try other browsers:"
			fi
		else 
			$VERBOSE echo "Running $BROWSER $URL"
			exec $BROWSER $URL &
		fi
		exit 1
	;;
esac

if [ -z "$DISPLAY" ]; then  # use text browser
    CBROWSER=`getConsoleBrowser`
    exec $CBROWSER "$URL"
else
    # in X
#    if which swiftfox > /dev/null 2>&1 ; then
#        if [ "$1" ]; then
#            if ps -u $USER | grep -q "swiftfox" ; then
#                swiftfox -remote "openURL($URL,new-tab)" &
#            else
#                swiftfox $URL &
#            fi
#        else
#            swiftfox &
#        fi
#    el
	if which firefox > /dev/null 2>&1 ; then
        if [ "$1" ]; then
            if ps -u $USER | grep -q "firefox" ; then
                firefox -remote "openURL($URL,new-tab)" &
            else
                firefox $URL &
            fi
        else
            firefox &
        fi
    elif which opera > /dev/null 2>&1 ; then
			if pgrep opera; then # opera instance found
				if [ "$1" ]; then
					opera -newwindow "$URL" &
				fi
        else
            opera &
        fi
    elif which konqueror > /dev/null 2>&1 ; then
        konqueror "$URL" &
    fi
fi

# for mutt: don't return too quickly that mutt deletes the temporary file to be loaded into browser
sleep 5

