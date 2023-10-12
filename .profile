# ~/.profile: executed by the command interpreter for login shells, including window managers.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
for D in "$HOME/bin" "$HOME/bin/online"; do
	if [ -d "$D" ] ; then
		 PATH="$D:$PATH"
	fi
done

. "$HOME/.cargo/env"

export PATH="$HOME/.poetry/bin:$PATH"
