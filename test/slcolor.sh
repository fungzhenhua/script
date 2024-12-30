#! /bin/sh
#
# slcolor.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#
# NEO_FORMAT="41;39" # 红底;白字
# NEO_FORMAT="42;39" # 绿底;白字
# NEO_FORMAT="43;39" # 黄底;白字
NEO_FORMAT="41;39"
# NEO_FORMAT="45;39" # 品底;白字
# NEO_FORMAT="46;39" # 青底;白字
# NEO_FORMAT="7"     # 反色
NEO_WARNING="43;39"
NEO_SLCOLOR=( "41;39" "42;39" "43;39" "44;39" "45;39" "46;39" "7" )
NEO_DISPLAY_CL(){
    i=0
    while [[ $i -lt ${#NEO_SLCOLOR[*]} ]]; do
        let i+=1 
        echo -e "\033[${NEO_SLCOLOR[$i]}m[$i]ugit theme\033[0m"
    done
    echo -en "请输入\033[41:39m${2}主题\033[0m编号[1~${#NEO_SLCOLOR[*]}]："; read NEO_COLOR_THEME
    let NEO_COLOR_THEME-=1
    sed -i "s/^$1.*$/$1=\"${NEO_SLCOLOR[$NEO_COLOR_THEME]}\"/" $0
}
# NEO_DISPLAY_CL "NEO_FORMAT" "选定"
# NEO_DISPLAY_CL "NEO_WARNING" "警告"
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
                        echo "背景色号超出范围:$3~$4"
                    fi
                else
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
NEO_DIS_COLOR 30 37 40 47
NEO_DIS_COLOR 90 97 100 107
