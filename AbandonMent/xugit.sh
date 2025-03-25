#! /bin/sh
#
# Program  : xugit.sh
# Date     : 2024-06-22 22:08
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2024 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
USB_NAME=ugit ; USB_NAME_SH="xugit.sh" ; USB_BNAME=usbmain
USB_VERSION="${USB_NAME}-V8.0"
USB_MAP_TAG=.ugitmap
USB_RCFG_TAG=.ugitrcf
USB_SCFG=.git/config
USB_TAG="@UGIT"
DY_LINE="-"
USB_EXE="/usr/local/bin/$USB_NAME"
USB_REMORT_SH="$USB_BNAME/$USB_NAME_SH"
unset USB_UPDATE_URLS
USB_UPDATE_URLS[0]=https://gitee.com/fengzhenhua/script/raw/$USB_REMORT_SH\?inline\=false     # 默认升级地址
USB_UPDATE_URLS[1]=https://gitlab.com/fengzhenhua/script/-/raw/$USB_REMORT_SH\?inline\=false  # 备用升级地址
USB_USED=95                                                                                 # U盘使用量阈值(0-100)
USB_DEPENDENT="trash-cli fastfetch curl gawk sed"                                           # 本脚本依赖的程序
USB_TIMEOUT=1                                                                               # curl 最大请求时间
USB_DETECT_URL(){
    if [[ $1 == "" ]]; then
        USB_TARGET=https://gitee.com # 默认检测目标网站
    else
        USB_TARGET=$1
        USB_TARGET_R=$USB_TARGET
        if [[ "$USB_TARGET_R" =~ "//" ]]; then 
            USB_TARGET_R="${USB_TARGET_R#*//}"
            if [[ "$USB_TARGET_R" =~ "/" ]]; then 
                USB_TARGET_R="${USB_TARGET_R#*/}"
                if [[ "$USB_TARGET_R" =~ "/" ]]; then 
                    USB_TARGET_R="${USB_TARGET_R#*/}"
                    if [[ "$USB_TARGET_R" =~ "/" ]]; then 
                        USB_TARGET_R="${USB_TARGET_R#*/}"
                        USB_TARGET="${USB_TARGET%%${USB_TARGET_R}*}"
                    fi
                fi
            fi
        fi
    fi
    USB_RET_CODE=`curl -I -s --connect-timeout ${USB_TIMEOUT} $USB_TARGET -w %{http_code} | tail -n1`
    if [ "x$USB_RET_CODE" = "x200" ]; then
        return 0
    else 
        return 1
    fi
}
# 安装脚本到系统目录
if [[ $# -gt 0 ]]; then
    if [[ $0 =~ ".sh" ]]; then
        if [ $1 == "-i" -o $1 == "-I" -o $1 == "--install" -o $1 == "--INSTALL" ]; then
            sudo pacman --needed --noconfirm -S $USB_DEPENDENT &> /dev/null
            sudo cp -f $0 $USB_EXE
            sudo chmod 755 $USB_EXE
            echo "ugit-${USB_VERSION}成功安装到: $USB_EXE"
            exit
        fi
    else
        if [ $1 == "-u" -o $1 == "-U" -o $1 == "--update" -o $1 == "--UPDATE" ]; then
            sudo pacman --needed --noconfirm -S $USB_DEPENDENT &> /dev/null
            USB_DETECT_URL "${USB_UPDATE_URLS[0]}"
            if [ $? = 0 ]; then
                USB_UPDATE_URL=${USB_UPDATE_URLS[0]}
            else
                USB_UPDATE_URL=${USB_UPDATE_URLS[1]}
            fi
            USB_DETECT_URL "${USB_UPDATE_URL}"
            if [ $? = 0 ]; then
                sudo curl -o $USB_EXE $USB_UPDATE_URL
                sudo chmod +x $USB_EXE
                echo "ugit-${USB_VERSION} 网络升级成功!"
                exit
            fi
        fi
    fi
fi
# 定义默认commit
USB_COMMENT=$(fastfetch |grep Host| awk -F'(' '{print $2}'|awk -F')' '{print $1}')
USB_COMMENT=$(echo $USB_COMMENT | sed 's/ /\-/g')
USB_COMMENT="${USER}@${USB_COMMENT}"
# 检测是否插入U盘，插入则建立U盘内容列表
USB_REMORT="/run/media/$USER" # udisks2 默认u盘挂载点
unset USB_ARR
if [ -e $USB_REMORT ]; then
    USB_ARR=($(ls "$USB_REMORT/"))
fi
if [[ "${#USB_ARR[*]}" -eq 0 ]]; then
    echo "${USB_VERSION} 未检测到U盘， 请插入U盘后重试!"
    exit
fi
USB_GET_MAP(){
    unset USB_LOCAL_MAP; unset USB_REMORT_MAP
    USB_LOCAL_MAP=($(ls ${USB_LOCAL_DIR}))
    USB_LOCAL_MAP=($(echo ${USB_LOCAL_MAP[@]/#/"$USB_LOCAL_DIR/"}))
    USB_REMORT_MAP=($(ls ${USB_REMORT_DIR}|grep ".git"))  #仅识别后缀.git的文件夹为git仓库
    USB_REMORT_MAP=($(echo ${USB_REMORT_MAP[@]/#/"$USB_REMORT_DIR/"}))
}
unset USB_REMORT_MAP_ALL; unset USB_LOCAL_MAP_ALL
# 检测U盘使用量，超过阈值给出提示
USB_PAN_INFO=($(lsblk -P -o MOUNTPOINT,ID,FSAVAIL,FSUSE%|grep "/run/media"))
i=0
while [[ $i -lt "${#USB_PAN_INFO[*]}" ]]; do
    USB_PAN_USE="${USB_PAN_INFO[$i+3]#*\"}"
    USB_PAN_NAM="${USB_PAN_INFO[$i]##*/}"   ; USB_PAN_NAM="${USB_PAN_NAM%\"*}"
    USB_PAN_ID="${USB_PAN_INFO[$i+1]#*\"}"  ; USB_PAN_ID="${USB_PAN_ID%%_*}"
    USB_PAN_AVA="${USB_PAN_INFO[$i+2]#*\"}" ; USB_PAN_AVA="${USB_PAN_AVA%\"*}"
    if [[ "${USB_PAN_USE%%\%*}" -gt $USB_USED ]]; then
        echo  "U盘${USB_PAN_NAM}($USB_PAN_ID) 已用${USB_PAN_USE%\"*} 剩余${USB_PAN_AVA} , 容量即将耗尽!!"
    fi
    let i+=4
done
# 获取多个U盘的uuid和相应远程U盘地址
USB_UPANP=($(lsblk -o UUID,MOUNTPOINT | grep "/run/media/"))
USB_LOCAL_UUID=($(lsblk -o UUID,MOUNTPOINT |grep "/home"))
i=0 # U盘仓库建立映射表
while [[ $i -lt "${#USB_UPANP[*]}" ]]; do
    # 定位到第i号U盘
    if [[ $(ls "${USB_UPANP[$i+1]}") =~ ".git" ]]; then
        USB_REMORT_DIR="${USB_UPANP[$i+1]}"
        # 建立U盘配置文件，并写入UUID
        USB_UPAN_M="${USB_REMORT_DIR}/$USB_MAP_TAG"
        if [ ! -e "${USB_UPAN_M}" ]; then
            touch "${USB_UPAN_M}"
            echo "${USB_UPANP[$i]}" > "${USB_UPAN_M}"
            echo "${USB_REMORT_DIR##*/}" >> "${USB_UPAN_M}"
        fi
        unset USB_RPROJ
        USB_RPROJ=($(cat "$USB_UPAN_M"))
        if [[ ! "${USB_RPROJ[*]}" =~ "${USB_LOCAL_UUID[0]}" ]]; then
            USB_LOCAL_DIR="$HOME/${USB_REMORT_DIR##*/}$USB_TAG"
            if [[ ! -e "$USB_LOCAL_DIR" ]]; then
                mkdir "$USB_LOCAL_DIR"
            fi
            USB_LOCAL_ID=($(ls -li "${USB_LOCAL_DIR%/*}" | grep "${USB_LOCAL_DIR##*/}" ))
            echo "${USB_LOCAL_UUID[0]}" >> "${USB_UPAN_M}"
            echo "${USB_LOCAL_DIR}" >> "${USB_UPAN_M}"
            echo "${USB_LOCAL_ID[0]}" >> "${USB_UPAN_M}"
        fi
        j=0 ; # 定位到第j个U盘
        while [[ $j -lt "${#USB_RPROJ[*]}" ]]; do
            # 取得本地仓库, 定位到要操作的U盘
            if [[ "${USB_RPROJ[$j]}" == "${USB_LOCAL_UUID[0]}" ]]; then
                USB_LOCAL_DIR="${USB_RPROJ[$j+1]}"
                let USB_NUM=$j+2
                if [[ ! -e  "$USB_LOCAL_DIR" ]]; then
                    USB_LOCAL_DIR="$(find "${USB_LOCAL_UUID[1]}/$USER" -inum "${USB_RPROJ[$USB_NUM]}")"
                    if [[ -e  "$USB_LOCAL_DIR" ]]; then
                        echo "仓库${USB_RPROJ[$j+1]}丢失，恢复成功！"
                        mv "$USB_LOCAL_DIR" "${USB_RPROJ[$j+1]}"
                    fi
                    USB_LOCAL_DIR="${USB_RPROJ[$j+1]}"
                fi
                if [[ ! -e  "$USB_LOCAL_DIR" ]]; then
                    mkdir "$USB_LOCAL_DIR"
                    sed -i "${USB_NUM}s?.*?$USB_LOCAL_DIR?g" "${USB_UPAN_M}"  &> /dev/null
                    USB_LOCAL_ID=($(ls -li "${USB_LOCAL_DIR%/*}" | grep "${USB_LOCAL_DIR##*/}" ))
                    let USB_NUM+=1
                    sed -i "${USB_NUM}s?.*?${USB_LOCAL_ID[0]}?g" "${USB_UPAN_M}" &> /dev/null
                fi
                USB_GET_MAP
                # 校准U盘名称, 同时校准本地仓库配置远程地址
                if [[ ! "${USB_REMORT_DIR##*/}" == "${USB_RPROJ[1]}" ]]; then
                    sed -i "2s?.*?${USB_REMORT_DIR##*/}?g" "${USB_UPAN_M}"
                    k=0
                    while [[ $k -lt "${#USB_LOCAL_MAP[*]}" ]]; do
                        sed -i "s?/$USER/${USB_RPROJ[1]}/?/$USER/${USB_REMORT_DIR##*/}/?g" \
                            "${USB_LOCAL_MAP[$k]}/$USB_SCFG"
                        let k+=1
                    done
                fi
                # 清理本地多余仓库到回收站
                k=0
                while [[ $k -lt "${#USB_LOCAL_MAP[*]}" ]]; do
                    if [[ ! "${USB_REMORT_MAP[*]##*/}" =~ "${USB_LOCAL_MAP[$k]##*/}.git" ]]; then
                        trash-put "${USB_LOCAL_MAP[$k]}"
                    fi
                    let k+=1
                done
                # 克隆远程仓库存在但本地缺失的仓库,2024-06-22可以考虑使用集合重新实现
                k=0
                while [[ $k -lt "${#USB_REMORT_MAP[*]}" ]]; do
                    USB_TEMP="${USB_REMORT_MAP[$k]##*/}"
                    USB_CLONE_DIR="$USB_LOCAL_DIR/${USB_TEMP%.git}"
                    if [[ ! "${USB_LOCAL_MAP[*]}" =~ "$USB_CLONE_DIR" ]]; then
                        if [ ! -e "$USB_CLONE_DIR" ]; then
                            git clone "${USB_REMORT_MAP[$k]}" "$USB_CLONE_DIR" &> /dev/null
                        fi
                    fi
                    let k+=1
                done
                USB_GET_MAP
                USB_LOCAL_MAP_ALL+=(${USB_LOCAL_MAP[*]})
                USB_REMORT_MAP_ALL+=(${USB_REMORT_MAP[*]})
            fi
            let j+=1
        done
    fi
    let i+=2
done
let i="${#USB_LOCAL_MAP_ALL[*]}"; let j="${#USB_REMORT_MAP_ALL[*]}"
let USB_LOCAL_WNUM=${#i}        ; let USB_REMORT_WNUM=${#j}
# 列表程序
DY_SET_SIZE(){
    TTY_H=$(stty size|awk '{print $1}')
    let TTY_H-=2
    TTY_W=$(stty size|awk '{print $2}')
}
DY_SET_SIZE
# 2024年05月26日 引入全新列表程序
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
NEO_PUSH(){
    cd $1
    git add . &> /dev/null
    git commit -m "$USB_COMMENT" &> /dev/null
    git push  &> /dev/null
}
# 逐次展开程序
NEO_NVIM_LS=(tex md py sh lua yml json h c hpp \
    hxx cc cpp cxx c++ java class toc aux dtx txt)
#
NEO_EDIT(){
    EDFILE=$1
    while [[ -d "$EDFILE" ]]; do
        unset NEO_DIRX ; unset NEO_DIRXX
        NEO_DIRX=($(ls $EDFILE))
        i=0
        while [[ $i -lt "${#NEO_DIRX[*]}" ]]; do
            NEO_DIRXX[$i]="${EDFILE}/${NEO_DIRX[$i]}"
            let i+=1
        done
        if [[ "${NEO_DIRXX[$i-1]%/*}" =~ "${USB_TAG}" ]]; then
            NEO_DIRXX[$i]="${NEO_DIRXX[$i-1]%/*}"
        fi
        if [[ "${NEO_DIRXX[$i]##*${USB_TAG}}" = "" ]]; then
            unset NEO_DIRXX[$i]
        else
            NEO_DIRXX[$i]="${NEO_DIRXX[$i]%/*}"
        fi
        NEO_LIST "${NEO_DIRXX[*]}" 1
    done
    if [[ "${NEO_NVIM_LS[*]}" =~ "${EDFILE##*.}" ]]; then
        cd ${EDFILE%/*}
        nvim $EDFILE
        NEO_PUSH ${EDFILE%/*}
    else
        xdg-open $EDFILE  &> /dev/null
    fi
}
#==============================帮助菜单================================
USB_MENU=""$USB_MENU" ugit $USB_VERSION                            \n"
USB_MENU=""$USB_MENU"+---------------------------------------------+\n"
USB_MENU=""$USB_MENU"|用法：ugit  [选项]                           |\n"
USB_MENU=""$USB_MENU"|---------------------------------------------|\n"
USB_MENU=""$USB_MENU"|ugit.sh -i --install       |            安装 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -h --help          |            帮助 |\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -l                 |列出本地仓库/编辑|\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -n                 |         新建仓库|\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        -ad                |     关联远程仓库|\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        --pull             |    本地 <-- 远程|\n"
USB_MENU=""$USB_MENU"|---------------------------+-----------------|\n"
USB_MENU=""$USB_MENU"|        --push             |    本地 ==> 远程|\n"
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
    if [ $1 == "-l" -o $1 == "--list" -o $1 == "--LIST" ]; then
        NEO_LIST "${USB_LOCAL_MAP_ALL[*]}" 1  # 默认设置为列出远程已经配置的仓库
        NEO_EDIT $EDFILE
    elif [ $1 == "-v" -o $1 == "-V" -o $1 == "--version" -o $1 == "--VERSION" ]; then
        echo "${USB_VERSION}"
    elif [ $1 == "-h" -o $1 == "-H" -o $1 == "--help" -o $1 == "--HELP" ]; then
        USB_HELP
    elif [ $1 == "-ad" -o $1 == "-addremote" -o $1 == "--AD" -o $1 == "--ADDREMOTE" ]; then
        if [[ "${USB_LOCAL_MAP_ALL[*]}" =~ "$PWD" ]]; then
            # 修改为配置文件存储到U盘中
            USB_RCFG="${PWD%"$USB_TAG"*}"
            USB_RCFG="${USB_RCFG##*/}"
            USB_RCFG="/run/media/$USER/$USB_RCFG/$USB_RCFG_TAG"
            if [ ! -e $USB_RCFG ]; then
                touch $USB_RCFG
                chmod +w $USB_RCFG
                echo "example: " > $USB_RCFG
                echo "gitee https://github.com/project.git" >> $USB_RCFG
                nvim $USB_RCFG
            fi
            USB_RCF=($(cat $USB_RCFG))
            i=2 ; k=${#USB_RCF[*]} ; let k=k-2 ; j=0
            USB_RNA=${PWD##*/}
            USB_RNAC=($(cat "$PWD/$USB_SCFG"))
            while [ $i -lt $k ]; do
                let i+=2 ; let j+=1
                if [[ ! "${USB_RNAC[@]}" =~ "[remote \"${USB_RCF[$i-1]}\"]" ]]; then
                    echo "[remote \"${USB_RCF[$i-1]}\"]" >> $USB_SCFG
                    echo "	url = ${USB_RCF[$i]}/$USB_RNA" >> $USB_SCFG
                    echo "	fetch = +refs/heads/*:refs/remotes/${USB_RCF[$i-1]}/*" >> $USB_SCFG
                    echo "[$j] $PWD <==> ${USB_RCF[$i-1]} 关联成功 !"
                else
                    echo "[$j] $PWD <--> ${USB_RCF[$i-1]} 已经关联 !"
                fi
            done
        else
            echo "远程仓库添加失败，$PWD 不是标准的U盘仓库克隆路径!"
        fi
    elif [ $1 == "-pull" -o $1 == "--pull" -o $1 == "-PULL" -o $1 == "--PULL" ]; then
        i=0
        while [[ $i -lt ${#USB_LOCAL_MAP_ALL[*]} ]]; do
            cd ${USB_LOCAL_MAP_ALL[$i]}
            git pull &> /dev/null
            let i+=1
            printf "[%0${USB_LOCAL_WNUM}d] %-6s ---\u2b9a %s \n" \
                "$i" "U-DISK" "${USB_LOCAL_MAP_ALL[$i-1]}"
        done
    elif [ $1 == "-push" -o $1 == "-PUSH" -o $1 == "--push" -o $1 == "--PUSH" ]; then
        i=0 ; k=0
        while [[ $i -lt ${#USB_LOCAL_MAP_ALL[*]} ]]; do
            NEO_PUSH ${USB_LOCAL_MAP_ALL[$i]}
            let i+=1
            printf "[%0${USB_LOCAL_WNUM}d] %-6s \u2b98--- %s \n" \
                "$i" "U-DISK" "${USB_LOCAL_MAP_ALL[$i-1]}" 
            m=0
            USB_RNAC=($(cat $USB_SCFG))
            while [ $m -lt ${#USB_RNAC[*]} ]; do
                let m+=1
                if [[ "${USB_RNAC[$m]}" =~ "\"]" ]]; then
                    USB_TEMP=${USB_RNAC[$m]}; USB_TEMP=${USB_TEMP#*\"}; USB_TEMP=${USB_TEMP%\"*}
                    if [ ! $USB_TEMP = "origin" -a !  $USB_TEMP = "$USB_BNAME" ]; then
                        if [[ "${USB_RNAC[$m+3]}" =~ ":" ]]; then
                            if [[ "${USB_RNAC[$m+3]}" =~ "gitee" ]]; then
                                USB_TEMP_URL="https://gitee.com/${USB_RNAC[$m+3]##*:}"
                            elif [[ "${USB_RNAC[$m+3]}" =~ "gitlab" ]]; then
                                USB_TEMP_URL="https://gitlab.com/${USB_RNAC[$m+3]##*:}"
                            elif [[ "${USB_RNAC[$m+3]}" =~ "github" ]]; then
                                USB_TEMP_URL="https://github.com/${USB_RNAC[$m+3]##*:}"
                            fi
                        else
                            USB_TEMP_URL="${USB_RNAC[$m+3]}"
                        fi
                        USB_DETECT_URL "$USB_TEMP_URL"
                        let k+=1
                        if [ $? = 0 ]; then
                            git push -f $USB_TEMP &> /dev/null
                            printf " %${USB_LOCAL_WNUM}s) %-6s \u2b98--- %s \n" \
                                "$k" "$USB_TEMP" "${USB_LOCAL_MAP_ALL[$i-1]}"
                        else
                            printf " %${USB_LOCAL_WNUM}s) %-6s \u2b98-\033[5mx\033[0m- %s \n" \
                                "$k" "$USB_TEMP" "${USB_LOCAL_MAP_ALL[$i-1]}"
                        fi
                    fi
                fi
            done
        done
    elif [ $1 == "-r" -o $1 == "-R" -o $1 == "--remove" -o $1 == "--REMOVE" ]; then
        NEO_LIST "${USB_REMORT_MAP_ALL[*]}" 1
        echo  -ne "\r[s] 删除USB仓库:${EDFILE} y/n : "; read USB_YesNo
        if [ $USB_YesNo = y -o $USB_YesNo = Y -o $USB_YesNo = yes -o $USB_YesNo = YES ]; then
            if [[ -e "${EDFILE}" ]]; then
                rm -rf "${EDFILE}"
            fi
            USB_TEMP="${EDFILE%/*}"
            USB_TEMP="$HOME/${USB_TEMP##*/}$USB_TAG"
            USB_TEMP="$USB_TEMP/${EDFILE##*/}"
            USB_TEMP="${USB_TEMP%.git*}"
            if [[ -e "$USB_TEMP" ]]; then
                rm -rf "$USB_TEMP"
            fi
            echo "仓库 ${EDFILE} 删除成功!"
        else
            echo "删除未执行，正常退出!"
            exit
        fi
    elif [ $1 == "-n" -o $1 == "-N" -o $1 == "--new" -o $1 == "--NEW" ]; then
        USB_UPAN=(${USB_UPANP[*]##*/})
        i=1; k=0 ; unset USB_UPAN
        while [[ $i -le "${#USB_UPANP[*]}" ]]; do
            USB_UPAN[$k]="${USB_UPANP[$i]}"
            let i+=2 ; let k+=1
        done
        if [[ ${#USB_UPAN[*]} -eq 1 ]]; then
            USB_UPANS=1
        else
            j=0
            while [[ $j -lt ${#USB_UPAN[*]} ]]; do
                let j+=1
                echo "[$j] ${USB_UPAN[$j-1]}"
            done
            echo -n "请选择U盘 "; read USB_UPANS  # 追加数字判断，后面升级时用
            expr "$USB_UPANS" + 1 &> /dev/null
            if [ $? -eq 0 ]; then
                if [ 0 -ge $USB_UPANS -o $USB_UPANS -gt  ${#USB_UPAN[*]} ]; then
                    echo "编号超出范围，请重新选择编号！"
                    exit
                fi
            else
                echo "输入非数字，请重新输入编号！"
                exit
            fi
        fi
        USB_UPAN_FILX=($(ls "${USB_UPAN[$USB_UPANS-1]}"))
        i=0 ; k=0
        while [[ $i -lt "${#USB_UPAN_FILX[*]}" ]]; do
            if [[ "${USB_UPAN_FILX[$i]}" =~ ".git" ]]; then
                USB_UPAN_FIL[$k]="${USB_UPAN_FILX[$i]}"
                let k+=1
            fi
            let i+=1
        done
        i=0
        while [[ $i -lt ${#USB_UPAN_FIL[*]} ]]; do
            let i+=1
            echo "[$i] ${USB_UPAN[$USB_UPANS-1]}/${USB_UPAN_FIL[$i-1]}"
        done
        DY_MKLINE
        echo -n "请输入新的仓库名: "; read SFNum
        if [[ "${USB_REMORT_MAP[*]}" =~ "${USB_UPAN[$USB_UPANS-1]}/${SFNum}.git" ]]; then
            echo "$SFNum 已经存在，请重新命名!"
        else
            USB_OUT_REM="${USB_UPAN[$USB_UPANS-1]}/${SFNum}.git"
            mkdir $USB_OUT_REM
            cd $USB_OUT_REM
            git init --bare --quiet &> /dev/null
            git branch -m $USB_BNAME &> /dev/null
            USB_TEMP="$HOME/${USB_UPAN[$USB_UPANS-1]##*/}$USB_TAG"
            if [ ! -e $USB_TEMP ]; then
                mkdir $USB_TEMP
            fi
            git clone $USB_OUT_REM "$USB_TEMP/${SFNum##*/}"  &> /dev/null
            cd "$USB_TEMP/${SFNum##*/}"
            touch README.md
            chmod +x README.md
            echo "$(date) created by ugit" > ./README.md
            echo "$USB_OUT_REM" >> ./README.md
            git add . &> /dev/null
            git commit -m "initial" &> /dev/null 
            git push &> /dev/null
            echo "U盘仓库[$SFNum]配置成功！"
        fi
    elif [ $1 == "-s" -o $1 == "-S" -o $1 == "--sync" -o $1 == "--SYNC" ]; then
        ugit --pull
        DY_MKLINE
        ugit --push
    fi
else
    ugit --sync
fi
