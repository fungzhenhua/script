#! /bin/sh
#
# ulist.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
# 原脚本中的字符
FenGeSym="-"
LineWidth=$(stty size |awk '{print $2}')
#新脚本变量
IFO=($(cat ./Ifo.txt))
TMS=$(stty size|awk '{print $1}')
let TMS-=2
i=1; j=$TMS
ListDo=one
TLS(){
    if [ $ListDo == "one" ]; then
        while [ $i -le $j ]; do
            echo [$i] ${IFO[$i-1]}
            let i+=1
        done
    fi
    l=0
    while [ $l -lt $LineWidth ]; do 
        echo -n "$FenGeSym"
        let l+=1
    done
    echo ""
    echo -n "[编号] 编辑 [j] 下翻 [k] 上翻 [q] 退出 : " ; read -s -n 1 ListDo
    expr "$ListDo" + 0 &> /dev/null
    if [ $? -eq 0 ]; then
        EDFILE=${IFO[$ListDo-1]}
        echo $EDFILE
    else
        case "$ListDo" in
            j)
                if [ $j -lt ${#IFO[*]} ]; then
                    let "j=$j+$TMS"
                    if [ $j -gt ${#IFO[*]} ]; then
                        j=${#IFO[*]} ; let "i=$j-$TMS"
                    fi
                else
                    j=$TMS; i=1
                fi
                clear
                while [ $i -le $j ]; do
                    echo [$i] ${IFO[$i-1]}
                    let i+=1
                done
                TLS
                ;;
            k)
                let "j=$j-$TMS"
                clear
                if [ $j -le 0  ]; then
                    let "j=$j+${#IFO[*]}"
                fi
                let "i=$j-$TMS"
                if [ $i -le 0 ]; then
                    let "k=$i+${#IFO[*]}"
                    while [[ $k -le ${#IFO[*]} ]]; do
                        echo [$k] ${IFO[$k-1]}
                        let k+=1
                    done
                    k=1
                    while [[ $k -le $j ]]; do
                        echo [$k] ${IFO[$k-1]}
                        let k+=1
                    done
                    let "i=$j+1"
                else
                    while [[ $i -le $j ]]; do
                        echo [$i] ${IFO[$i-1]}
                        let i+=1
                    done
                fi
                TLS
                ;;
            *)
                exit
                ;;
        esac
    fi
}
TLS
