#! /bin/sh
#
# direct.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#


# akey=(0 0 0)
#
# cESC=`echo -ne "\033"`
#
# while :
# do
#     #这里要注意，这里有-n选项，后跟一个数字，指定输入的字符长度最大值，所以不管key变量的值有多少个字符，都是一个值一个值做循环， 有多少个值就循环多少次
#     #输入键盘的上下左右键时，都有三个字符(ESC键算一个)，所以都是做三次循环，每做一次循环，akey的值都会发生改变
#     read -s -n 1 key
#
#     akey[0]=${akey[1]}
#     akey[1]=${akey[2]}
#     akey[2]=${key}
#
#     if [[ ${key} == ${cESC} && ${akey[1]} == ${cESC} ]]; then
#         echo "ESC键"
#     elif [[ ${akey[0]} == ${cESC} && ${akey[1]} == "[" ]]; then
#         if [[ ${key} == "A" ]];then echo "上键"
#         elif [[ ${key} == "B" ]];then echo "向下"
#         elif [[ ${key} == "D" ]];then echo "向左"
#         elif [[ ${key} == "C" ]];then echo "向右"
#         fi
#     fi
# done

# 2024-07-14 11:18
# cESC=`echo -ne "\033"`
# echo -n "请输入按键"; read -sn 3 key
# if [[ $key == "${cESC}[A" ]]; then
#     echo "向上"
# elif [[ $key == "${cESC}[B" ]]; then
#     echo "向下"
# elif [[ $key == "${cESC}[C" ]]; then
#     echo "向右"
# elif [[ $key == "${cESC}[D" ]]; then
#     echo "向左"
# fi

cESC=`echo -ne "\033"`
# echo -n "请输入按键"; read -sn 1 key
# if [[ $key = "$cESC" ]]; then
#     read -sn 2 me
#     echo $me
# fi
# case "$key" in
#     "[A") echo "向上"
#     ;;
#     2|3) echo 2 or 3
#     ;;
#     *) echo default
#     ;;
# esac
#
# read -sn 3 key
echo -n "请输入按键"; read  key
echo $key
