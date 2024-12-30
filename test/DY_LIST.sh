#! /bin/sh
#
# DY_LIST.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#
# 2024年04月19日 引入规范的新函数
# 2024年05月26日 废除此代码，启用新一代列表程序，留此备份
i=1; j=$TTY_H
ListDo=one
TLS_CAS(){
    DY_SET_SIZE
    case "$ListDo" in
        s)
            if [ ${#DY_SELECT} -eq 0 ]; then 
                read -s -n 1 ListDo
                TLS_CAS
            else
                DY_READ_SEL "[s] 选择" ; read TLS_SNum
                expr "$TLS_SNum" + 0 &> /dev/null
                if [ $? -eq 0 ]; then
                    if [ 0 -ge $TLS_SNum -o $TLS_SNum -gt  ${#IFO[*]} ]; then
                        echo "编号超出范围，请重新选择编号！"
                        exit
                    else
                        EDFILE=${IFO[$TLS_SNum-1]}
                    fi
                else
                    echo "输入非数字，请重新输入编号！"
                    exit
                fi
            fi
            ;;
        j)
            if [ $j -lt ${#IFO[*]} ]; then
                let "j=$j+$TTY_H"
                if [ $j -gt ${#IFO[*]} ]; then
                    j=${#IFO[*]} ; let "i=$j-$TTY_H"
                fi
            else
                j=$TTY_H; i=1
            fi
            clear
            while [ $i -le $j ]; do
            printf "[%0${DY_NUM_WT}d] %s\n" \
                "$i" "${IFO[$i-1]}"
                let i+=1
            done
            TLS
            ;;
        k)
            let "j=$j-$TTY_H"
            clear
            if [ $j -le 0  ]; then
                let "j=$j+${#IFO[*]}"
            fi
            let "i=$j-$TTY_H"
            if [ $i -le 0 ]; then
                let "k=$i+${#IFO[*]}"
                while [[ $k -le ${#IFO[*]} ]]; do
                    printf "[%0${DY_NUM_WT}d] %s\n" \
                        "$k" "${IFO[$k-1]}"
                    let k+=1
                done
                k=1
                while [[ $k -le $j ]]; do
                    printf "[%0${DY_NUM_WT}d] %s\n" \
                        "$k" "${IFO[$k-1]}"
                    let k+=1
                done
                let "i=$j+1"
            else
                while [[ $i -le $j ]]; do
                    printf "[%0${DY_NUM_WT}d] %s\n" \
                        "$i" "${IFO[$i-1]}"
                    let i+=1
                done
            fi
            TLS
            ;;
        q)
            exit 
            ;;
        *)
            read -s -n 1 ListDo
            TLS_CAS
            ;;
    esac
}
DY_MKLINE(){
    l=0
    while [ $l -lt $TTY_W ]; do 
        echo -n "$DY_LINE"
        let l+=1
    done
}
TLS(){
    DY_SET_SIZE
    if [ $ListDo == "one" ]; then
        while [ $i -le $j ]; do
            printf "[%0${DY_NUM_WT}d] %s\n" \
                "$i" "${IFO[$i-1]}"
            let i+=1
        done
    fi
    DY_MKLINE
    echo ""
    echo -n "[j] 下翻 [k] 上翻 ${DY_SELECT}[q] 退出 "
    read -s -n 1 ListDo
    TLS_CAS
}
DY_READ_SEL(){
    echo -ne "\r\033[47;30m$1\033[0m "; echo -ne "\033[K" ;
}
TLS_CAS_SUB(){
    DY_SET_SIZE
    case "$TLS_SNum" in 
        q)
            exit 
            ;;
        s)
            if [  ${#DY_SELECT} -eq 0 ]; then 
                read -s -n 1 TLS_SNum
                TLS_CAS_SUB
            else
                DY_READ_SEL "[s] 选择"; read TLS_SNum
                expr "$TLS_SNum" + 0 &> /dev/null
                if [ $? -eq 0 ]; then
                    if [ 0 -ge $TLS_SNum -o $TLS_SNum -gt  ${#IFO[*]} ]; then
                        echo "编号超出范围，请重新选择编号！"
                        exit
                    else
                        EDFILE=${IFO[$TLS_SNum-1]}
                    fi
                else
                    echo "输入非数字，请重新输入编号！"
                    exit
                fi
            fi
            ;;
        *)
            read -s -n 1 TLS_SNum
            TLS_CAS_SUB
            ;;
    esac
}
DY_LIST(){
    unset IFO
    IFO=($1) ; DY_SELECT=$2
    DY_SET_SIZE
    DY_NUM_WTX="${#IFO[*]}"
    DY_NUM_WT="${#DY_NUM_WTX}"
    if [ ${#IFO[*]} -lt $TTY_H ]; then
        while [ $i -le ${#IFO[*]} ]; do
            printf "[%0${DY_NUM_WT}d] %s\n" \
                "$i" "${IFO[$i-1]}"
            let i+=1
        done
        DY_MKLINE
        echo ""
        echo -n "${DY_SELECT}[q] 退出 " ; read -s -n 1 TLS_SNum
        TLS_CAS_SUB
    else
        TLS
    fi
}
