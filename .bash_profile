#!/bin/bash

: ${HOSTNAME:=`hostname`}
export HOSTNAME

echo "{  .bash_profile: $HOSTNAME : `date +%D-%T` : `tty`: $SHLVL: $0 $*" >> ${MY_LOG:=~/init.log}
export MY_LOG

if [ "$TIMEME" ] ; then
	START_NANO=`date +%N`
	START_SEC=`date +%s`
fi

# only need to do the following once per login 
if [ -z "$MY_TRASH" ] || [ "$1" == "--force" ] ; then

	# check .my_links
	if [ -d "$HOME/.my_links" ] && ! [ -d "$HOME/.my_links/tempDir" ] ; then
		pushd ~/.my_links
		source autosource
		popd
	fi

	export MY_NOBACKUP=$HOME/NOBACKUP
	[ -d "$MY_NOBACKUP" ] || mkdir "$MY_NOBACKUP"

	# used by many apps (e.g. gs, ps2pdf, gksudo)
	# must use actual resolved directory since root will not have permissions to a mounted home directory or its subdirs
	[ -e "$HOME/.my_links/tempDir" ] && export TEMP=`readlink -f "$HOME/.my_links/tempDir"`
	[ "$TEMP" ] || export TEMP="$MY_NOBACKUP/tmp"
	# used by mutt
	export TMPDIR=$TEMP
	export TMP=$TEMP
	[ -d "$TMP" ] || mkdir -pv "$TMP"

	# export JAVA_HOME is set by bash_noninter
	source "$HOME/.bash_noninter" "- 'sourced by .bash_profile'"

	# echo "  Exporting env variables in .bash_profile called from $0."
	[ $SHLVL -ne 1 ] && echo "   SHLVL=$SHLVL: exporting env variables !!! " >> $MY_LOG

	if [ "$BASH" ]; then
		unset MAILCHECK         # don't warn me of incoming mail
		export HISTCONTROL=ignoredups # don't put duplicate lines in the history. See bash(1)

		# for bash_completion package
		export COMP_CONFIGURE_HINTS="true"

		# some unique return value between 2 and 255 for my completion setup
		# --completionCommand$COMPLETION_OPT will be used as an argument
		# see $MYBIN_SRC/autosource
		export COMPLETION_OPT="234"

		#export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
		export HISTIGNORE="&:ls:ll:l:..:...:bg:fg:h:xine:mplayer"
		# bash history file size
		export HISTFILESIZE=1000
		#export HOSTFILE=$HOME/.hosts	 # Put a list of remote hosts in ~/.hosts (for bash completion?)

	fi

	# locale settings
	if [ "$messesUpMan" ] && locale -a | grep -q "en_US.utf8"; then
		# this only seems to work in xterm, not aterm or mrxvt
		# for unikey
		export LANG="en_US.UTF-8"
		export LC_ALL="en_US.UTF-8"
	else
		# so that evince uses letter paper
		export LC_PAPER="en_US.UTF-8"
		# fallback value in the absence of LC_ALL and other LC_*
		export LANG="C" #or "en_US"
		export COUNTRY="en"  # use en instead of us for aspell to work
		export LANGUAGE="en" # "en_US" # or "en_US.UTF-8" or "en_US.ISO-8859-1"
		#export XMODIFIERS=""
		#export KEYTABLE="us"
		#export KDEKEYBOARD="us"
		#export CHARSET="iso8859-1"
	fi

	#[ -f $MY_LOG ] && rm -f $MY_LOG
	#if ( [ -f $MY_LOG ] && [ `ls -s $MY_LOG | cut -d'.' -f1` -gt 20 ] ) ; then
	#	mv $MY_LOG $MY_LOG.bak
	#	tail -c10000 $MY_LOG.bak > $MY_LOG
	#fi

	# executed when sh is called
	#export ENV=~/.bash_profile

	# Specify that Ctrl-D must be pressed twice to exit:
	#export IGNOREEOF=1

	export VISUAL=vim
	export EDITOR=vim

	# Caution: do not add line number (or similar) as this affects scripts that use grep
	#export GREP_OPTIONS='--color'

	# gs options
	#export GS_OPTIONS=-dSAFER -dNOPAUSE -dBATCH -dCompatibilityLevel=1.2 -sOutputFile=gs.pdf 
	#export GS_DEVICE=pdfwrite

	#export MANPATH=:$HOME/usr/man

	if [ "$MY_BIN" ]; then
		export BROWSER=$MY_BIN/browser.sh
		export MY_BINSRC="$MY_BIN/src" #dir of files to be sourced automatically if executable
	fi


	# set variable identifying the chroot you work in (can be used in the prompt below)
	if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
		debian_chroot=$(cat /etc/debian_chroot)
	fi

	[ -f "$HOME"/.ssh/ssh-agent.src ] && . "$HOME"/.ssh/ssh-agent.src >> $MY_LOG

	if [ "$SSH_CONNECTION" ] ; then
		# for xterm title bar
		MY_SSHHOST="${HOSTNAME%%.*}:"
		#echo "  `env` SSH_CLIENT=$SSH_CLIENT" >> ${MY_LOG}
	fi
	export H=$HOME

	export PAGER=less
	export LESS='--ignore-case --line-numbers --hilite-unread --window=-4 --LONG-PROMPT --no-init --quit-if-one-screen --RAW-CONTROL-CHARS -P%t?f%f :stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'
	# use less to view binary files, e.g. tar, jar, zip, doc (with catdoc)
	 [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
	#export LESSCHARSET='latin1'

	[ -f "$HOME"/.bash_profile.$HOSTNAME ] && . "$HOME"/.bash_profile.$HOSTNAME >> $MY_LOG

else 
	# This now only happens rarely (i.e. at login)
	echo "   Skipping unnecessry parts of .bash_profile called from $0." >> ${MY_LOG}
fi

# ------ the following section is always executed --------
# xterm does not source .bash_profile by default
# it's easy to set this once at SHLVL=1 anyway
# why not set it in if condition above?  why continue to check LS_COLORS?
if [ ! "$LS_COLORS" ] ; then
	if [ ! -f "$HOME/.dir_colors.src" ] && which dircolors &> /dev/null && [ -f "$HOME/.dir_colors" ] ; then
		dircolors -b $HOME/.dir_colors > $HOME/.dir_colors.src
	fi
	[ -f "$HOME/.dir_colors.src" ] && . $HOME/.dir_colors.src
fi

# interactive stuff should be in .bashrc because shell level 0 may be non-interactive and .bash_profile is only called then
if [ "$PS1" ]; then	# if interactive shell
	echo "   .bash_profile: sourcing .bashrc" >> ${MY_LOG}
	[ -f ~/.bashrc ] && . ~/.bashrc >> ${MY_LOG}
else 
   echo "   not interactive: ignoring .bashrc" >> ${MY_LOG}
fi

# ------ done always executed --------

if [ -z "$MY_TRASH" ] ; then

	# must edit PATHs after . ~/.bashrc to be effective.  WHY, it gets reset?
#	addToMyPath -f -var CDPATH .
#	addToMyPath -var CDPATH $HOME $HOME/Desktop
#	addToMyPath $H/NOBACKUP/dev/omnetpp-4.2.2/bin
	
	[ -e "$HOME/.my_links" ] && export MY_TRASH=$HOME/.my_links/trashDir
	[ -e "$MY_TRASH" ] || export MY_TRASH="$TMP"
	# already done above [ -d "$HOME/.my_links/tempDir" ] || { pushd $HOME/.my_links; source autosource; popd; }  #mkdir -p "$MY_TRASH"

fi

if [ "$TIMEME" ] ; then
	STOP_NANO=`date +%N`
	STOP_SEC=`date +%s`
	let DIFF_NANO=$STOP_NANO-$START_NANO
	let DIFF_SEC=$STOP_SEC-$START_SEC
	echo "   `date +%D-%T` : $DIFF_SEC.$DIFF_NANO " >> ${MY_LOG}
fi


[ -e ~/.my_gpg ] && source ~/.my_gpg

# confuses scp
# [ "$PS1" ] && [ -d $HOME/.calendar ] && sh $MY_BINSRC/calendar.src checkToday -f


# ivim: fdm=indent
