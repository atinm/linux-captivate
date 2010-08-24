#!/system/bin/sh
# Wait for init event in init.rc to complete
# Run user init programs. These are run just before class_default is started,
# so they will have access to the complete environment. All actions are logged
# to /system/user.log
export PATH=/sbin:/system/bin:/system/xbin
exec >>/system/user.log
exec 2>&1
echo $(date) USER INIT START
if cd /system/etc/init.d >/dev/null 2>&1 ; then
    for file in S* ; do
        if ! ls "$file" >/dev/null 2>&1 ; then continue ; fi
        echo "START '$file'"
        "./$file"
        echo "EXIT '$file' ($?)"
    done
fi
echo $(date) USER INIT DONE
# Allow init to proceed
read s </sync_fifo
