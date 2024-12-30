#! /bin/sh
#
# regular.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#


Arr_A=( a b c d e f )
Arr_B=(${Arr_A[*]/e})

echo ${Arr_C[@]}

# file_list_1=("test1" "test2" "test3" "test4" "test5" "test6")
# file_list_2=("test5" "test6" "test7" "test8")
#
# # 获取并集，A ∪ B
# file_list_union=(`echo ${file_list_1[*]} ${file_list_2[*]}|sed 's/ /\n/g'|sort|uniq`)
# echo ${file_list_union[*]}
#
# # 获取交集，A n B
# file_list_inter=(`echo ${file_list_1[*]} ${file_list_2[*]}|sed 's/ /\n/g'|sort|uniq -c|awk '$1!=1{print $2}'`)
# echo ${file_list_inter[*]}
#
# # 对称差集，不属于 A n B
# file_list_4=(`echo ${file_list_1[*]} ${file_list_2[*]}|sed 's/ /\n/g'|sort|uniq -c|awk '$1==1{print $2}'`)
# echo ${file_list_4[*]}
