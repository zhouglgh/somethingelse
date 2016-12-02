#!/usr/bin/bash
#本目录
dir_root=$(pwd)
#作为比较基准的目录
	dir_base=$dir_root/tmpremote
#作为对比的目录
	dir_another=$dir_root/tmplocal
#文件的结果保存
	same=same.txt
	emas=notsame.txt
	diff=diff.txt
#基准目录中的每一个文件
filelist=$(find $dir_base -type f)
#一个函数用来比较基准文件有的，目标文件是否有
function comp_sameORnot()
{
#基准文件的相对根目录的路径
	name=`echo $file |cut -b $(length=${#dir_base};let length+=2;echo $length)-`
#基准文件名
		filename=${name##*/}
#对比文件夹里面的文件
	filea=$dir_another/$name
#判断有无
		ls $file  &> /dev/null;if [ $? -eq 0 ];then res=1 ;else res=0 ;fi;
	ls $filea &> /dev/null;if [ $? -eq 0 ];then resa=1;else resa=0;fi;
	if [ $res -eq $resa ]
		then 
			echo $filename    >> $same;
	diff $file $filea >> $diff;
	else
		echo $filename >> $emas;
	fi

}
#处理文件
if [ -f $same ];then rm -f $same;fi
if [ -f $emas ];then rm -f $emas;fi
for file in $filelist
do
#每个文件的处理都是相互独立的，所以可以并行。
comp_sameORnot &
#确定并行最大值
a=`jobs |awk -F']' '{print $1}'|tail -1` && b=${a:1} &> /dev/null
if [ $b -gt 100 ];then echo $b;wait;fi;
done
