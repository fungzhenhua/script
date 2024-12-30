#! /bin/sh
#
# Program  : ugit.sh
# Version  : V2.1
# Date     : 2024-04-19 08:59
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2024 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
# History  : V1.6 增加联网更新，以Gitlab仓库为源
#            V1.7 增加选项-b, 工作完成，全部仓库上载U盘
#            V1.8 优化删除和建立仓库
#            V1.9 增加选项-ad 配置联网仓库, -p 同步U盘和网络仓库
#            V2.0 增加网络联通判断，实现-b项，全面同步
#            V2.1 增加帮助菜单, 去除bug
#
USB_VERSION=V2.1
# 超时时间
timeout=1
# 目标网站
target=www.baidu.com
USB_MAP_CFG=~/.ugitmap
USB_RCFG=~/.ugitrcf
USB_SCFG=.git/config
USB_BNAME=usbmain # branch name
if [ ! -e $USB_MAP_CFG ]; then 
    touch $USB_MAP_CFG
    chmod +w $USB_MAP_CFG
fi
if [ ! -e $USB_RCFG ]; then
    touch $USB_RCFG
    chmod +w $USB_RCFG
    echo "exampal: " > $USB_RCFG
    echo "gitee::https://github.com/project.git" >> $USB_RCFG
fi
USB_EXE=/usr/local/bin/ugit
# 安装脚本到系统目录
if [ $# -gt 0 ]; then
    if [ $1 == "-i" -o $1 == "-I" -o $1 == "--install" -o $1 == "--INSTALL" ]; then
        sudo cp -f $0 $USB_EXE
        sudo chmod 755 $USB_EXE
        echo "ugit成功安装到: $USB_EXE"
        exit
    elif [ $1 == "-u" -o $1 == "-U" -o $1 == "--update" -o $1 == "--UPDATE" ]; then
        sudo curl -o /usr/local/bin/ugit https://gitlab.com/fengzhenhua/script/-/raw/usbmain/xugit.sh\?inline\=false 
        sudo chmod +x /usr/local/bin/ugit
        echo "通过https://gitlab.com/fengzhenhua/script 升级完成!"
    fi
fi
# 检测是否插入U盘，插入则建立U盘内容列表
USB_MAP=($(cat $USB_MAP_CFG))
USB_RCF=($(cat $USB_RCFG))
USB_MAPED=(${USB_MAP[*]##*/})
USB_REMORT="/run/media/$USER" # udisks2 默认u盘挂载点
USB_PC_PATH=$PWD
if [ -e $USB_REMORT ]; then
    USB_ARR=($(ls $USB_REMORT/))
else
    exit
fi
# 选择目标U盘
if [ ${#USB_ARR[*]} -eq 0 ]; then
    echo "未检测到U盘，请插入U盘!"
    exit
else  # 获取多个U盘的uuid和相应远程U盘地址
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
#=========================帮助菜单=========================
USB_MENU=""$USB_MENU" ugit $USB_VERSION                           \n"
USB_MENU=""$USB_MENU"+--------------------------------------------+\n"
USB_MENU=""$USB_MENU"|用法：ugit  [选项]                          |\n"
USB_MENU=""$USB_MENU"|--------------------------------------------|\n"
USB_MENU=""$USB_MENU"|ugit.sh -i --install       |            安装|\n"
USB_MENU=""$USB_MENU"|--------------------------------------------|\n"
USB_MENU=""$USB_MENU"|        -h --help          |            帮助|\n"
USB_MENU=""$USB_MENU"|--------------------------------------------|\n"
USB_MENU=""$USB_MENU"|        -v --version       |            版本|\n"
USB_MENU=""$USB_MENU"|--------------------------------------------|\n"
USB_MENU=""$USB_MENU"|        -u --update        |    联网升级软件|\n"
USB_MENU=""$USB_MENU"|--------------------------------------------|\n"
USB_MENU=""$USB_MENU"|        -a --all           |    U盘 --> 本地|\n"
USB_MENU=""$USB_MENU"|--------------------------------------------|\n"
USB_MENU=""$USB_MENU"|        -b --backup        |本地--> U盘+网络|\n"
USB_MENU=""$USB_MENU"|--------------------------------------------|\n"
USB_MENU=""$USB_MENU"|        -p --pull          |    本地--> 网络|\n"
USB_MENU=""$USB_MENU"|--------------------------------------------|\n"
USB_MENU=""$USB_MENU"|        -l --list          |     列出U盘仓库|\n"
USB_MENU=""$USB_MENU"|--------------------------------------------|\n"
USB_MENU=""$USB_MENU"|        -r --remove        |     删除U盘仓库|\n"
USB_MENU=""$USB_MENU"+--------------------------------------------+\n"
USB_HELP(){
    echo  -e "$USB_MENU" |less
}
if [ $# -gt 0 ]; then
    if [ $1 == "-l" -o $1 == "-L" -o $1 == "--list" -o $1 == "--LIST" ]; then
        USB_LIST_X
    elif [ $1 == "-v" -o $1 == "-V" -o $1 == "--version" -o $1 == "--VERSION" ]; then
        echo $USB_VERSION
    elif [ $1 == "-h" -o $1 == "-H" -o $1 == "--help" -o $1 == "--HELP" ]; then
        USB_HELP
    elif [ $1 == "-ad" -o $1 == "-addremote" -o $1 == "--AD" -o $1 == "--ADDREMOTE" ]; then
        i=2 ; k=${#USB_RCF[*]} ; let k=k-2 
        USB_RNA=${PWD##*/} ; USB_RNA=${USB_RNA%%@*}
        USB_RNAC=($(cat $USB_SCFG))
        while [ $i -lt $k ]; do
            let i+=2
            if [[ ! "${USB_RNAC[@]}" =~ "[remote \"${USB_RCF[$i-1]}\"]" ]]; then
                echo "[remote \"${USB_RCF[$i-1]}\"]" >> $USB_SCFG
                echo "	url = ${USB_RCF[$i]}/$USB_RNA" >> $USB_SCFG
                echo "	fetch = +refs/heads/*:refs/remotes/${USB_RCF[$i-1]}/*" >> $USB_SCFG
            fi
        done
    elif [ $1 == "-a" -o $1 == "-A" -o $1 == "--all" -o $1 == "--ALL" ]; then
        j=1 ;k=0
        while [[ $i -lt ${#USB_RLIST[*]} ]]; do
            USB_RTEST=${USB_RLIST[$j]%/*}
            USB_RTEST=${USB_RTEST##*/}  # 注意仓库在U盘中的名称以.git结尾
            USB_UHOME="$HOME/${USB_RTEST}@UGIT"
            if [ ! -e  "$USB_UHOME" ]; then
                mkdir $USB_UHOME
            fi
            USB_RTEST_SUB=${USB_RLIST[$j]##*/}
            USB_RTEST_SUB=${USB_RTEST_SUB%%.git*}  # 注意仓库在U盘中的名称以.git结尾
            USB_UHOME_SUB="$USB_UHOME/${USB_RTEST_SUB}"
            let k+=1
            if [ -e "$USB_UHOME_SUB" ]; then
                cd $USB_UHOME_SUB
                git pull  &> /dev/null
                echo "[$k] $USB_UHOME_SUB <-- ${USB_RLIST[$j]} 更新完毕!"
            else
                mkdir $USB_UHOME_SUB
                git clone ${USB_RLIST[$j]} $USB_UHOME_SUB &> /dev/null
                echo "[$k] $USB_UHOME_SUB <== ${USB_RLIST[$j]} 克隆完毕!"
                if [[ ! "${USB_MAP[*]}" =~ "$USB_UHOME_SUB" ]]; then
                    echo "${USB_RLIST[$j-1]}" >> $USB_MAP_CFG
                    echo "$USB_UHOME_SUB" >> $USB_MAP_CFG
                fi
            fi
            let j+=2
        done
    elif [ $1 == "-b" -o $1 == "-B" -o $1 == "--backup" -o $1 == "--BACKUP" ]; then
        i=1 ; k=0
        while [ $i -lt ${#USB_MAP[*]} ]; do
            j=1
            while [[ $j -lt ${#USB_RLIST[*]} ]]; do
                USB_RTEST=${USB_RLIST[$j]##*/}
                USB_RTEST=${USB_RTEST%%.git*}       # 注意仓库在U盘中的名称以.git结尾
                if [[ "${USB_MAP[$i]}" =~ "$USB_RTEST" && "${USB_MAP[$i-1]}" = "${USB_RLIST[$j-1]}" ]]; then
                    cd ${USB_MAP[$i]}
                    git pull &> /dev/null
                    let k+=1
                    echo "[$k] ${USB_MAP[$i]}仓库更新完毕!"
                    let k+=1       # 联网同步
                    ugit --@PUSH
                    k=$n
                fi
                let j+=2
            done
            let i+=2
        done
    elif [ $1 == "-p" -o $1 == "-P" -o $1 == "--push" -o $1 == "--@PUSH" ]; then
        if [ -e $USB_RCFG -a -e "$USB_SCFG" ]; then 
            ret_code=`curl -I -s --connect-timeout ${timeout} ${target} -w %{http_code} | tail -n1`
            if [ "x$ret_code" = "x200" ]; then
                m=0 ; 
                if [ $1 == "--@PUSH" ]; then
                    n=$k
                else
                    n=0
                fi
                USB_RNAC=($(cat $USB_SCFG))
                while [ $m -lt ${#USB_RNAC[*]} ]; do
                    let m+=1
                    if [[ "${USB_RNAC[$m]}" =~ "\"]" ]]; then
                        USB_TEMP=${USB_RNAC[$m]}; USB_TEMP=${USB_TEMP#*\"}; USB_TEMP=${USB_TEMP%\"*}
                        if [ ! $USB_TEMP = "origin" -a !  $USB_TEMP = "$USB_BNAME" ]; then
                            git push -f $USB_TEMP &> /dev/null
                            let n+=1
                            echo "[$n] $PWD 成功同步到$USB_TEMP !"
                        fi
                    fi
                done
            else
                echo "网络无法联通，暂停同步网络, 请在网络恢复后重试 !"
            fi
        fi
    elif [ $1 == "-r" -o $1 == "-R" -o $1 == "--remove" -o $1 == "--REMOVE" ]; then
        USB_LIST_X
        echo -n "请输入要删除的USB仓库编号:"; read Rfile
        let Rfile=2*$Rfile ; let Rfile=$Rfile-1
        USB_DEL=${USB_RLIST[$Rfile]}
        echo -n "删除USB仓库:[$USB_DEL] Y/N "; read USB_YesNo
        if [ $USB_YesNo = y -o $USB_YesNo = Y -o $USB_YesNo = yes -o $USB_YesNo = YES ]; then
        i=1 
        while [ $i -lt ${#USB_MAP[*]} ]; do
            USB_RTEST=${USB_DEL##*/}
            USB_RTEST=${USB_DEL%%.git*}       # 注意仓库在U盘中的名称以.git结尾
            if [[ "${USB_MAP[$i]}" =~ "$USB_RTEST" ]]; then
                sed -i "/${USB_MAP[$i]}/d" $USB_MAP_CFG
                sed -i "/${USB_MAP[$i-1]}/d" $USB_MAP_CFG
            fi
            let i+=2
        done
            rm -rf "$USB_DEL"
            echo "仓库[$USB_DEL]删除成功!"
        fi
    elif [ $1 == "-c" -o $1 == "-C" -o $1 == "--clone" -o $1 == "--CLONE" ]; then
        USB_LIST_X
        echo -n "请输入要克隆的USB仓库编号:"; read Rfile
        i=1 ; let Rfile=2*$Rfile ; let Rfile=$Rfile-1
        USB_RTESX=${USB_RLIST[$Rfile]##*/}
        USB_RTESX=${USB_RTESX%%.git*}       # 注意仓库在U盘中的名称以.git结尾
        if [[ "${USB_MAP[*]}" =~ $USB_RTESX ]]; then
            while [ $i -lt ${#USB_MAP[*]} ]; do
                if [[ "${USB_MAP[$i]}" =~ "$USB_RTESX" && "${USB_MAP[$i-1]}" = "${USB_RLIST[$Rfile-1]}" ]]; then
                    cd ${USB_MAP[$i]}
                    git pull &> /dev/null
                    echo "${USB_MAP[$i]} 仓库更新完毕!"
                fi
                let i+=2
            done
        else
            USB_RTEST=${USB_RLIST[$Rfile-1]%/*}
            USB_RTEST=${USB_RTEST##*/}  # 注意仓库在U盘中的名称以.git结尾
            USB_UHOME="$HOME/${USB_RTEST}@UGIT"
            if [ ! -e  "$USB_UHOME" ]; then
                mkdir $USB_UHOME
            fi
            USB_RTEST_SUB=${USB_RLIST[$Rfile]##*/}
            USB_RTEST_SUB=${USB_RTEST_SUB%%.git*}  # 注意仓库在U盘中的名称以.git结尾
            USB_UHOME_SUB="$USB_UHOME/${USB_RTEST_SUB}"
            if [ -e "$USB_UHOME_SUB" ]; then
                mv ${USB_UHOME_SUB} "${USB_UHOME_SUB}.BAK"
            fi
            mkdir $USB_UHOME_SUB
            git clone ${USB_RLIST[$Rfile]} $USB_UHOME_SUB &> /dev/null
            echo "$USB_UHOME_SUB <== ${USB_RLIST[$Rfile]} 克隆完毕!"
            echo "${USB_RLIST[$Rfile-1]}" >> $USB_MAP_CFG
            echo "$USB_UHOME_SUB" >> $USB_MAP_CFG
        fi
    elif [ $1 == "-n" -o $1 == "-N" -o $1 == "--new" -o $1 == "--NEW" ]; then
        USB_LIST_X
        echo -n "请输入新的目标仓库: U盘名/仓库名"; read Sfile
        if [[ ${USB_RLIST[*]} =~ "${Sfile}.git" ]]; then
            echo "$Sfile 已经存在，请重新选择仓库名!"
        else
            USB_OUT_REM="/run/media/$USER/${Sfile}.git"
            mkdir $USB_OUT_REM
            cd $USB_OUT_REM
            git init --bare --quiet &> /dev/null
            git branch -m $USB_BNAME &> /dev/null
            ugit -a
            cd "$HOME/${Sfile%%/*}@UGIT/${Sfile##*/}"
            touch README.md
            chmod +x README.md
            echo "$(date) created by ugit" > ./README.md
            echo "$USB_OUT_REM" >> ./README.md
            git add . &> /dev/null
            git commit -m "initial" &> /dev/null 
            git push &> /dev/null
            echo "U盘仓库[$Sfile]已经配置完毕！"
        fi
    else
        echo "正确选项: 安装[i] 删除[r] 克隆[c] 新建[n]"
    fi
fi
