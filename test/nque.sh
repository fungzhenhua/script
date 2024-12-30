#! /bin/sh
#
# nque.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#
# 2024年06月21日
Arr_TES=("[d]发布博客"  "[s]预览博客" "[b]回归编辑" "[q]退出")
NEO_FORMAT="44;39"   # 蓝底;白字
DY_BUT_LS(){
    DY_BUTTON=($1)
    if [ $i -eq 0 ]; then
        echo -ne "\r\033[2K"
    fi
    if [ $m -ge "${#DY_BUTTON[*]}" ]; then
        let m-="${#DY_BUTTON[*]}"
    fi
    if [ $m -lt 0 ]; then
        let m="${#DY_BUTTON[*]}"-1
    fi
    while [[ $i -le ${#DY_BUTTON[*]} ]]; do
        if [[ $i -eq $m ]]; then
            echo -en "\e[${NEO_FORMAT}m${DY_BUTTON[$i]}\e[0m "
        else
            echo -n "${DY_BUTTON[$i]} "
        fi
        let i+=1
    done
}
# 参数：初始，选中
DY_BUT_LIST(){
    i=$1; m=$2
    DY_BUT_LS "$3"
    read -s -n 1 ListDo
    case "$ListDo" in
        l|L|j|J)
            let m+=1
            DY_BUT_LIST 0 $m "$3"
            ;;
        h|H|k|K)
            let m-=1
            DY_BUT_LIST 0 $m "$3"
            ;;
        d|s|b|q|D|S|B|Q)
            QueRen=$ListDo
            ;;
        "")
            QueRen=$m
            ;;
        *)
            DY_BUT_LIST 0 $m "$3"
            ;;
    esac
}
DY_BUT_LIST 0 0 "${Arr_TES[*]}"
# if [ $QueRen == 0 ]; then
#     echo "hello"
# else
#     echo $QueRen
# fi
expr "$QueRen" + 1 &> /dev/null
if [ $? -eq 0 ]; then
    echo $QueRen
else
    echo $QueRen
    echo "非数字"
fi
