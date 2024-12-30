#! /bin/sh
#
# dic.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#

declare -A dic=([key1]="value1" [key2]="value2")

# for md in ${dic[*]} ;do
#     echo $md 
# done
echo ${!dic[*]}
echo ${!dic[@]}
echo ${dic[*]}
echo ${dic[@]}
echo ${#dic[*]}
echo ${#dic[@]}
