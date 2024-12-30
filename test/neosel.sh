#! /bin/sh
#
# neosel.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#
DY_FILES=($(ls ~/.DY_SCE/fengzhenhua.gitlab.io/source/_posts/))
DY_FILESX=(${DY_FILES[*]%.*})
# DY_FILES=($(ls ~/.DY_SCE/fengzhenhua.gitlab.io/source/))
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
# 预设置高亮本色
# NEO_FORMAT="41;39" # 红底;白字
# NEO_FORMAT="42;39" # 绿底;白字
# NEO_FORMAT="43;39" # 黄底;白字
NEO_FORMAT="44;39"   # 蓝底;白字
# NEO_FORMAT="45;39" # 品底;白字
# NEO_FORMAT="46;39" # 青底;白字
# NEO_FORMAT="7"     # 反色
# 参数： 输出行，行号，数组号， 高亮行号
NEO_PRINT(){
    if [[ $3 -eq $4 ]]; then
        printf "\033[$1;1H\033[?25l\033[${NEO_FORMAT}m[%0${DY_NUM_WT}d] %s\033[0m\033[K\n" \
            "$2" "${NEO_ARR[$3-1]}"
    else
        printf "\033[$1;1H\033[?25l[%0${DY_NUM_WT}d] %s\033[K\n"  \
            "$2" "${NEO_ARR[$3-1]}"
    fi
}
# 参数：$1 起始点 $2 列表长度 $3 高亮行
NEO_LIA(){
    k=0 ; i=$1
    while [[ $k -lt $TTY_H ]]; do
        let k+=1
        if [ $i -lt -$2 ]; then
            let i=$i+$2
        fi
        let i+=1
        if [ $i -gt $2 ]; then
            let i=$i-$2
        fi
        if [ $i -lt 1 ]; then
            let j=$i+$2
        else
            j=$i
        fi
        NEO_PRINT $k $j $i $3
    done
}
NEO_SELECT(){
    echo -ne "\r\033[${NEO_FORMAT}m[s] 选择\033[0m\033[K " ; read TLS_SNum
    expr "$TLS_SNum" + 0 &> /dev/null
    if [ $? -eq 0 ]; then
        if [ $TLS_SNum -lt $1 -o $TLS_SNum -gt  $2 ]; then
            echo "编号超出范围，请重新选择编号！"
            exit
        else
            NEO_OUT_H=$TLS_SNum
        fi
    else
        echo "输入非数字，请重新输入编号！"
        exit
    fi
}
# 参数： 输出行，光标所在行
NEO_MENUE(){
    let r=$1+2
    if [ $NEO_SEL_ON -eq 1 ]; then
        printf "\033[$r;1H[s] 选择 [q] 退出 \033[${NEO_FORMAT}m%0${DY_NUM_WT}d\033[0m\033[K\033[?25h" $2

    else
        printf "\033[$r;1H[q] 退出 \033[${NEO_FORMAT}m%0${DY_NUM_WT}d\033[0m\033[K\033[?25h" $2
    fi
}
NEO_LISA(){
    DY_SET_SIZE
    p=$1 ; let q=$p+$TTY_H; m=$3
    if [ $q -gt "${#NEO_ARR[*]}" ]; then
        let q=$q-"${#NEO_ARR[*]}"
        let p=$p-"${#NEO_ARR[*]}"
        let m=$m-"${#NEO_ARR[*]}"
    fi
    if [ $p -le "-${#NEO_ARR[*]}" ]; then
        let q=$q+"${#NEO_ARR[*]}"
        let p=$p+"${#NEO_ARR[*]}"
        let m=$m+"${#NEO_ARR[*]}"
    fi
    NEO_LIA $p $2 $m
    DY_MKLINE
    if [ $m -le 0 ]; then
        let NEO_CURRENT=$m+"${#NEO_ARR[*]}"
    else
        NEO_CURRENT=$m
    fi
    NEO_MENUE "$TTY_H" "$NEO_CURRENT"
    read -s -n 1 ListDo
    case "$ListDo" in
        j)
            let m+=1
            if [ $m -gt $q ]; then
                let p+=$TTY_H
            fi
            NEO_LISA $p $2 $m
            ;;
        J)
            let p+=$TTY_H
            let m=$p+1
            NEO_LISA $p $2 $m
            ;;
        k)
            let m-=1
            if [ $m -le $p ]; then
                let p-=$TTY_H
            fi
            NEO_LISA $p $2 $m
            ;;
        K)
            let m=$p
            let p-=$TTY_H
            NEO_LISA $p $2 $m
            ;;
        "")
            if [ $NEO_SEL_ON -eq 1 ]; then
                NEO_OUT_H=$m
            else
                exit
            fi
            ;;
        s)
            if [ $NEO_SEL_ON -eq 1 ]; then
                NEO_SELECT $p $q
            else
                NEO_LISA $p $2 $m
            fi
            ;;
        q)
            exit 
            ;;
    esac
}
NEO_LIB(){
    k=0 ; i=$1
    while [[ $k -lt $2 ]]; do
        let k+=1
        if [ $i -lt -$2 ]; then
            let i=$i+$2
        fi
        let i+=1
        if [ $i -gt $2 ]; then
            let i=$i-$2
        fi
        if [ $i -lt 1 ]; then
            let j=$i+$2
        else
            j=$i
        fi
        NEO_PRINT $k $j $i $3
    done
}
NEO_LISB(){
    DY_SET_SIZE
    p=$1 ; q=$2 ; m=$3
    if [ $m -gt $q ]; then
        let m=$p+1
    fi
    if [ $m -le $p ]; then
        m=$q
    fi
    NEO_LIB $p $2 $m
    DY_MKLINE
    NEO_MENUE $q $m
    read -s -n 1 ListDo
    case "$ListDo" in
        j)
            let m+=1
            NEO_LISB $p $2 $m
            ;;
        k)
            let m-=1
            NEO_LISB $p $2 $m
            ;;
        s)
            if [ $NEO_SEL_ON -eq 1 ]; then
                NEO_SELECT $p $q
            else
                NEO_LISB $p $2 $m
            fi
            ;;
        "")
            if [ $NEO_SEL_ON -eq 1 ]; then
                NEO_OUT_H=$m
            else
                exit
            fi
            ;;
        q)
            exit
            ;;
    esac
}
# 参数：列出的数组， 1开启选择/0关闭选择
NEO_LIST(){
    unset NEO_ARR ; NEO_ARR=($1) ; NEO_SEL_ON=$2
    DY_NUM_WTX="${#NEO_ARR[*]}"
    DY_NUM_WT="${#DY_NUM_WTX}"
    clear
    DY_SET_SIZE
    if [ "${#NEO_ARR[*]}" -gt $TTY_H ]; then
        NEO_LISA 0 "${#NEO_ARR[*]}" 1
    else
        NEO_LISB 0 "${#NEO_ARR[*]}" 1
    fi
    # EDFILE="${NEO_ARR[$NEO_OUT_H-1]}"
    let NEO_NUM=$NEO_OUT_H-1
}
NEO_LIST "${DY_FILESX[*]}" 1
echo "${DY_FILES[$NEO_NUM]}"
