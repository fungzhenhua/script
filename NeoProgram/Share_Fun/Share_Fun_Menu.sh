#! /bin/sh
#
# 项目：Share_Fun_Menu.sh
# 版本：V1.1
# Copyright (C) 2023 feng <feng@arch>
# Distributed under terms of the MIT license.
#
DY_LINE="\u2584"
NEO_FORMAT="44;39"
# 列表程序
DY_SET_SIZE(){
    if [ -t 0 ]; then
        TTY_H=$(stty size|awk '{print $1}')
        TTY_W=$(stty size|awk '{print $2}')
    else
        TTY_H=$(tput lines 2>/dev/null) || TTY_H=37
        TTY_W=$(tput cols 2>/dev/null) || TTY_W=147
    fi
    let TTY_H-=2
}
DY_SET_SIZE
# 2024年05月26日 引入全新列表程序
DY_MKLINE(){
    l=0
    while [ $l -lt $TTY_W ]; do 
        echo -en "$DY_LINE"
        let l+=1
    done
}
# 预设置高亮本色, 由于主题的数量较小，所以简单的罗列出来,不作选择式菜单
NEO_DIS_COLOR(){
    i=$1;j=$3
    while [[ $1 -le $i && $i -le $2  ]]; do
        while [[ $3 -le $j && $j -le $4 ]]; do
            echo -en "\033[${i};${j}m${i};${j}\033[0m" 
            let j+=1
        done
        echo ""; j=$3
        let i+=1
    done
    read -p '请选择主题编号: ' NEO_THEME_CL
    if [[ ! $NEO_THEME_CL =~ ";" ]]; then
        echo "请输入正确的格式: 文字色号;背景色号"
        exit
    else
        NEO_THEME_WD=${NEO_THEME_CL%%;*}
        NEO_THEME_BG=${NEO_THEME_CL##*;}
        expr "$NEO_THEME_BG" + 1 &> /dev/null
        if [ $? -eq 0 ]; then
            expr "$NEO_THEME_WD" + 1 &> /dev/null
            if [ $? -eq 0 ]; then
                if [[ $1 -le $NEO_THEME_WD && $NEO_THEME_WD -le $2 ]]; then
                    if [[ $3 -le $NEO_THEME_BG && $NEO_THEME_BG -le $4 ]]; then
                        NEO_THEME_COLOR=$NEO_THEME_CL
                    else
                        NEO_THEME_COLOR="44;39"
                        echo "背景色号超出范围:$3~$4"
                    fi
                else
                    NEO_THEME_COLOR="44;39"
                    echo "文字色号超出范围:$1~$2"
                    if [[ $3 -gt $NEO_THEME_BG && $NEO_THEME_BG -gt $4 ]]; then
                        echo "背景色号超出范围:$3~$4"
                    fi
                fi
            else
                echo "请输入正确的文字色!"
            fi
        else
            echo "请输入正确的背景色!"
        fi
    fi
    echo -en "\r已选择主题编号:\033[${NEO_THEME_COLOR}m${NEO_THEME_COLOR}\033[0m" 
}
NEO_THEME_SET(){
    NEO_DIS_COLOR 30 37 40 47
    sudo sed -i "s/^$1.*$/$1=\"${NEO_THEME_COLOR}\"/" $USB_EXE
}
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
    expr "$TLS_SNum" + 1 &> /dev/null
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
        j|h)
            let m+=1
            if [ $m -gt $q ]; then
                let p+=$TTY_H
            fi
            NEO_LISA $p $2 $m
            ;;
        J|H)
            let p+=$TTY_H
            let m=$p+1
            NEO_LISA $p $2 $m
            ;;
        k|l)
            let m-=1
            if [ $m -le $p ]; then
                let p-=$TTY_H
            fi
            NEO_LISA $p $2 $m
            ;;
        K|L)
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
        ${NEO_ESC})
            read -sn 2 SubListDo
            case "$SubListDo" in
                "[H")
                    NEO_LISA 0 $2 1
                    ;;
                "[F")
                    NEO_LISA -$TTY_H $2 0
                    ;;
                "[A"|"[D")
                    let m-=1
                    if [ $m -le $p ]; then
                        let p-=$TTY_H
                    fi
                    NEO_LISA $p $2 $m
                    ;;
                "[B"|"[C")
                    let m+=1
                    if [ $m -gt $q ]; then
                        let p+=$TTY_H
                    fi
                    NEO_LISA $p $2 $m
                    ;;
                "[5")
                    read -sn 1 NEO_NULL
                    let m=$p
                    let p-=$TTY_H
                    NEO_LISA $p $2 $m
                    ;;
                "[6")
                    read -sn 1 NEO_NULL
                    let p+=$TTY_H
                    let m=$p+1
                    NEO_LISA $p $2 $m
                    ;;
                *)
                    NEO_LISA $p $2 $m
                    ;;
            esac
            ;;
        s|S)
            if [ $NEO_SEL_ON -eq 1 ]; then
                NEO_SELECT $p $q
            else
                NEO_LISA $p $2 $m
            fi
            ;;
        q|Q)
            exit 
            ;;
        *)
            NEO_LISA $p $2 $m
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
        j|h|J|H)
            let m+=1
            NEO_LISB $p $2 $m
            ;;
        k|l|K|L)
            let m-=1
            NEO_LISB $p $2 $m
            ;;
        s|S)
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
        ${NEO_ESC})
            read -sn 2 SubListDo
            case "$SubListDo" in
                "[A"|"[D")
                    let m-=1
                    NEO_LISB $p $2 $m
                    ;;
                "[B"|"[C")
                    let m+=1
                    NEO_LISB $p $2 $m
                    ;;
                *)
                    NEO_LISB $p $2 $m
                    ;;
            esac
            ;;
        q|Q)
            exit
            ;;
        *)
            NEO_LISB $p $2 $m
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
    EDFILE="${NEO_ARR[$NEO_OUT_H-1]}"
}
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
        ${NEO_ESC})
            read -sn 2 SubListDo
            case "$SubListDo" in
                "[A"|"[D")
                    let m-=1
                    DY_BUT_LIST 0 $m "$3"
                    ;;
                "[B"|"[C")
                    let m+=1
                    DY_BUT_LIST 0 $m "$3"
                    ;;
                *)
                    DY_BUT_LIST 0 $m "$3"
                    ;;
            esac
            ;;
        *)
            DY_BUT_LIST 0 $m "$3"
            ;;
    esac
}
