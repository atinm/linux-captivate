#!/system/bin/sh
# Run user init programs. These are run just before class_default is started,
# so they will have access to the complete environment. All actions are logged
# to /user.log
export PATH=/sbin:/system/bin:/system/xbin
exec >>/system/user.log
exec 2>&1
echo $(date) USER INIT START
for file in /system/etc/init.d/S* ; do
    if ! ls "$file" >/dev/null 2>&1 ; then continue ; fi
    echo "START '$file'"
    "$file"
    echo "EXIT '$file' ($?)"
done
echo $(date) USER INIT DONE
# Allow init to proceed
setprop user_init.init.completed 1
