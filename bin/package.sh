#!/bin/bash


#  dpkg -L|--listfiles <package-name> ...   list files `owned' by package(s)
#  dpkg -l|--list [<pattern> ...]           list packages concisely
#  dpkg -S|--search <pattern> ...           find package(s) owning file(s)

apt-ii(){
	echo "${RED}Checking for broken packages:"
	apt-get check
	echo "${RED}Packages on the system:"
	cat /var/lib/dpkg/available
	echo "${RED}Packages status on the system:"
	cat /var/lib/dpkg/status
}


package-list(){
	dpkg -l $*
}
package-list-associated-files(){
	dpkg -L $*
}
package-of-file(){
	dpkg -S $*
}
package-info(){
	dpkg -s $*
}
package-autoclean(){
	apt-get autoclean # ???
}
package-description-search(){
	apt-cache search $*
}
package-name-search(){
	apt-cache search --full --names-only $*
}

list-packages-by-size(){
	dpkg-query -W --showformat='${Installed-Size} ${Package}\n' | sort -n
}

askForTask(){
	select TASK in package-list package-list-associated-files package-info package-description-search package-name-search "exit" ; do
		[ "$TASK" == "exit" ] && return 0;
		# if you want to quit upon bad user input: [ -z "$TASK" ] && echo "Quiting." && return 0;
		#echo $?=$REPLY task=$TASK
		break;
	done
	[ -z "$TASK" ] && echo "Quiting." && return 0;
	echo "You selected $TASK"

	echo "Running \"${TASK}\""
	${TASK} "$@"
}
askForTask "$@"
