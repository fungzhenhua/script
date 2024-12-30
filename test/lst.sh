#! /bin/sh
#
# lst.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#

U_PAT="/run/media/$USER"
U_PAN=($(ls -d $U_PAT/*))
Arr=($(ls -d $U_PAT/*/*)) #取得所有U盘的目录
i=0
while [[ $i -lt "${#U_PAN[*]}" ]]; do
    Arr=(${Arr[*]//"${U_PAN[$i]}"/"$HOME/${U_PAN[$i]##*/}@UGIT"})
    let i+=1
done

# Brr=(${Arr[*]//"$U_PAT"/$HOME})
echo ${Arr[*]}
# echo ${U_PAN[*]}
# Arr=(${Arr[@]/#/$U_PAT\/})
# j=0
# while [[ $j -lt ${#Arr[*]} ]]; do
#     Brr+=($(ls -1 ${Arr[$j]}|awk '{print i$0}' i="${Arr[$j]}/"|grep "\."))
#     let j+=1
# done
# echo ${Brr[*]}
