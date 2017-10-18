#!/bin/bash

lsb_release -a

 # Determine the Linux distribution and version that is being run.
   #
   # Check for GNU/Linux distributions
   if [ -f /etc/SuSE-release ]; then
     DISTRIBUTION="suse"
   elif [ -f /etc/UnitedLinux-release ]; then
     DISTRIBUTION="united"
  elif [ -f /etc/debian_version ]; then
    DISTRIBUTION="debian"
  elif [ -f /etc/redhat-release ]; then
    a=`grep -i 'red.*hat.*enterprise.*linux' /etc/redhat-release`
    if test $? = 0; then
      DISTRIBUTION=rhel
    else
      a=`grep -i 'red.*hat.*linux' /etc/redhat-release`
      if test $? = 0; then
        DISTRIBUTION=rh
      else
        a=`grep -i 'cern.*e.*linux' /etc/redhat-release`
        if test $? = 0; then
          DISTRIBUTION=cel
        else
          a=`grep -i 'scientific linux cern' /etc/redhat-release`
          if test $? = 0; then
            DISTRIBUTION=slc
          else
            DISTRIBUTION="unknown"
          fi
        fi
      fi
    fi
  else
    DISTRIBUTION="unknown"
  fi

  ###    VERSION=`rpm -q redhat-release | sed -e 's#redhat[-]release[-]##'`

  case ${DISTRIBUTION} in
  rh|cel|rhel)
      VERSION=`cat /etc/redhat-release | sed -e 's#[^0-9]##g' -e 's#7[0-2]#73#'`
      ;;
  slc)
      VERSION=`cat /etc/redhat-release | sed -e 's#[^0-9]##g' | cut -c1`
      ;;
  debian)
      VERSION=`cat /etc/debian_version`
      if [ ${VERSION} = "testing/unstable" ]; then
          # The debian testing/unstable version must be translated into
          # a numeric version number, but no number makes sense so just
          # remove the version all together.
          VERSION=""
      fi
      ;;
  suse)
      VERSION=`cat /etc/SuSE-release | grep 'VERSION' | sed  -e 's#[^0-9]##g'`
      ;;
  united)
      VERSION=`cat /etc/UnitedLinux-release`
      ;;
  *)
      VERSION='00'
      ;;
  esac;

  echo ${DISTRIBUTION}${VERSION}

cat /etc/issue

cat /etc/*release

uname -a
