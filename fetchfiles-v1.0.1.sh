#!/usr/bin/bash
#文件存放的目录
TMP=$(pwd)/tmp
#执行过程中错误的输出
errors=$TMP/errors
#执行过程中消息的输出
logs=$TMP/messages
#要测试的文件夹
dir_test=/
#要测试的文件列表 except files in itself /proc /sys /dev
filelist=`find $dir_test -path /data -prune -o -path /proc -prune -o -path /sys -prune -o -path /dev -prune -o -type f -print`

#创建所有需要的文件夹
function mk_dir ()
{
	dir_md5=$TMP/md5
	if [ ! -d $dir_md5 ]
	then 
		mkdir -p $dir_md5
	else
		rm -rf $dir_md5/*
	fi
	dir_elf=$TMP/ldd
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
#对每一个文件操作的函数
function file_op ()
{
	
	file=$1;
	if [ -f $file ]
	then
		file $file | grep "ELF"|grep "dynamically linked"  1> /dev/null 2> $errors
		is_elf=$?
		if [ $is_elf -eq 0 ]
		then
			if test ! -d $dir_elf`dirname $file`
			then
				mkdir -p $dir_elf`dirname $file`
			fi
			ldd $file 2> $errors | awk '{$NF="";print}' | sort > $dir_elf$file\.ldd  
		fi
		file $file | grep "not stripped"  1> /dev/null 2> $errors
		is_nm=$?
		if [ $is_nm -eq 0 ]
		then
			if test ! -d $dir_nm`dirname $file`
			then
				mkdir -p $dir_nm`dirname $file`
			fi
			nm $file 2> $errors |awk '{print $NF}'|sort > $dir_nm$file\.nm  
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

#创建文件夹
mk_dir
#对每一个需要测试的文件进行处理
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
		#每个文件的处理都是相互独立的，所以可以并行。
		file_op $file &
		#设置最大并行数
		a=`jobs |awk -F']' '{print $1}'|tail -1` && b=${a:1} &> /dev/null
		if [ $b -gt 100 ];then echo $b;wait;fi;
	done	
