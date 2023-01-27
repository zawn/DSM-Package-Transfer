#!/bin/bash

operation=$1
package=$2
new_volume=$3

case $operation in
	list)
		package_list=$(ls /var/packages/ |tr -s " ")
		echo " Folder name -- Package name
-----------------------------"
		for a in $package_list;
		do
		if [ -e /var/packages/$a/INFO ]
		then
			package_name=$(cat /var/packages/$a/INFO | grep displayname_chs\= | grep -o '".*"' |sed 's/"//g')
			if [ -z "$package_name" ]
			then
				package_name=$(cat /var/packages/$a/INFO | grep displayname\= | grep -o '".*"' |sed 's/"//g')
			fi
			echo $a -- $package_name
		else
			echo $a -- /var/packages/$a/INFO does not exist.The package may be uninstalled.
		fi
		done
		;;
	transfer)
		dir=("conf" "home" "store" "temp" "data")
		link=("etc" "home" "target" "tmp" "var")

		for ((i=0;i<=4;i++))
		do
		if [ -e /var/packages/$package/${link[$i]} ]
		then
			lk=$(ls -l /var/packages/$package/${link[$i]})
			original_lk=${lk##* }
			original_volume=${original_lk:7:1}
			if [ $new_volume -ne $original_volume ]
			then
				if [ ! -d /volume$new_volume/@app${dir[$i]} ]
				then
					mkdir /volume$new_volume/@app${dir[$i]}
					if [ $? -eq 0 ];then echo "Creat directory /volume$new_volume/@app${dir[$i]}...Done.";else echo "Creat directory /volume$new_volume/@app${dir[$i]}...Failed.";exit;fi
				fi
				new_lk=$original_lk
				new_lk=${original_lk/$original_volume/$new_volume}
				cp -a $original_lk $new_lk
				if [ $? -eq 0 ];then echo "Copy $original_lk to $new_lk...Done.";else echo "Copy $original_lk to $new_lk...Failed.";exit;fi
				ln -snf $new_lk /var/packages/$package/${link[$i]}
				if [ $? -eq 0 ];then echo "Link $new_lk to /var/packages/$package/${link[$i]}...Done.";else echo "Link $new_lk to /var/packages/$package/${link[$i]}...Failed.";exit;fi
			fi
		else
			echo /var/packages/$package/${link[$i]} does not exist.
			exit
		fi
		done
		;;
	help|*)
		echo "Usage: $0 list|transfer [packagefolder_name] [targetvolume_num]"
		;;
esac
