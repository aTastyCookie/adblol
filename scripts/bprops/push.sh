#!/bin/bash
cat > build.prop.sh << EOF
new_conf=`cat ./build.prop_n`
old_conf=`cat ./build.prop`
str="ro.product.brand= ro.product.name= ro.product.device= ro.build.version.incremental= ro.build.tags= ro.build.fingerprint="
for sss in $str; do
	val_new=`echo "$new_conf" | grep "$sss"`
	val_old=`echo "$old_conf" | grep "$sss"`
	conf=`echo "$old_conf" | sed "s/$val_old/$val_new/"`
	old_conf="$conf"
done
echo "$conf" >> ./build.prop_z
EOF

adb devices | while read line
do
	if [ ! "$line" = "" ] && [ `echo $line | awk '{print $2}'` = "device" ]
	then
		device=`echo $line | awk '{print $1}'`

		a=(*); BUILDPROP=${a[$((RANDOM % ${#a[@]}))]};

		echo "adb -s $device is started with $BUILDPROP"

		adb -s $device shell "su -c 'mount -o remount,rw /'"

		adb -s $device push $BUILDPROP /build.prop_n
		adb -s $device push ./build.prop.sh /build.prop.sh
		#pull
		adb -s $device shell "su -c 'chmod +x ./build.prop.sh'"
		adb -s $device shell "su -c './build.prop.sh'"
		adb -s $device shell "su -c '[[ -f /build.prop_z ]] && echo success || echo error'"
		#push _z

		adb -s $device shell "su -c 'cp /build.prop_z /system/build.prop'"


		adb -s $device shell "su -c 'chmod 0744 /system/build.prop'"
		adb -s $device shell "su -c 'adb shell reboot'"
		#adb -s $device shell "su -c 'rm /build.prop'"

		echo "adb -s $device is canceled"

	fi
done