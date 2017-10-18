#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

#echo "Running .bashrc: $@" >> $MY_LOG

#No reason to do this: [ -f /etc/bashrc ] && . /etc/bashrc

[ -f ~/.bashrc.orig ] && . ~/.bashrc.orig

#Constraints:
# xterm does not have a loginShell resource that executes .bash_profile
#   when .bashrc runs, if $MY_BIN is not set, exec .bash_profile
# cvs does not need any scripts: check if cvs has $PS1
#   cvs does not have $MY_BIN set

#if [ "$SHLVL" = "1" ]; then # if in a login shell

# interactive shell stuff should be set in .bashrc since .bash_profile can be called in a non-interactive shell and never called again
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# if interactive shell, load aliases and functions
# for cvs to login: if .bash_profile never previously run, then skip .bashrc
: ${MY_LOG:=~/init.log}
export MY_LOG
if [ -z "$MY_BINSRC" ] ; then # .bash_profile not sourced
	# if ! cvs then 
	if [ "$TERM" = "dumb" ]; then
		 # used by SCP
		# occurs when 'ssh host command', which does not source .bash_profile by default
		: echo " [ .bashrc: `date` : Dumb term (cvs, scp, or 'ssh host command')" >> ${MY_LOG}
		source ~/.bash_noninter
	elif [ "$PS1" ] ; then  # interactive shell
 		: echo " [ .bashrc: MY_BINSRC not set: sourcing .bash_profile" >> ${MY_LOG}
		source ~/.bash_profile "- 'sourced by ~/.bashrc'"  # will call .bashrc
	else # other non-interactive shell
		echo " [ .bashrc: `date` : When does this occur?? : $0 $*" >> ${MY_LOG}
		source ~/.bash_noninter
		#printenv >> ${MY_LOG}
		# for recording source ip of last ssh connection; to get external address of dynamic IP from home
		# { printenv SSH_CONNECTION | sed 's/ /\n/g'; printenv; echo "# created by .bash_profile"; } > ~/.ssh_connection
	fi
elif [ -z "$PS1" ]; then
	# this case should already be captured by .bash_profile
	# only want the rest if interactive shell
   echo " .bashrc: Ignoring rest of .bashrc.  occurs when sourced (usually indirectly) by .xsession or .xinitr c" >> ${MY_LOG}
	return
else
	# xterm does not source .bash_profile by default, so we'll set OLDPWD here
	#echo OLDPWD=$OLDPWD
	if [ -f ~/.pwd-${HOSTNAME} ] ; then
		OLDPWD="`tail -1 ~/.pwd-${HOSTNAME}`"
		while [ "$OLDPWD" ] && [ ! -d "$OLDPWD" ] ; do
			#echo "OLDPWD=$OLDPWD"
			OLDPWD="${OLDPWD%/*}"
		done
	fi

	# echo "   Normal .bashrc" >> ${MY_LOG}

	#---------------
	# Shell settings must be set with every new shell
	#---------------
	#ulimit -S -c 0				# default: Don't want any coredumps
	ulimit -n 4000
	ulimit -u 10240
	set -o notify
	#set -o nounset 	# indicates an error when using an undefined variable
	#set -o xtrace				# useful for debuging
	#set -P #for symbolic links, goes to the actual directory; can also use 'cd -P' instead

	# Report the status of terminated background jobs immediately
	set -b  

	if [ "$BASH" ]; then
		# too restrictive for letting others see files: umask 0077 # umask -S to view it
		umask 0027
		# Enable options:
		shopt -s checkhash
		shopt -s checkwinsize
		shopt -s sourcepath

		# Disable options:
		shopt -u mailwarn

		#set -o noclobber	# prevent from accidentally overwriting a file when you redirect output; use '>|' to actually overwrite the file
		#set -o ignoreeof	# prevents using Ctrl-d to logout

		shopt -s cdspell
		#not needed: shopt -s cdable_vars

		shopt -s cmdhist
		# shopt -s lithist				    # If cmdhist is enabled, save milti-line commands with newlines.
		shopt -s histappend histreedit histverify
		shopt -s extglob		   # necessary for programmable completion
		shopt -s hostcomplete
	fi

	case "$TERM" in
	   "rxvt" | "aterm" )
			# needed for backspace when ssh in aterm
			#stty erase '^?'
		 ;;
		 "linux" )
			# for non-X console
			loadkeys -q ~/.keymap
		 ;;
	esac

	[ -z "$TTY" ] && TTY=`tty` && TTY=${TTY##*/}

	# for gpg-agent
	# echo '	[ -f "~/bin/crypt.sh" ] && source ~/bin/crypt.sh'
	export GPG_TTY=`tty`


	if [ "$PS1" -a -z "$PROMPT_COMMAND" ]; then	# if interactive shell
	#if [ "$MRXVT_TABTITLE" ]; then
		echo "   Setting prompt_command" >> ${MY_LOG}
		function prompt_command {
			# append to bash history so its available in new windows
			history -a

			# if no dir change then return
			# doesn't work after ssh: [ "$PWD" == "$LASTPWD" ] && return 0;

			#	How many characters of the $PWD should be kept so that $PWD fits in window
			let pwdmaxlen=${COLUMNS}-24
			#	Indicator that there has been directory truncation
			#newPWD=`echo $PWD | sed -e "s/\/home\/$USER/~/"`
			#newPWD=${PWD/#\/home\/$USER/~}
			newPWD=${PWD/\/home\/$USER/\$H}
			if [ ${#newPWD} -gt $pwdmaxlen ]; then
				local pwdoffset=$(( ${#newPWD} - $pwdmaxlen ))
				newPWD="...${newPWD:$pwdoffset}"
			else
				newPWD="${newPWD}"
			fi

			# for xterm title change
			local TITLE="${MY_SSHHOST}${PWD/\/home\/$USER/\$H}"
			[ "$TITLE" ] || TITLE="~"
			case "$TERM" in
				linux)  # text-console
            ;;
            xterm)
			       echo -en "\033]0;$TITLE\007"
				;;
				screen) # for screen utility
					 echo -en "\033]0;$WINDOW:$TITLE\007"
				;;
				*) 
					echo -ne "\033]0;$TITLE\007" # doesn't work for mrxvt
					# for mrxvt:
					# mrxvt always exports the variable "COLORTERM" unless ssh
					if [ "$SSH_CLIENT" ]; then
						[ "$TERM" == "rxvt" ] && echo -en "\e]61;$TITLE\a"
					else
						[ "$MRXVT_TABTITLE" ] && echo -en "\e]61;$TITLE\a"
					fi
					# alternativly select some text in the mrxvt terminal and press Shift_Delete.
					# or select text in the mrxvt terminal and click the middle button of your mouse on the tab that you want to change the title
				;;
			esac
			LASTPWD=$PWD
		}
		if [ "$SHELL" != /bin/sh ] ; then
			export -f prompt_command
		fi

		if type -t prompt_command > /dev/null; then
			# do this after sourcing /etc/bashrc to override defaults
			export PROMPT_COMMAND=prompt_command
		fi
	fi

	if [ "$SHELL" = "/bin/sh" ] ; then
		PS1="$HOSTNAME: \$PWD $TTY $PS1 \$? > "
	elif [ -z "$prompt_is_set" ]; then
		case $TERM in
			*term | rxvt | linux | cygwin )
				if [ "${DISPLAY}" = ":0" ] || [ "${DISPLAY}" = ":0.0" ] || [ -z "$SSH_TTY" ]; then
					export HILIT='\e[0;36m'  # local machine: prompt will be partly cyan
				else
					export HILIT='\e[0;31m'  # remote machine: prompt will be partly red
				fi

				# PS1="${HILIT}[\h]$NORM \W > \[\033]0;\${TERM} [\u@\h] \w\007\]" ;;
				# add a \ in front of $ to make it evaluate at every prompt (it will be dynamically resolved)

				# Define some colors:
				# red='\e[0;31m'
				# grn='\e[0;32m'
				# yel='\e[0;33m'
				# blue='\e[0;34m'
				# magn='\e[0;35m'
				# cyan='\e[0;36m'
				# norm='\e[0m'				    # No Color
				
				#export PS1="< \u@\[${HILIT}\]\h: \[\e[0;32m\]\${newPWD}\n  [${TTY}.${SHLVL}] \t {\j} \[\e[0;31m\]\${?}\[\e[0m\] > " ;;
				if [ "$PROMPT_COMMAND" ]; then
					export PS1="< \u@\[${HILIT}\]\h:\[ \e[0;32m\]\${newPWD}\n  [${SHLVL}] \t {\j} \[\e[0;31m\]\${?}\[\e[0m\] > "
				else
					export PS1="< \u@\[${HILIT}\]\h:\[ \e[0;32m\]\${PWD}\n  [${SHLVL}] \t {\j} \[\e[0;31m\]\${?}\[\e[0m\] > "
				fi
				;;
			screen )
				export PS1="\n\u@\[${HILIT}\]\h:\[ \e[0;32m\]\${PWD}\n [${WINDOW}: ${TTY}.${SHLVL}] \t {\j} \[\e[0;31m\]\${?}\[\e[0m\] > " ;;
			old_linux )
				export PS1="${HILIT}[\h]$norm \W > " ;;
			dumb) # SCP
				  ;;
			*)
				export PS1="term=$TERM [\h] \W > " ;;
		esac
		export PS2="continuing command > "
		export PS3="--- Select one of the above ---> "
		export prompt_is_set=true
	fi

	[ -f ~/.alias ] && . ~/.alias || echo "Note: ~/.alias not found"

	# bash completion delays showing prompt
	if [ "$BASH_COMPLETION" ] ; then
		: echo "  Already using BASH_COMPLETION=$BASH_COMPLETION"
	elif [ "$BASH" ]; then
		# define a function for later use
		bashcomplete(){
			COMP_TAR_INTERNAL_PATHS="true" # effective only if set *before* sourcing bash_complete
			if [ -f /etc/bash_completion ]; then
				# echo "  Using /etc/bash_completion"
				. /etc/bash_completion # this will source ~/.bash_completion
			elif [ -d "$MY_BINSRC" ] ; then
				# if not installed in system, then source my own
				#echo ${BASH_VERSION%.*} #; bmajor=${bash%.*}; bminor=${bash#*.}
				if [ ${BASH_VERSION%.*} '<' 2.04 ]; then
					echo "Bash version $BASH_VERSION ($bashver) is not >= 2.04"
				else
					shopt -s no_empty_cmd_completion  # bash>=2.04 only
					if [ -f $MY_BIN/direct/bash-completionpackage/bash_completion/etc/profile.d/bash_completion.sh ]; then
						BASH_COMPLETION=$MY_BIN/direct/bash-completionpackage/bash_completion/etc/profile.d/bash_completion.sh
						echo "  Using $MY_BIN/direct/bash-completionpackage/bash_completion/etc/profile.d/bash_completion.sh" >> ${MY_LOG}
						. "$MY_BIN/direct/bash-completionpackage/bash_completion/etc/profile.d/bash_completion.sh"  # will source ~/.bash_completion
					elif [ -f ~/.bash_completion ]; then
						BASH_COMPLETION=~/.bash_completion
						echo "  Using only ~/.bash_completion" >> ${MY_LOG}
						. ~/.bash_completion
					fi
				fi
			fi
			. $MY_BINSRC/git-completion.bash
		}
		bashcomplete
	fi

	if [ "$MY_BINSRC" ] ; then 
		# just add it to $MY_BINSRC/autosource instead
		[ -f $MY_BINSRC/autosource ] && . $MY_BINSRC/autosource #|| echo "Note: $MY_BINSRC/autosource not found"
	fi

fi

[ -f ~/.sdkman.src ] && source ~/.sdkman.src

