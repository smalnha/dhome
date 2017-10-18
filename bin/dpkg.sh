#!


# If you delete a single file or directory and want to know what package provided it
dpkg -S /bin/ls

# to know what package to install to get the missing file or application
apt-file search /usr/bin/jove

# to identify packages whose names match a specific substring is dpkg
dpkg -l '*emacs*'

# apt-cache searches package names, and also searches the short and long package descriptions. You could use apt-cache to search for emacs-related packages
apt-cache search emacs



# Verifying the Integrity of Installed Packages
#----------------------------------
# use the debsums command to generate and verify the MD5 checksums of files that have been installed from Debian packages
# change directory to /var/cache/apt/archives (where the APT tools store downloaded packages), and do the following:
# retrieves all of the packages that are installed on your system, but which don\u2019t have an MD5 checksums file. You may see error messages about any packages that you downloaded and installed manually, but there should be very few of those
sudo apt-get --download-only --reinstall install `debsums -l`

# Next, generate the checksums for all installed packages whose debs are present on your system but which don\u2019t already have MD5 checksums, and keep them in files in the working directory:
sudo debsums --generate=nocheck *.deb

#Finally, use debsums in silent mode to only display error information for files and directories that differ from the values in the original packages:
debsums -s

#You can then use the resulting list of missing files and associated packages to determine what to reinstall to recover your system. The debsums script can also be very useful for verifying the integrity of your system if you suspect that you've been hacked.


# --------------------------------------

# or use galternative
update-alternative --config editor



