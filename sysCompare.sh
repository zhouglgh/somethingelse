#!/usr/bin/bash
TMP=/home/zhouyuchen/tmp
TMP=/data/tmp
errors=$TMP/errors
logs=$TMP/messages
a=/home/zhouyuchen/Pingtai/
a=/
#except itself /proc /sys /dev
filelist=`find $a -path /data -prune -o -path /proc -prune -o -path /sys -prune -o -path /dev -prune -o -type f -print`


function mk_dir ()
{
	dir_md5=$TMP/md5
	if [ ! -d $dir_md5 ]
	then 
		mkdir -p $dir_md5
	else
		rm -rf $dir_md5/*
	fi
	dir_elf=$TMP/elf
	if [ ! -d $dir_elf ]
	then 
		mkdir -p $dir_elf
	else
		rm -rf $dir_elf/*
	fi
	dir_nm=$TMP/nm
	if [ ! -d $dir_nm ]
	then 
		mkdir -p $dir_nm
	else
		rm -rf $dir_nm/*
	fi
	dir_dev=$TMP/dev
	if [ ! -d $dir_dev ]
	then 
		mkdir -p $dir_dev
	else
		rm -rf $dir_dev/*
	fi
}
function file_op ()
{
	
	file=$1;
	if [ -f $file ]
	then
		file $file | grep "ELF"  1> /dev/null 2> $errors
		is_elf=$?
		if [ $is_elf -eq 0 ]
		then
			if test ! -d $dir_elf`dirname $file`
			then
				mkdir -p $dir_elf`dirname $file`
			fi
			ldd $file > $dir_elf$file\.ldd  2> $errors
		fi
		file $file | grep "not stripped"  1> /dev/null 2> $errors
		is_nm=$?
		if [ $is_nm -eq 0 ]
		then
			if test ! -d $dir_nm`dirname $file`
			then
				mkdir -p $dir_nm`dirname $file`
			fi
			nm $file > $dir_nm$file\.nm  2> $errors
		fi
		echo $file | grep -e "^\/dev"  1> /dev/null 2> $errors
		is_dev=$?
		if [ $is_dev -eq 0 ]
		then
			if test ! -d $dir_dev`dirname $file`
			then
				mkdir -p $dir_dev`dirname $file`
			fi
			echo $file > $dir_dev$file\.dev 2> $errors
		fi
	fi
}

mk_dir

for file in $filelist
	do
		if test -f $file
		then
			if test ! -d $dir_md5`dirname $file`
			then
				mkdir -p $dir_md5`dirname $file`
			fi
			md5sum $file > $dir_md5$file\.md5 &
		fi
		file_op $file &
		a=`jobs |awk -F']' '{print $1}'|tail -1` && b=${a:1} &> /dev/null
		if [ $b -gt 100 ];then echo $b;wait;fi;
	done	



