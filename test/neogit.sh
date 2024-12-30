#! /bin/sh
#
# Program  : ugit.sh
# Date     : 2024-05-07 12:50
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2024 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
USB_VERSION=V4.0
# 超时时间
timeout=1
# 目标网站
target=www.baidu.com
USB_MAP_CFG=~/.ugitmap
USB_RCFG=~/.ugitrcf
USB_SCFG=.git/config
USB_TAG="@UGIT"
USB_BNAME=usbmain # branch name
if [ "$(pacman -Q |grep fastfetch)" = "" ]; then sudo pacman --needed --noconfirm -S fastfetch; fi
USB_COMMENT=$(fastfetch |grep Host| awk -F'(' '{print $2}'|awk -F')' '{print $1}')
USB_COMMENT=$(echo $USB_COMMENT | sed 's/ /\-/g')
USB_COMMENT="${USER}@${USB_COMMENT}"
if [ ! -e $USB_MAP_CFG ]; then 
    touch $USB_MAP_CFG
    chmod +w $USB_MAP_CFG
fi
if [ ! -e $USB_RCFG ]; then
    touch $USB_RCFG
    chmod +w $USB_RCFG
    echo "exampal: " > $USB_RCFG
    echo "gitee https://github.com/project.git" >> $USB_RCFG
fi
USB_EXE=/usr/local/bin/ugit
# 安装脚本到系统目录
if [[ $# -gt 0 && $0 =~ ".sh" ]]; then
    if [ $1 == "-i" -o $1 == "-I" -o $1 == "--install" -o $1 == "--INSTALL" ]; then
        sudo cp -f $0 $USB_EXE
        sudo chmod 755 $USB_EXE
        echo "ugit-${USB_VERSION}成功安装到: $USB_EXE"
        exit
    fi
fi
# 检测是否插入U盘，插入则建立U盘内容列表
unset USB_MAP
unset USB_RCF
USB_MAP=($(cat $USB_MAP_CFG))
USB_RCF=($(cat $USB_RCFG))
USB_REMORT="/run/media/$USER" # udisks2 默认u盘挂载点
USB_PC_PATH=$PWD
if [ -e $USB_REMORT ]; then
    unset USB_ARR
    USB_ARR=($(ls $USB_REMORT/))
else
    exit
fi
# 选择目标U盘
if [ ${#USB_ARR[*]} -eq 0 ]; then
    echo "未检测到U盘，请插入U盘!"
    exit
else  # 获取多个U盘的uuid和相应远程U盘地址
    USB_UPANP=($(lsblk -o mountpoint | grep "/run/media/"))
    unset USB_REMORT_PROJ
    USB_REMORT_PROJ=($(lsblk -o uuid,mountpoint |grep "/run/media/" ))
    unset USB_RLIST
    i=1; j=1
    while [[ $i -lt ${#USB_REMORT_PROJ[*]} ]]; do
        USB_REMORT_PNAME=($(ls ${USB_REMORT_PROJ[$i]}))
        k=0
        while [[ $k -lt ${#USB_REMORT_PNAME[*]} ]]; do
            if [[ "${USB_REMORT_PNAME[$k]}" =~ ".git" ]]; then
                USB_RLIST[$j-1]="${USB_REMORT_PROJ[$i-1]}"
                USB_RLIST[$j]="${USB_REMORT_PROJ[$i]}/${USB_REMORT_PNAME[$k]}"
                let j+=2
            fi
            let k+=1
        done
        let i+=2 
    done
fi
USB_MAPED=(${USB_MAP[*]##*/})
USB_RLISTED=(${USB_RLIST[*]##*/})
USB_RLISTED=(${USB_RLISTED[*]%%.git*})
USB_RLISTEL=(${USB_RLIST[*]%/*})
USB_RLISTEL=(${USB_RLISTEL[*]##*/})
j=1 
while [[ $j -lt "${#USB_RLISTED[*]}" ]]; do
    USB_RLISTEL[$j]="$HOME/${USB_RLISTEL[$j]}$USB_TAG/${USB_RLISTED[$j]}" # 以U盘为标准，本地应当存在的目录
    let j+=2
done
unset USB_MAP_EFF     ; unset USB_MAP_ID     # 本地已经存在的仓库
unset USB_RLI_EFF     ; unset USB_RLI_ID     # 本地与U盘共同存在的仓库
unset USB_RLI_UEFF    ; unset USB_RLI_UID    # U盘存在，本地不存在的仓库, U盘地址
unset USB_MAPRLI_UEFF ; unset USB_MAPRLI_UID # U盘存在，本地不存在的仓库，本地地址
unset USB_MAP_UEFF    ; unset USB_MAP_UID    # 在已经连接的U盘中不存在的仓库，需删除
i=1; k=0
while [[ $i -lt "${#USB_MAP[*]}" ]]; do
    j=1
    while [[ $j -lt "${#USB_RLISTEL[*]}" ]]; do
        if [[ "${USB_RLISTEL[$j-1]}" = "${USB_MAP[$i-1]}" && "${USB_RLISTEL[$j]}" = "${USB_MAP[$i]}" ]]; then
            USB_MAP_EFF[$k]="${USB_MAP[$i]}"  ; USB_MAP_ID[$k]="${USB_MAP[$i-1]}"
            USB_RLI_EFF[$k]="${USB_RLIST[$j]}" ; USB_RLI_ID[$k]="${USB_RLIST[$j-1]}"
            let k+=1
        fi
        let j+=2
    done
    let i+=2
done
# 检测本地MAP地址
i=0; k=1 
while [[ $i -lt "${#USB_MAP_EFF[*]}" ]]; do
    # 有效仓库目录，若本地不存在，则创建目录
    if [ ! -e "${USB_MAP_EFF[$i]%/*}" ]; then
        mkdir -p "${USB_MAP_EFF[$i]%/*}"
    fi
    # 有效仓库，若本地不存在，则主动从远程U盘克隆到本地
    if [[ ! -e "${USB_MAP_EFF[$i]}" ]]; then
        git clone "${USB_RLI_EFF[$i]}" "${USB_MAP_EFF[$i]}" &> /dev/null
        echo "[$k] ${USB_MAP_EFF[$i]} <== ${USB_RLI_EFF[$i]} 克隆成功!"
        let k+=1
    fi
    let i+=1
done
# 不根据U盘名来判断仓库是否存在，有待研究
# j=1 ; k=0
# while [[ $j -lt "${#USB_RLISTED[*]}" ]]; do
#     i=1
#     while [[ $i -lt "${#USB_MAPED[*]}" ]]; do
#         if [[ "${USB_MAPED[$i]}" = "${USB_RLISTED[$j]}" && "${USB_MAPED[$i-1]}" = "${USB_RLISTED[$j-1]}" ]]; then
#             USB_MAP_EFF[$k]="${USB_MAP[$i]}" ; USB_MAP_ID[$k]="${USB_MAPED[$i-1]}"
#             USB_RLI_EFF[$k]="${USB_RLIST[$j]}" ; USB_RLI_ID[$k]="${USB_RLISTED[$j-1]}"
#             let k+=1
#         fi
#         let i+=2 
#     done
#     let j+=2 
# done
j=1 ; l=0
while [[ $j -lt "${#USB_RLIST[*]}" ]]; do
    i=0; k=0
    while [[ $i -lt "${#USB_RLI_EFF[*]}" ]]; do
        if [[ "${USB_RLI_EFF[$i]}" = "${USB_RLIST[$j]}" && "${USB_RLI_ID[$i]}" = "${USB_RLIST[$j-1]}" ]] ; then
            k=1
        fi
        let i+=1
    done
    if [ $k -eq 0 ]; then
        USB_RLI_UEFF[$l]="${USB_RLIST[$j]}"      ; USB_RLI_UID[$l]="${USB_RLIST[$j-1]}"
        USB_MAPRLI_UEFF[$l]="${USB_RLISTEL[$j]}" ; USB_MAPRLI_UID[$l]="${USB_RLISTEL[$j-1]}"
        let l+=1
    fi
    let j+=2
done
unset MAP_UEFF_HANG
j=1 ; l=0 
while [[ $j -lt "${#USB_MAP[*]}" ]]; do
    if [[ "${USB_REMORT_PROJ[*]}" =~ "${USB_MAP[$j-1]}" ]]; then
        i=1 ; k=0
        while [[ $i -lt "${#USB_RLISTEL[*]}" ]]; do
            if [[ "${USB_RLISTEL[$i]}" = "${USB_MAP[$j]}" && "${USB_RLISTEL[$i-1]}" = "${USB_MAP[$j-1]}" ]]; then
                k=1
            fi
            let i+=1
        done
        if [ $k -eq 0 ]; then
            USB_MAP_UEFF[$l]="${USB_MAP[$j]}"; USB_MAP_UID[$l]="${USB_MAP[$j-1]}"
            let MAP_UEFF_HANG[$l]="$j+1"   # 数组USB_MAP是从0开始计数，而MAP_UEFF_HANG是sed要删除的行，从1开始计数，所以要加上1
            let l+=1
        fi
    fi
    let j+=2
done
# 处理删除、新建、列出、克隆
USB_LIST_X(){
    echo "U盘仓库列表: "
    i=1; k=0
    while [[ $i -lt ${#USB_RLIST[*]} ]]; do
        let k+=1
        echo "[$k] ${USB_RLIST[$i]}"
        let i+=2
    done
}
# 新的列出程序
# ==============================================
DY_SET_SIZE(){
    TTY_H=$(stty size|awk '{print $1}')
    TTY_W=$(stty size|awk '{print $2}')
}
DY_SET_SIZE
DY_LINE="-"
DY_TAG=":: "
let TTY_H-=2
i=1; j=$TTY_H
ListDo=one
TLS_CAS(){
    DY_SET_SIZE
    case "$ListDo" in
        s)
            echo -n " [选择] "; read TLS_SNum
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
                echo [$i] ${IFO[$i-1]}
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
            echo [$i] ${IFO[$i-1]}
            let i+=1
        done
    fi
    DY_MKLINE
    echo ""
    echo -n "[s] 选择 [j] 下翻 [k] 上翻 [q] 退出 "
    read -s -n 1 ListDo
    TLS_CAS
}
TLS_CAS_SUB(){
    DY_SET_SIZE
    case "$TLS_SNum" in 
        q)
            exit 
            ;;
        s)
            echo -n " [选择] "; read TLS_SNum
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
            ;;
        *)
            read -s -n 1 TLS_SNum
            TLS_CAS_SUB
            ;;
    esac
}
DY_LIST(){
    DY_SET_SIZE
    if [ ${#IFO[*]} -lt $TTY_H ]; then
        while [ $i -le ${#IFO[*]} ]; do
            echo [$i] ${IFO[$i-1]}
            let i+=1
        done
        l=0
        while [ $l -lt $TTY_W ]; do 
            echo -n "$DY_LINE"
            let l+=1
        done
        echo ""
        echo -n "[s] 选择 [q] 退出 " ; read -s -n 1 TLS_SNum
        TLS_CAS_SUB
    else
        TLS
    fi
}
#==============================帮助菜单================================
USB_MENU=""$USB_MENU" ugit $USB_VERSION                            \n"
USB_MENU=""$USB_MENU"+---------------------------------------------+\n"
USB_MENU=""$USB_MENU"|用法：ugit  [选项]                           |\n"
USB_MENU=""$USB_MENU"|---------------------------------------------|\n"
USB_MENU=""$USB_MENU"|ugit.sh -i --install       |            安装 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -a --all           |    U盘 ==> 本地 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -b --backup        |本地--> U盘+网络 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -c --clone         |本地<-- U盘      |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -h --help          |            帮助 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -l                 |    列出本地仓库 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -ll --listlocal    |    列出本地仓库 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -lr --listremote   |     列出U盘仓库 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -n                 |        新建仓库 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -p --pull          |    本地--> 网络 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -r --remove        |     删除U盘仓库 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -s --sync          |本地<->U盘<->网络|\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -u --update        |    联网升级软件 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -v --version       |            版本 |\n"
USB_MENU=""$USB_MENU"+---------------------------------------------+\n"
USB_HELP(){
    echo  -e "$USB_MENU" |less
}
if [ $# -gt 0 ]; then
    if [ $1 == "-l" -o $1 == "-ll" -o $1 == "-LL" -o $1 == "--listlocal" -o $1 == "--LISTLOCAL" ]; then
        IFO=(${USB_MAP_EFF[*]})  # 默认设置为列出本地已经配置的仓库
        DY_LIST
    elif [ $1 == "-u" -o $1 == "-U" -o $1 == "--update" -o $1 == "--UPDATE" ]; then
        sudo curl -o /usr/local/bin/ugit https://gitlab.com/fengzhenhua/script/-/raw/usbmain/xugit.sh\?inline\=false 
        sudo chmod +x /usr/local/bin/ugit
        echo "通过https://gitlab.com/fengzhenhua/script 升级版本${USB_VERSION}!"
    elif [ $1 == "-lr" -o $1 == "-LR" -o $1 == "--listremote" -o $1 == "--LISTREMOTE" ]; then
        IFO=(${USB_RLI_EFF[*]})  # 默认设置为列出本地已经配置的仓库
        DY_LIST
    elif [ $1 == "-v" -o $1 == "-V" -o $1 == "--version" -o $1 == "--VERSION" ]; then
        echo $USB_VERSION
    elif [ $1 == "-h" -o $1 == "-H" -o $1 == "--help" -o $1 == "--HELP" ]; then
        USB_HELP
    elif [ $1 == "-ad" -o $1 == "-addremote" -o $1 == "--AD" -o $1 == "--ADDREMOTE" ]; then
        if [[ "${USB_MAP[*]}" =~ "$PWD" ]]; then
            i=2 ; k=${#USB_RCF[*]} ; let k=k-2 ; j=0
            USB_RNA=${PWD##*/}
            USB_RNAC=($(cat $USB_SCFG))
            while [ $i -lt $k ]; do
                let i+=2 ; let j+=1
                if [[ ! "${USB_RNAC[@]}" =~ "[remote \"${USB_RCF[$i-1]}\"]" ]]; then
                    echo "[remote \"${USB_RCF[$i-1]}\"]" >> $USB_SCFG
                    echo "	url = ${USB_RCF[$i]}/$USB_RNA" >> $USB_SCFG
                    echo "	fetch = +refs/heads/*:refs/remotes/${USB_RCF[$i-1]}/*" >> $USB_SCFG
                    echo "[$j] $PWD <==> ${USB_RCF[$i-1]} 关联成功 ! "
                else
                    echo "[$j] $PWD <--> ${USB_RCF[$i-1]} 已经关联, 勿需重复操作! "
                fi
            done
        else
            echo "远程仓库添加失败，$PWD 不是标准的U盘仓库克隆路径!"
        fi
    elif [ $1 == "-a" -o $1 == "-A" -o $1 == "--all" -o $1 == "--ALL" ]; then
        i=0; k=1
        while [[ $i -lt "${#USB_MAPRLI_UEFF[*]}" ]]; do
            if [ ! -e "${USB_MAPRLI_UEFF[$i]%/*}" ]; then
                mkdir -p "${USB_MAPRLI_UEFF[$i]%/*}"
            fi
            if [ ! -e ${USB_MAPRLI_UEFF[$i]} ]; then
                git clone "${USB_RLI_UEFF[$i]}" "${USB_MAPRLI_UEFF[$i]}" &> /dev/null
                echo "[$k] ${USB_MAPRLI_UEFF[$i]} <== ${USB_RLI_UEFF[$i]} 成功!"
                echo "${USB_MAPRLI_UID[$i]}" >> $USB_MAP_CFG
                echo "${USB_MAPRLI_UEFF[$i]}" >> $USB_MAP_CFG
                let k+=1
            fi
            let i+=1
        done
        if [ $k -gt 1 ]; then
            echo "本地 <== U盘 成功!"
        else
            echo "本地 <==> U盘，无需克隆!"
        fi
    elif [ $1 == "-b" -o $1 == "-B" -o $1 == "--backup" -o $1 == "--BACKUP" ]; then
        i=0
        while [[ $i -lt ${#USB_MAP_EFF[*]} ]]; do
            cd ${USB_MAP_EFF[$i]}
            git pull &> /dev/null
            let i+=1
            echo "[$i] ${USB_MAP_EFF[$i-1]} 本地<--U盘 成功!"
        done
    elif [ $1 == "-p" -o $1 == "-P" -o $1 == "--push" -o $1 == "--PUSH" ]; then
        i=0
        while [[ $i -lt ${#USB_MAP_EFF[*]} ]]; do
            cd ${USB_MAP_EFF[$i]}
            git add . &> /dev/null
            git commit -m "$USB_COMMENT" &> /dev/null
            git push  &> /dev/null
            let i+=1
            echo "[$i] ${USB_MAP_EFF[$i-1]} 本地-->U盘 成功!"
        done
        k=$i
        if [ -e $USB_RCFG -a -e "$USB_SCFG" ]; then 
            ret_code=`curl -I -s --connect-timeout ${timeout} ${target} -w %{http_code} | tail -n1`
            if [ "x$ret_code" = "x200" ]; then
                i=0 
                while [[ $i -lt ${#USB_MAP_EFF[*]} ]]; do
                    cd ${USB_MAP_EFF[$i]}
                    m=0
                    USB_RNAC=($(cat $USB_SCFG))
                    while [ $m -lt ${#USB_RNAC[*]} ]; do
                        let m+=1
                        if [[ "${USB_RNAC[$m]}" =~ "\"]" ]]; then
                            USB_TEMP=${USB_RNAC[$m]}; USB_TEMP=${USB_TEMP#*\"}; USB_TEMP=${USB_TEMP%\"*}
                            if [ ! $USB_TEMP = "origin" -a !  $USB_TEMP = "$USB_BNAME" ]; then
                                git push -f $USB_TEMP &> /dev/null
                                let k+=1
                                echo "[$k] ${USB_MAP_EFF[$i]} --> $USB_TEMP 成功!"
                            fi
                        fi
                    done
                    let i+=1
                done
                echo "本地-->网络 成功 !"
            else
                echo "网络无法联通，暂停同步网络, 请在网络恢复后重试 !"
            fi
        fi
    elif [ $1 == "-r" -o $1 == "-R" -o $1 == "--remove" -o $1 == "--REMOVE" ]; then
        IFO=(${USB_RLI_EFF[*]})
        DY_LIST
        let TLS_SNum-=1
        echo -n "删除USB仓库:${USB_RLI_EFF[$TLS_SNum]} y/n "; read USB_YesNo
        if [ $USB_YesNo = y -o $USB_YesNo = Y -o $USB_YesNo = yes -o $USB_YesNo = YES ]; then
            rm -rf ${USB_RLI_EFF[$TLS_SNum]}
            rm -rf ${USB_MAP_EFF[$TLS_SNum]}
            DEL_NUM=$(grep -n "${USB_MAP_EFF[$TLS_SNum]}" $USB_MAP_CFG |cut -d ":" -f 1)
            sed -i "$DEL_NUM d" $USB_MAP_CFG
            let DEL_NUM-=1
            sed -i "$DEL_NUM d" $USB_MAP_CFG
            echo "仓库 ${USB_RLI_EFF[$TLS_SNum]} 删除成功!"
        else
            echo "删除未执行，正常退出!"
            exit
        fi
    elif [ $1 == "-c" -o $1 == "-C" -o $1 == "--clone" -o $1 == "--CLONE" ]; then
        IFO=(${USB_RLI_EFF[*]})
        DY_LIST
        k=0
        echo "克隆：${USB_MAPRLI_UEFF[$TLS_SNum]} <== ${USB_RLI_UEFF[$TLS_SNum]}"
        if [ ! -e ${USB_MAPRLI_UEFF[$TLS_SNum]} ]; then
            mkdir "${USB_MAPRLI_UEFF[$TLS_SNum]}"
            git clone ${USB_RLI_UEFF[$TLS_SNum]} ${USB_MAPRLI_UEFF[$TLS_SNum]} &> /dev/null
            echo "${USB_MAPRLI_UID_ID[$TLS_SNum]}" >> $USB_MAP_CFG
            echo "${USB_MAPRLI_UEFF[$i]}" >> $USB_MAP_CFG
            k=1
        fi
        if [ $k =1 ]; then
            echo "${USB_MAPRLI_UEFF[$TLS_SNum]} <== ${USB_RLI_UEFF[$TLS_SNum]} 成功!"
        else
            echo "${USB_MAPRLI_UEFF[$TLS_SNum]} 本地已经存在，无需克隆!"
        fi
    elif [ $1 == "-n" -o $1 == "-N" -o $1 == "--new" -o $1 == "--NEW" ]; then
        USB_UPAN=(${USB_UPANP[*]##*/})
        if [[ ${#USB_UPAN[*]} -eq 0 ]]; then
            echo "请插入U盘后再运行程序!"
            exit
        elif [[ ${#USB_UPAN[*]} -eq 1 ]]; then
            USB_UPANS=1
        else
            j=0
            while [[ $j -lt ${#USB_UPAN[*]} ]]; do
                let j+=1
                echo "[$j] ${USB_UPAN[$j-1]}"
            done
            echo -n "请选择U盘 "; read USB_UPANS  # 追加数字判断，后面升级时用
        fi
        USB_UPAN_FIL=($(ls ${USB_UPANP[$USB_UPANS-1]}))
        i=0
        while [[ $i -lt ${#USB_UPAN_FIL[*]} ]]; do
            let i+=1
            echo "[$i] ${USB_UPAN[$USB_UPANS-1]}/${USB_UPAN_FIL[$i-1]}"
        done
        echo -n "请输入新的仓库名: "; read SFNum
        if [[ ${USB_RLIST[*]} =~ "${USB_UPAN[$USB_UPANS-1]}/${SFNum}.git" ]]; then
            echo "$SFNum 已经存在，请重新选择仓库名!"
        else
            USB_OUT_REM="/run/media/$USER/${USB_UPAN[$USB_UPANS-1]}/${SFNum}.git"
            mkdir $USB_OUT_REM
            cd $USB_OUT_REM
            git init --bare --quiet &> /dev/null
            git branch -m $USB_BNAME &> /dev/null
            ugit -a
            cd "$HOME/${USB_UPAN[$USB_UPANS-1]}$USB_TAG/${SFNum##*/}"
            touch README.md
            chmod +x README.md
            echo "$(date) created by ugit" > ./README.md
            echo "$USB_OUT_REM" >> ./README.md
            git add . &> /dev/null
            git commit -m "initial" &> /dev/null 
            git push &> /dev/null
            echo "U盘仓库[$SFNum]已经配置完毕！"
        fi
    elif [ $1 == "-s" -o $1 == "-S" -o $1 == "--sync" -o $1 == "--SYNC" ]; then
        if [[ "${#USB_MAP_UEFF[*]}" -gt 0 ]]; then
            i="${#USB_MAP_UEFF[*]}"                       # 删除文件夹到回收站, 这样可以找回文件
            while [[ $i -ge  1 ]]; do
                if [ -e ${USB_MAP_UEFF[$i-1]} ]; then 
                    mv  -t ~/.local/share/Trash/files --backup=t ${USB_MAP_UEFF[$i-1]}
                fi
                let DEL_NUM="${MAP_UEFF_HANG[$i-1]}"
                sed -i "$DEL_NUM d" $USB_MAP_CFG
                let DEL_NUM-=1
                sed -i "$DEL_NUM d" $USB_MAP_CFG
                echo "[$i] ${USB_MAP_UEFF[$i-1]} ==> 回收站 成功!"
                let i-=1
            done
        fi
        ugit -a
        ugit -b
        ugit -p
    else
        echo "输入错误，请参考使用说明："
        echo  -e "$USB_MENU"
    fi
fi
