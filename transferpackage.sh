#!/bin/bash

# v0.2
# 1、添加套件外部链接检测功能
#    提示：部分套件会链接到套件文件夹外部的文件（夹），迁移后一般还能正常运行，如果外部的文件（夹）在需要调整的存储空间上，你可能需要手动移动它们，同时修改对应的软链接
# 2、增加显示特定存储空间上安装的套件清单功能
# 3、增加对迁移目标存储空间的检测

operation=$1


dir=("conf" "home" "store" "temp" "data")
link=("etc" "home" "target" "tmp" "var")


check_package () {
	echo 正在检测套件是否含有外部链接...
	check_result=0
	for l in "${link[@]}";
	do
		if [ -e /var/packages/$package/$l ]
		then
			for f in `find /var/packages/$package/$l/ -type l`
			do
				#ll=$(ls -l $f)
				#echo /${ll#*/}
				local k=0
				for ((j=0;j<=4;j++))
				do
				if [ -e /var/packages/$package/${link[$j]} ]
				then
					lk=$(ls -l /var/packages/$package/${link[$j]})
					# echo realpath1: `realpath -e --relative-base=${lk##* } $f`
					# echo realpath2: `realpath -e $f`
					if [ `realpath -e --relative-base=${lk##* } $f` = `realpath -e $f` ] 
					then
						# echo realpath1=realpath2
						((k=k+1))
					else
						# echo $f在${lk##* }目录下
						break
					fi
					if [ $k -eq 5 ]
					then
						check_result=1
						ll=$(ls -l $f)
						echo 有外部链接：/${ll#*/}
					fi
				else
					echo /var/packages/$package/${link[$j]} 不存在.
					exit
				fi		
				done	
			done
		else
			echo /var/packages/$package/$l 不存在.
			exit
		fi
	done
	if [ $check_result -eq 0 ]
	then
		echo 没有外部链接
	fi
}

check_answer () {
	local a=1
	while [ $a -ne 0 ]
		do
		read -n1 -p "是否继续迁移套件$package?[y/n]" answer
		case $answer in
			Y|y)
				a=0
				echo;;
			N|n)
				echo
				exit;;
		esac
	done
}

show_usage () {
	echo "使用方法:
	显示套件清单：
		transferpackage.sh list [存储空间编号]
		示例： transferpackage.sh list 显示所有安装的套件
		       transferpackage.sh list 2 显示所有安装在存储空间2上的套件
	迁移套件：
		transferpackage.sh transfer 套件名 目标存储空间编号
	检查套件外部链接：
		transferpackage.sh check 套件名
	显示本帮助：
		transferpackage.sh help"
}

case $operation in
	list)
		if [ $2 ]
		then
			synostgvolume --enum-dep-pkgs /volume$2
		else
			#package_list=$(ls /var/packages/ |tr -s " ")
			echo " 套件名 -- 套件中心显示的名称
-----------------------------"
			for a in `synopkg list --name`
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
				echo $a -- /var/packages/$a/INFO 文件不存在.该套件可能已卸载.
			fi
			done
		fi
		;;
	transfer)
		if [ ! $2 ];then show_usage;exit;fi
		if [ ! $3 ];then show_usage;exit;fi
		package=$2
		new_volume=$3
		# 检测目标存储空间
		synostgvolume --is-writable /volume$new_volume 2>/dev/null
		if [ $? -eq 255 ];then echo 错误：目标存储空间不可用;exit;fi
		case `synopkg status $package | sed 's/^.*Status: \[//g' | sed 's/\].*//g'` in
			0)
				echo "检测到套件$package未停用，为避免出现未知错误建议先停用该套件再进行迁移."
				check_answer
				;;
			255)
				echo 套件$package未安装
				exit;;
			263)
				#echo 套件$package已停用
				;;
		esac
		# 检测外部链接
		check_package
		if [ $check_result -eq 1 ]
		then
			echo "套件$package存在以上外部链接，请根据需要手动迁移这些文件(夹)并修改相应链接."
			check_answer
		fi
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
					if [ $? -eq 0 ];then echo -e "添加文件夹 /volume$new_volume/@app${dir[$i]}...\e[0;32m完成\e[0m.";else echo -e "添加文件夹 /volume$new_volume/@app${dir[$i]}...\e[0;31m失败\e[0m.";exit;fi
				fi
				new_lk=$original_lk
				new_lk=${original_lk/$original_volume/$new_volume}
				cp -a $original_lk $new_lk
				if [ $? -eq 0 ];then echo -e "复制 $original_lk 到 $new_lk...\e[0;32m完成\e[0m.";else echo -e "复制 $original_lk 到 $new_lk...\e[0;31m失败\e[0m.";exit;fi
				ln -snf $new_lk /var/packages/$package/${link[$i]}
				if [ $? -eq 0 ];then echo -e "链接 $new_lk 到 /var/packages/$package/${link[$i]}...\e[0;32m完成\e[0m.";else echo -e "链接 $new_lk 到 /var/packages/$package/${link[$i]}...\e[0;31m失败\e[0m.";exit;fi
			else
				echo "目标存储空间与套件/var/packages/$package/${link[$i]}文件夹所在存储空间相同，无需迁移."
			fi
		else
			echo "/var/packages/$package/${link[$i]} 不存在."
			exit
		fi
		done
		;;
	check)
		if [ ! $2 ];then show_usage;exit;fi
		package=$2
		check_package
		;;
	help|*)
		show_usage
		;;
esac
