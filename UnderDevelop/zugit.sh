#! /bin/sh
#
# Program  : zugit.sh
# Date     : 2024-12-04 21:50
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2024 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
USB_NAME=ugit ; USB_NAME_SH="zugit.sh" ; USB_BNAME=usbmain
USB_VERSION="${USB_NAME}-V10.6"
USB_REGISTER=".uregister"
USB_RCFG_TAG=".ugitrcf"
USB_SCFG=.git/config
USB_REL_CFG=".ugitrelocate"
USB_TAG="@UGIT"
DY_LINE="\u2584"
NEO_FORMAT="44;39"
USB_EXE="/usr/local/bin/$USB_NAME"
USB_REMORT_SH="$USB_BNAME/$USB_NAME_SH"
unset USB_UPDATE_URLS
USB_UPDATE_URLS[0]=https://gitee.com/fengzhenhua/script/raw/$USB_REMORT_SH\?inline\=false     # 默认升级地址
USB_UPDATE_URLS[1]=https://gitlab.com/fengzhenhua/script/-/raw/$USB_REMORT_SH\?inline\=false  # 备用升级地址
USB_USED=95                                                                                   # U盘使用量阈值(0-100)
USB_DEPENDENT="trash-cli curl gawk sed grep"                                        # 本脚本依赖的程序
USB_TIMEOUT=1                                                                                 # curl 最大请求时间
NEO_ESC=`echo -ne "\033"`
USB_DETECT_URL(){
    wget --spider -T 5 -q -t 2 $1
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
COMMENT="${USER}@$(hostname -i)"
# 检测是否插入U盘，插入则建立U盘内容列表
USB_REMORT="/run/media/$USER" # udisks2 默认u盘挂载点
unset USB_ARR
if [ -e $USB_REMORT ]; then
    USB_ARR_UUID=($(lsblk -o UUID,MOUNTPOINT | grep "/run/media/"|awk '{print $1}'))
    USB_ARR=($(lsblk -o UUID,MOUNTPOINT | grep "/run/media/"|awk '{print $2}'))
fi
if [[ "${#USB_ARR[*]}" -eq 0 ]]; then
    echo "${USB_VERSION} 未检测到U盘， 请插入U盘后重试!"
    exit
fi
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
USB_LOCAL_UUID=($(lsblk -o UUID,MOUNTPOINT |grep "/home"))
# 先校检U盘和本地硬盘的id
unset USB_REG_PATH ; unset USB_REG_ID ; unset USB_LOCAL_ID
unset USB_REMORT_MAP_ALL; unset USB_LOCAL_MAP_ALL ; unset USB_CHECK_MAP_ALL
USB_REMORT_MAP_ALL=($(ls -d $USB_REMORT/*/* |grep ".git"))
USB_CHECK_MAP_ALL=(${USB_REMORT_MAP_ALL[*]%.git})
i=0
while [[ $i -lt "${#USB_ARR[*]}" ]]; do
    # 从U盘读取注册ID和PATH
    if [[ ! -e "${USB_ARR[$i]}/$USB_REGISTER" ]]; then
        touch "${USB_ARR[$i]}/$USB_REGISTER"
        echo "${USB_ARR_UUID[$i]} ${USB_ARR[$i]##*/}" \
            > ${USB_ARR[$i]}/$USB_REGISTER
        ls -lid --time-style=iso $HOME/${USB_ARR[$i]##*/}$USB_TAG/* \
            |awk '{print $1 " " $9 }' | sed "s/^/"$USB_LOCAL_UUID" &/g" \
            >> ${USB_ARR[$i]}/$USB_REGISTER
    else
        USB_REG_NAME=($(cat ${USB_ARR[$i]}/$USB_REGISTER |grep "${USB_ARR_UUID[$i]}" |awk '{print $2}'))
        if [[ ! $USB_REG_NAME == ${USB_ARR[$i]##*/} ]]; then # 检测U盘名称是否修改，确保仓库路径不变
            echo "U盘${USB_REG_NAME}被修改为${USB_ARR[$i]##*/}, 请改回为${USB_REG_NAME}!!" # 考虑自动化处理
        fi
        USB_REG_ID+=($(cat ${USB_ARR[$i]}/$USB_REGISTER |grep "$USB_LOCAL_UUID" |awk '{print $2}'))
        USB_REG_PATH+=($(cat ${USB_ARR[$i]}/$USB_REGISTER |grep "$USB_LOCAL_UUID" |awk '{print $3}'))
    fi
    # 由U盘生成准本地仓库，用来核对信息
    USB_CHECK_MAP_ALL=(${USB_CHECK_MAP_ALL[*]//"${USB_ARR[$i]}"/"$HOME/${USB_ARR[$i]##*/}$USB_TAG"})
    # 由本地与U盘关联的仓库实际生成目录
    USB_ARR_HOME="$HOME/${USB_ARR[$i]##*/}$USB_TAG"
    if [[ -d $USB_ARR_HOME ]]; then
        USB_LOCAL_MAP_ALL+=($(ls -lid --time-style=iso ${USB_ARR_HOME}/*|awk '{print $9}'))  # 获取目录
        USB_LOCAL_ID+=($(ls -lid --time-style=iso ${USB_ARR_HOME}/*/|awk '{print $1}'))      # 获取目录ID
    else
        if [[ "${USB_REMORT_MAP_ALL[*]%/*}" =~ "${USB_ARR[$i]}" ]]; then
            mkdir $USB_ARR_HOME
        fi
    fi
    let i+=1
done
# 获取远程和本地交集，用于同步
USB_SYNC_MAP_ALL=(`echo ${USB_CHECK_MAP_ALL[*]} ${USB_LOCAL_MAP_ALL[*]}|sed 's/ /\n/g'|sort|uniq -c|awk '$1!=1{print $2}'`)
# 获取远程减去远本交集，用于克隆到本地仓库
USB_LCLONE_MAP_ALL=(`echo ${USB_CHECK_MAP_ALL[*]} ${USB_SYNC_MAP_ALL[*]}|sed 's/ /\n/g'|sort|uniq -c|awk '$1==1{print $2}'`)
if [[ "${#USB_LCLONE_MAP_ALL[*]}" -gt 0 ]]; then
    USB_RCLONE_MAP_ALL=(${USB_LCLONE_MAP_ALL[*]//"$HOME"/"$USB_REMORT"}) # 替换本地地址
    USB_RCLONE_MAP_ALL=(${USB_RCLONE_MAP_ALL[*]//"$USB_TAG"/""})         # 去除本地标记
    USB_RCLONE_MAP_ALL=(${USB_RCLONE_MAP_ALL[*]/%/".git"})               # 添加仓库后缀
    i=0
    while [[ $i -lt "${#USB_LCLONE_MAP_ALL[*]}" ]]; do
        git clone ${USB_RCLONE_MAP_ALL[$i]} ${USB_LCLONE_MAP_ALL[$i]}
        echo "$USB_LOCAL_UUID ${USB_LOCAL_ID[$i]} ${USB_LCLONE_MAP_ALL[$i]}" \
            >> ${USB_RCLONE_MAP_ALL[$i]%/*}/$USB_REGISTER
        let i+=1
    done
fi
# 获取本地减去远本交集，这部分是需要删除的
USB_DELETE_MAP_ALL=(`echo ${USB_LOCAL_MAP_ALL[*]} ${USB_SYNC_MAP_ALL[*]}|sed 's/ /\n/g'|sort|uniq -c|awk '$1==1{print $2}'`)
if [[ "${#USB_DELETE_MAP_ALL[*]}" -gt 0 ]]; then
    USB_DELETE_MAP_REG=(${USB_DELETE_MAP_ALL[*]//"$HOME"/"$USB_REMORT"})
    USB_DELETE_MAP_REG=(${USB_DELETE_MAP_REG[*]%${USB_TAG}*})
    USB_DELETE_MAP_REG=(${USB_DELETE_MAP_REG[*]/%/"/$USB_REGISTER"})
    i=0
    while [[ $i -lt "${#USB_DELETE_MAP_ALL[*]}" ]]; do
        trash-put "${USB_DELETE_MAP_ALL[$i]}"
        sed -i "s#${USB_DELETE_MAP_ALL[$i]}#DELETSTRING#g" "${USB_DELETE_MAP_REG[$i]}"
        sed -i '/DELETSTRING/d' "${USB_DELETE_MAP_REG[$i]}"
        echo ${USB_DELETE_MAP_ALL[$i]}
        let i+=1
    done
fi
let i="${#USB_SYNC_MAP_ALL[*]}"; let j="${#USB_REMORT_MAP_ALL[*]}"
let USB_SYNC_WNUM=${#i}        ; let USB_REMORT_WNUM=${#j}
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
NEO_PUSH(){
    cd $1
    git add . &> /dev/null
    git commit -m "$COMMENT" &> /dev/null
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
USB_HELP(){
cat << EOF
用法：ugit  [选项]
版本：$USB_VERSION
ugit.sh -i --install       安装
        -h --help          帮助
        -l                 列出本地仓库/编辑
        -n                 新建仓库
        -ad                关联远程仓库
        -r --remove        删除U盘仓库
        -s --sync          本地<->U盘<->网络
        -u --update        联网升级软件
        -v --version       版本
        --pull             本地 <-- 远程
        --push             本地 ==> 远程
        --theme            选择主题
        --relocate         仓库搬家
EOF
}
if [ $# -gt 0 ]; then
    if [ $1 == "-l" -o $1 == "--list" -o $1 == "--LIST" ]; then
        NEO_LIST "${USB_SYNC_MAP_ALL[*]}" 1  # 默认设置为列出远程已经配置的仓库
        NEO_EDIT $EDFILE
    elif [ $1 == "-v" -o $1 == "-V" -o $1 == "--version" -o $1 == "--VERSION" ]; then
        echo "${USB_VERSION}"
    elif [ $1 == "-h" -o $1 == "-H" -o $1 == "--help" -o $1 == "--HELP" ]; then
        USB_HELP
    elif [ $1 == "--theme" -o $1 == "--THEME" ]; then
        NEO_THEME_SET "NEO_FORMAT"
    elif [ $1 == "-ad" -o $1 == "-addremote" -o $1 == "--AD" -o $1 == "--ADDREMOTE" ]; then
        if [[ "${USB_SYNC_MAP_ALL[*]}" =~ "$PWD" ]]; then
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
        while [[ $i -lt ${#USB_SYNC_MAP_ALL[*]} ]]; do
            cd ${USB_SYNC_MAP_ALL[$i]}
            git pull &> /dev/null
            let i+=1
            printf "[%0${USB_SYNC_WNUM}d] \U0001F4BE \u2b62 \U0001F4BB %s \n" \
                "$i" "${USB_SYNC_MAP_ALL[$i-1]}"
        done
    elif [ $1 == "-push" -o $1 == "-PUSH" -o $1 == "--push" -o $1 == "--PUSH" ]; then
        i=0 ; k=0
        while [[ $i -lt ${#USB_SYNC_MAP_ALL[*]} ]]; do
            NEO_PUSH ${USB_SYNC_MAP_ALL[$i]}
            let i+=1
            printf "[%0${USB_SYNC_WNUM}d] \U0001F4BE \u2b60 \U0001F4BB %s \n" \
                "$i" "${USB_SYNC_MAP_ALL[$i-1]}"
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
                        case "$USB_TEMP" in
                            gitlab) USB_TEMP_ICON=f296
                            ;;
                            github) USB_TEMP_ICON=f09b
                            ;;
                            *) USB_TEMP_ICON=f1d2
                            ;;
                        esac
                        if [ $? = 0 ]; then
                            git add . &> /dev/null
                            git commit -m "$COMMENT" &> /dev/null
                            git push -f $USB_TEMP &> /dev/null
                            printf " %${USB_SYNC_WNUM}s)  \u$USB_TEMP_ICON \u2b60 \U0001F4BB %s \n" \
                                "$k" "${USB_SYNC_MAP_ALL[$i-1]}"
                        else
                            printf " %${USB_SYNC_WNUM}s)  \u$USB_TEMP_ICON \u219A \U0001F4BB %s \n" \
                                "$k" "${USB_SYNC_MAP_ALL[$i-1]}"
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
            USB_TEMP_ID=$(ls -lid --time-style=iso $USB_TEMP |awk '{print $1}')
            if [[ -e "$USB_TEMP" ]]; then
                rm -rf "$USB_TEMP"
            fi
            sed -i "s#${USB_TEMP}#DELETSTRING#g" "${EDFILE%/*}/$USB_REGISTER"
            sed -i '/DELETSTRING/d' "${EDFILE%/*}/$USB_REGISTER"
            echo "仓库 ${EDFILE} 删除成功!"
        else
            echo "删除未执行，正常退出!"
            exit
        fi
    elif [ $1 == "-n" -o $1 == "-N" -o $1 == "--new" -o $1 == "--NEW" ]; then
        if [[ ${#USB_ARR[*]} -eq 1 ]]; then
            USB_UPANS=1
        else
            j=0
            while [[ $j -lt ${#USB_ARR[*]} ]]; do
                let j+=1
                echo "[$j] ${USB_ARR[$j-1]}"
            done
            echo -n "请选择U盘 "; read USB_UPANS  # 追加数字判断，后面升级时用
            expr "$USB_UPANS" + 1 &> /dev/null
            if [ $? -eq 0 ]; then
                if [ 0 -ge $USB_UPANS -o $USB_UPANS -gt  ${#USB_ARR[*]} ]; then
                    echo "编号超出范围，请重新选择编号！"
                    exit
                fi
            else
                echo "输入非数字，请重新输入编号！"
                exit
            fi
        fi
        USB_UPAN_FILE=($(echo ${USB_REMORT_MAP_ALL[*]} |grep "${USB_ARR[$USB_UPANS-1]}"))
        i=0
        while [[ $i -lt ${#USB_UPAN_FILE[*]} ]]; do
            let i+=1
            echo "[$i] ${USB_UPAN_FILE[$i-1]}"
        done
        DY_MKLINE
        echo -n "请输入新的仓库名: "; read SFNum
        if [[ "${USB_REMORT_MAP_ALL[*]}" =~ "${USB_ARR[$USB_UPANS-1]}/${SFNum}.git" ]]; then
            echo "$SFNum 已经存在，请重新命名!"
        else
            USB_OUT_REM="${USB_ARR[$USB_UPANS-1]}/${SFNum}.git"
            mkdir $USB_OUT_REM
            cd $USB_OUT_REM
            git init --bare --quiet &> /dev/null
            git branch -m $USB_BNAME &> /dev/null
            USB_TEMP="$HOME/${USB_ARR[$USB_UPANS-1]##*/}$USB_TAG"
            if [ ! -e $USB_TEMP ]; then
                mkdir $USB_TEMP
            fi
            git clone $USB_OUT_REM "$USB_TEMP/${SFNum}"  &> /dev/null
            ls -lid --time-style=iso "$USB_TEMP/${SFNum}" \
                |awk '{print $1 " " $9 }' | sed "s/^/"$USB_LOCAL_UUID" &/g" \
                >> ${USB_ARR[$USB_UPANS-1]}/$USB_REGISTER
            cd "$USB_TEMP/${SFNum}"
            touch README.md
            chmod +x README.md
            echo "$(date) created by ugit" > ./README.md
            echo "$USB_OUT_REM" >> ./README.md
            git add . &> /dev/null
            git commit -m "initial" &> /dev/null 
            git push &> /dev/null
            echo "U盘仓库[$SFNum]配置成功！"
        fi
    elif [ $1 == "--relocate" -o $1 == "--RELOCATE" ]; then
        USB_RELOCATE=($(ls -d $HOME/*$USB_TAG))
        NEO_LIST "${USB_RELOCATE[*]}" 1
        USB_LOCAL_OLD=${EDFILE}
        NEO_LIST "${USB_ARR[*]}" 1
        USB_LOCAL_NEW=${EDFILE}
        clear
        echo -ne "仓库迁移会清空U盘\033[41m${USB_LOCAL_NEW##*/}\033[0m ：Y/N "
        read USB_YesNo
        if [ $USB_YesNo == "Y" -o $USB_YesNo == "y" ]; then
            trash-put $USB_LOCAL_NEW/* &> /dev/null
            echo -ne "本地仓库\033[41m${USB_LOCAL_OLD##*/}\033[0m迁移至\033[41m${USB_LOCAL_NEW##*/}\033[0m : Y/N "
            if [ -e "$HOME/.zsh_history" ]; then
                sed -i "s?${USB_LOCAL_OLD##*/}?${USB_LOCAL_NEW##*/}?g" "$HOME/.zsh_history"
            fi
            read USB_SubYesNo
            if [ $USB_SubYesNo == "Y" -o $USB_SubYesNo == "y" ]; then
                if [ ! -e "${USB_LOCAL_NEW}/${USB_REL_CFG}" ]; then
                    touch "${USB_LOCAL_NEW}/${USB_REL_CFG}"
                fi
                echo "${USB_LOCAL_OLD}  ${USB_LOCAL_NEW}" >> "${USB_LOCAL_NEW}/${USB_REL_CFG}"
                USB_LOCAL_OLD_DIR=($(ls ${USB_LOCAL_OLD}))
                i=0
                while [[ $i -lt "${#USB_LOCAL_OLD_DIR[*]}" ]]; do
                    USB_RM_GIT="${USB_LOCAL_NEW}/${USB_LOCAL_OLD_DIR[$i]}.git"
                    if [ ! -e $USB_RM_GIT ]; then
                        mkdir $USB_RM_GIT
                        cd $USB_RM_GIT
                        git init --bare  &> /dev/null
                        git config --global init.defaultBranch $USB_BNAME &> /dev/null
                        cd "$USB_LOCAL_OLD/${USB_LOCAL_OLD_DIR[$i]}"
                        rm -rf .git
                        git init &> /dev/null
                        git remote add origin $USB_RM_GIT &> /dev/null
                        git add . &> /dev/null
                        git commit -m "RELOCATE" &> /dev/null
                        git push --set-upstream origin $USB_BNAME &> /dev/null
                        echo "$USB_LOCAL_OLD/${USB_LOCAL_OLD_DIR[$i]} 迁移成功!" 
                    fi
                    let i+=1
                done
            fi
        fi
    elif [ $1 == "-s" -o $1 == "-S" -o $1 == "--sync" -o $1 == "--SYNC" ]; then
        ugit --pull
        DY_MKLINE
        ugit --push
    fi
else
    ugit --sync
fi
