#!/bin/bash

echo -n "Type destination path:"
read dstdir

if [ ! -d $dstdir ]
then
	mkdir $dstdir
fi

echo -n "Type pst filename:"
read pstfile

readpst -o $dstdir $pstfile

echo -n "Type username:"
read username

maildir="/home/vmail/$username/Maildir"

for file in `ls $dstdir`
do
        echo -n "Do you want to move $file to $maildir [n]?:"
        read answer1

        if [[ $answer1 == "y" ]]
        then
          echo -n "Type the name of destination folder [$file]:"
          read answer2

          if [[ $answer2 == "" ]]
          then
           foldername="$file" 
          else
           foldername="$answer2"
          fi
        
	perl ./mbox2maildir.pl ./$dstdir/$file $maildir/$foldername/ 504 504 
	

	echo "$file was moved to $maildir/$foldername"
        else
         echo "$file was not moved to $maildir"
        fi
done
rm -Rf $dstdir
