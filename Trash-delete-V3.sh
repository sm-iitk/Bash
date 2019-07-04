 
#!/bin/bash
echo "Usage:Enter the nubmer below to perform specified action."
echo "    1)Check user disk quota usage."
echo "    2)check user Trash size."
echo "    3)Delete user Trash size."
echo "    4)Quit the program."
file=/var/log/quota-del.log
echo -n "Enter username: "
read usern
dir=`grep ^$usern: /etc/passwd|awk -F: '{print $6}'`
if [ -z "$dir" ]; then
        echo "user $usern does not exist"
        exit
fi
check_size() {
        sizein=`/usr/bin/quota -s -u $usern|tail -1| awk  '{print $1}'`
        sizeout=`/usr/bin/quota -s -u $usern|tail -1| awk  '{print $2}'`
        echo "User $usern has used $sizein of quota out of $sizeout."
}

check_tras() {
        if [ -d "$dir/Maildir/.Trash" ]; then
                sizetr=`du -sh $dir/Maildir/.Trash|awk '{print $1}'`
                if [ $? == 0 ]; then
                echo "User $usern has $sizetr in Trash."
                fi
        else
                echo "User $usern has no Trash directory."
        fi
}

del_tras() {
        if [ -d "$dir/Maildir/.Trash" ]; then
        rm -fr  $dir/Maildir/.Trash/*
        rm -fr $dir/Maildir/dovecot.index*
        echo "user Trash contents deleted."
        echo `date` >> $file
        printf "Deleted $usern Trash \n\n" >> $file
        else
                echo "User $usern has no Trash folder."
        fi
}

while [ "$flag" != "yes" ]; do
        echo -n "Enter option as shown above [1-4]: "
        read num
        if [ $num == "4" ]; then
        exit
        fi
case "$num" in
        1)
        check_size
        ;;
        2)
        check_tras ;;
        3)
        del_tras ;;
        4)
        flag=yes
        ;;
        *)
        echo "wrong input"
esac
done
