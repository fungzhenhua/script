#! /bin/sh
#
# select.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#
DY_FILES=($(ls ~/.DY_SCE/fengzhenhua.gitlab.io/source/_posts/))
DY_SET_SIZE(){
    TTY_H=$(stty size|awk '{print $1}')
    let TTY_H-=2
    TTY_W=$(stty size|awk '{print $2}')
}
DY_LINE="-"
DY_MKLINE(){
    l=0
    while [ $l -lt $TTY_W ]; do 
        echo -n "$DY_LINE"
        let l+=1
    done
}
# 
# 2024年05月25日, 测试成功
# 三个参数：最低，最高，选定
DY_LS(){
    clear; i=$1 
    while [[ $i -le $2 ]]; do
        if [[ $i -eq $3 ]]; then
            echo -e "\033[7m[$i] ${DY_FILES[$i-1]}\033[0m"
        else
            echo "[$i] ${DY_FILES[$i-1]}"
        fi
        let i+=1
    done
}
# 三个参数：最低，最高，选定
DY_LIST(){
    DY_SET_SIZE
    DY_LMIN=$1 ; let DY_LMAX=$DY_LMIN+$TTY_H ; let DY_LMAX-=1 ; m=$3
    if [[ $m -lt $DY_LMIN ]]; then 
        m=$DY_LMAX
    elif [[ $m -gt $DY_LMAX ]]; then
        m=$DY_LMIN
    fi
    DY_LS $DY_LMIN $DY_LMAX $m 
    DY_MKLINE
    echo -n "[j] 下翻 [k] 上翻 ${DY_SELECT}[q] 退出 "
    read -s -n 1 ListDo
    case "$ListDo" in
        j) 
            let m+=1
            DY_LIST $DY_LMIN $DY_LMAX $m
            ;;
        k)
            let m-=1
            DY_LIST $DY_LMIN $DY_LMAX $m
            ;;
        *)
            exit
            ;;
    esac
}
# DY_LIST 1 36 2
