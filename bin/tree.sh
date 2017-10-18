#!/bin/bash
#         @(#) tree      1.1  30/11/95       by Jordi Sanfeliu
#                                         email: mikaku@arrakis.es
#
#         Initial version:  1.0  30/11/95
#         Next version   :  1.1  24/02/97   Now, with symbolic links
#         Patch by       :  Ian Kjos, to support unsearchable dirs
#                           email: beth13@mail.utexas.edu
#
#         Tree is a tool for view the directory tree (obvious :-) )
#
search () {
   for dir in * #`echo *`
   do
      if [ -d "$dir" ] ; then
         local zz=0
         while [ $zz != $deep ]
         do
            echo -n "|   "
            zz=`expr $zz + 1`
         done
         if [ -L "$dir" ] ; then # if dir is a link
            echo "+---$dir" `ls -l "$dir" | sed 's/^.*'"$dir"' //'`
         else
            echo "+---$dir"
            if cd "$dir" >/dev/null; then
               deep=`expr $deep + 1`
               search    # with recursivity ;-)
               numdirs=`expr $numdirs + 1`
            fi
         fi
      fi
   done
   cd ..
   if [ $deep ] ; then
      swfi=1
   fi
   deep=`expr $deep - 1`
}

# - Main -
if [ $# = 0 ] ; then
   cd `pwd`
else
   cd $1
fi
echo "Initial directory = `pwd`"
swfi=0
deep=0
numdirs=0
zz=0

while [ "$swfi" != 1 ]; do
   search
done
echo "Total directories = $numdirs"



