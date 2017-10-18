#!/bin/bash
#createCompletionFunction samba "mount umount list listAll"

#	local CMD FUNCTIONNAME KEYWORD_LIST ALIASES
		# to register this script with bash's command completion
		#echo ": $COMPLETION_OPT;"
	while [ "$1" ] ; do
		ARG="$1"
		# echo "case $ARG"
		case "$ARG" in
			-a | --alias) shift
				ALIASES="$1"
				shift
				;;
			-o | --query_options) shift
				COMPLETION_OPTS="$1"
				shift
				;;
			*) 
				if [ -z "$CMD" ] ; then
					CMD="$1"
				else
					for KEYWORD in $1; do
						if [ "$KEYWORD_LIST" ]; then
							KEYWORD_LIST="$KEYWORD_LIST | $KEYWORD"
						else
							KEYWORD_LIST=$KEYWORD
						fi
					done
				fi
				shift
				;;
		esac
	done
	[ "$ALIASES" ] || ALIASES="${CMD##*/}" 
    LONG_OPTS=`$CMD --help | sed  -e '/--/!d' -e 's/.*--\([^[:space:].,]*\).*/--\1/' | tr '\n' ' '`
	
	# replace '/' and '.' with '_'
	if [ "$shorten" ]; then
		FUNCTIONNAME=${CMD##*\/}
	else
		FUNCTIONNAME=${CMD//\//_}; 
	fi
	FUNCTIONNAME=_${FUNCTIONNAME//./_}
	echo "echo -e \"\nRegistering function $FUNCTIONNAME for command completion of $CMD\";"
	echo "function $FUNCTIONNAME () { 
		# which \$1 &> /dev/null || { echo -e "\\n \$1 not found"; return 1; }
		# $1=command $2=currentArgBeingCompleted $3=lastArgument
		# echo "args: 1=\$1 2=\$2 3=\$3 "
		# all words on command line: echo "\$COMP_CWORD COMP_WORDS=\${COMP_WORDS[*]}"

		# process $3 first, then $2"

if [ $DEBUG ] ; then
	echo "echo $FUNCTIONNAME me; } ; type $FUNCTIONNAME; sleep 0;"
	echo "complete | grep apable"
	echo "echo "reg.. ${COMPREPLY[*]}" ; complete -F $FUNCTIONNAME $ALIASES;"
	echo "complete | grep apable"
	exit 0
fi

	if [ "$KEYWORD_LIST" ]; then 
		echo "case \"\$3\" in "
		#local COMPGEN_COMMAND 
		for OPT in ${KEYWORD_LIST//|}; do
			COMPGEN_COMMAND=$( $CMD --completion_$OPT ) 
			if [ $? -eq $COMPLETION_OPT ]; then
				echo "$OPT)
					COMPREPLY=(\$(eval \"$COMPGEN_COMMAND\"))
				;;"
			fi
		done
		[ "${NotReallyNeeded}" ] &&	echo "
				$KEYWORD_LIST)
					#'local' this must be on separate line for \$? to work
					local COMPGEN_COMMAND 
					COMPGEN_COMMAND=\$( \$1 --completion_\$3 ) 
					[ \$? -eq $COMPLETION_OPT ] && COMPREPLY=(\$(eval \$COMPGEN_COMMAND))
				;;"
		echo "esac"
	fi
	echo "
		[ \"\$COMPREPLY\" ] && return
		case \"\$2\" in 
			\"\") 
				COMPREPLY=(\$(compgen -W \"$LONG_OPTS ${KEYWORD_LIST//|}\" -- \$2))
			;;
			-*)
				#_longopts_func \"\$@\"
				COMPREPLY=(\$(compgen -W \"$LONG_OPTS\" -- \$2))
			;;"
	[ "$KEYWORD_LIST" ] && echo "
			*)
				COMPREPLY=(\$(compgen -W \"${KEYWORD_LIST//|}\" -- \$2))
				;;"
	echo "
			esac
		} ; "
	echo "complete -F $FUNCTIONNAME $ALIASES;"

exit 0

createCompletionFunction1(){
	while [ "$1" ] ; do
		ARG="$1"
		# echo "case $ARG"
		case "$ARG" in
			-a | --alias) shift
				ALIASES="$1"
				shift
				;;
			-o | --query_options) shift
				COMPLETION_OPTS="$1"
				shift
				;;
			*) CMD="$1"
				shift
				;;
		esac
	done
	local FUNCTIONNAME=${CMD//\//_}
	local FUNCTIONNAME=${FUNCTIONNAME//./_}
	[ "$COMPLETION_OPTS" ] || COMPLETION_OPTS=`$CMD --completion_options`
	[ "$ALIASES" ] || ALIASES="${CMD##*/}" 
	eval "function _$FUNCTIONNAME () { 
		# $1=command $2=currentArgBeingCompleted $3=lastArgument
		# echo " \$PWD 2=\$2 3=\$3 "
		case \"\$3\" in 
			mount) 
				COMPREPLY=( \$( compgen -A directory -- \$2 ) )
			;; 
			*)
				COMPREPLY=( \$( compgen -W \"${COMPLETION_OPTS}\" -- \$2 ) )
			;;
		esac
	}"
	eval "complete -F _$FUNCTIONNAME $ALIASES"
}

