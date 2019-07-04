#!/bin/bash

SCRIPT_DIR=/root/scr
INDX_DIR=/users06/dovecot/index
INDX_LOG=$SCRIPT_DIR/indx-copy
DATA_DIR=$SCRIPT_DIR/data
S_TIME=`date`
users=`awk -F: '$3 >=1000 && $3<=1100 {print $1}' /etc/passwd`
highuid=`awk -F: '$3 >=20000 && $3 <=100000{print $3}' /etc/passwd|sort -nr | head -n1`
for i in $users
do
        f_letter=`echo $i | head -c 1`
        udir=`awk -v var="$i" -F: '$1==var {print $6}' /etc/passwd`
        uidN=`awk -v var="$i" -F: '$1==var {print $3}' /etc/passwd`
        gidN=`awk -v var="$i" -F: '$1==var {print $4}' /etc/passwd`
        printf "\n username is: $i, Uid is :$uidN, Gid is :$gidN \n"

        find $udir/Maildir/ | grep index > "$DATA_DIR/$i-indx"
        find $udir/Maildir/ | grep uidlist > "$DATA_DIR/$i-cntl"
        find $udir/Maildir/ | grep keywords >> "$DATA_DIR/$i-cntl"
        awk -F/ '{print $(NF-1)}' "$DATA_DIR/$i-indx"| grep -v "Maildir"|uniq -d > "$DATA_DIR/$i-dirs"
        IFS=$'\n'
        for j in `cat "$DATA_DIR/$i-dirs"`
        do
                if [ ! -d $INDX_DIR/$f_letter/$i/$j ]; then
                        mkdir -p $INDX_DIR/$f_letter/$i/$j
                fi

                rsync -avpzh $udir/Maildir/$j/dovecot.* $INDX_DIR/$f_letter/$i/$j/
                rsync -apvzh $udir/Maildir/$j/dovecot-* $INDX_DIR/$f_letter/$i/$j/
                rsync -pavzh $udir/Maildir/$j/maildirfolder $INDX_DIR/$f_letter/$i/$j/
        done
        rsync -avzph $udir/Maildir/dovecot.* $INDX_DIR/$f_letter/$i/
        rsync -avpzh $udir/Maildir/dovecot-* $INDX_DIR/$f_letter/$i/
        rsync -avpzh $udir/Maildir/subscriptions $INDX_DIR/$f_letter/$i/
        chown -R $i:$gidN $INDX_DIR/$f_letter/$i/
done
F_TIME=`date`
echo "Started at $S_TIME"
echo "Finished at $F_TIME 
