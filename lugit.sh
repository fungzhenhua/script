#! /bin/sh
#
# Program  : ugit.sh
# Date     : 2025-01-06 12:25
# Weather  : 2025年01月06日星期一晴北京市
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2024 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
USB_NAME=ugit ; USB_NAME_SH="lugit.sh" ; USB_BNAME=main
USB_VERSION="${USB_NAME}-V11.2"
USB_REMORT="$HOME/.gitrepository"                         # 默认git仓库
USB_LOCAL="$HOME/KINGSTON@UGIT"
USB_URL_CFG="$HOME/.ugit-url"
if [[ ! -e $USB_URL_CFG ]]; then
    touch $USB_URL_CFG
    echo "Created by ugit" > $USB_URL_CFG
    echo "1. 本地远程仓库:" >> $USB_URL_CFG
    echo $USB_REMORT >> $USB_URL_CFG
    echo "2. 本地编辑仓库:" >> $USB_URL_CFG
    echo $USB_LOCAL >> $USB_URL_CFG
else
    USB_REMORT=$(sed -n '3p' $USB_URL_CFG)
    USB_LOCAL=$(sed -n '5p' $USB_URL_CFG)
fi
USB_SCFG=.git/config
USB_RCFG="$USB_REMORT/.ugitrcf"
USB_TAG="@UGIT"
DY_LINE="\u2584"
NEO_FORMAT="44;39"
USB_EXE="/usr/local/bin/$USB_NAME"
USB_REMORT_SH="$USB_BNAME/$USB_NAME_SH"
unset USB_UPDATE_URLS
USB_UPDATE_URLS[0]=https://gitee.com/fengzhenhua/script/raw/$USB_REMORT_SH\?inline\=false     # 默认升级地址
USB_UPDATE_URLS[1]=https://gitlab.com/fengzhenhua/script/-/raw/$USB_REMORT_SH\?inline\=false  # 备用升级地址
USB_USED=95                                                                                   # U盘使用量阈值(0-100)
USB_DEPENDENT="trash-cli curl gawk sed grep"                                                  # 本脚本依赖的程序
USB_TIMEOUT=1                                                                                 # curl 最大请求时间
NEO_ESC=`echo -ne "\033"`
# 网络探测程序
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
            echo "${USB_VERSION}成功安装到: $USB_EXE"
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
# ------------------------------------------------------------
USB_REMORT_MAP_ALL=($(ls -F $USB_REMORT |grep "$USB_TAG"))
USB_LOCAL_MAP_ALL=($(ls -F $USB_LOCAL |grep "/$"))                       # 临时不加鉴别的识别为当前目录
# 去除路径，为求集合做准备
USB_REMORT_MAP_ALL=(${USB_REMORT_MAP_ALL[@]%${USB_TAG}*})
USB_LOCAL_MAP_ALL=(${USB_LOCAL_MAP_ALL[@]%/*})
# 获取远程和本地交集，用于同步
USB_SYNC_MAP_ALL=(`echo ${USB_REMORT_MAP_ALL[*]} ${USB_LOCAL_MAP_ALL[*]}|sed 's/ /\n/g'|sort|uniq -c|awk '$1!=1{print $2}'`)
# 获取远程减去远本交集，用于克隆到本地仓库
USB_LCLONE_MAP_ALL=(`echo ${USB_REMORT_MAP_ALL[*]} ${USB_SYNC_MAP_ALL[*]}|sed 's/ /\n/g'|sort|uniq -c|awk '$1==1{print $2}'`)
# 获取本地减去远本交集，这部分是需要删除的
USB_DELETE_MAP_ALL=(`echo ${USB_LOCAL_MAP_ALL[*]} ${USB_SYNC_MAP_ALL[*]}|sed 's/ /\n/g'|sort|uniq -c|awk '$1==1{print $2}'`)
# 为各仓库添加路径
USB_RCLONE_MAP_ALL=(${USB_LCLONE_MAP_ALL[@]/#/"$USB_REMORT/"})         # 添加远程地址
USB_RCLONE_MAP_ALL=(${USB_LCLONE_MAP_ALL[@]/%/"$USB_TAG"})             # 添加仓库标记
USB_LCLONE_MAP_ALL=(${USB_LCLONE_MAP_ALL[@]/#/"$USB_LOCAL/"})          # 添加本地地址
USB_RELOCA_MAP_ALL=(${USB_DELETE_MAP_ALL[@]/#/"$USB_REMORT/"})         # 添加远程地址
USB_RELOCA_MAP_ALL=(${USB_RELOCA_MAP_ALL[@]/%/"$USB_TAG"})             # 添加仓库标记
USB_DELETE_MAP_ALL=(${USB_DELETE_MAP_ALL[@]/#/"$USB_LOCAL/"})          # 添加本地地址
USB_SYNC_MAP_ALL=(${USB_SYNC_MAP_ALL[@]/#/"$USB_LOCAL/"})              # 添加本地地址
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
    if [ $1 == "-v" -o $1 == "-V" -o $1 == "--version" -o $1 == "--VERSION" ]; then
        echo "${USB_VERSION}"
    elif [ $1 == "-h" -o $1 == "-H" -o $1 == "--help" -o $1 == "--HELP" ]; then
        USB_HELP
    elif [ $1 == "--theme" -o $1 == "--THEME" ]; then
        NEO_THEME_SET "NEO_FORMAT"
    elif [ $1 == "-l" -o $1 == "--list" -o $1 == "--LIST" ]; then
        NEO_LIST "${USB_SYNC_MAP_ALL[@]}" 1  # 默认设置为列出远程已经配置的仓库
        NEO_EDIT $EDFILE
    elif [ $1 == "--ad" -o $1 == "--addremote" -o $1 == "--AD" -o $1 == "--ADDREMOTE" ]; then
        if [[ "${USB_SYNC_MAP_ALL[*]}" =~ "$PWD" ]]; then
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
    elif [ $1 == "-rbr" -o $1 == "--rbranch" -o $1 == "-RBR" -o $1 == "--RBRANCH" ]; then
        for ((i = 0; i < ${#USB_SYNC_MAP_ALL[*]}; i++)); do
            cd ${USB_SYNC_MAP_ALL[$i]}
            git checkout --orphan latest
            git add .
            git commit -m "重置仓库"
            git branch | grep -v "latest" | xargs git branch -D
            git branch -m $USB_BNAME 
            git branch --set-upstream-to=origin/$USB_BNAME $USB_BNAME
            git push -f origin $USB_BNAME
        done
    elif [ $1 == "-pull" -o $1 == "--pull" -o $1 == "-PULL" -o $1 == "--PULL" ]; then
        for ((i = 0; i < ${#USB_SYNC_MAP_ALL[*]}; i++)); do
            cd ${USB_SYNC_MAP_ALL[$i]}
            git pull &> /dev/null
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
            USB_TEMP="${EDFILE%${USB_TAG}*}"
            USB_TEMP="$USB_LOCAL/${USB_TEMP##*/}"
            if [[ -e "$USB_TEMP" ]]; then
                rm -rf "$USB_TEMP"
            fi
            echo "仓库 ${EDFILE} 删除成功!"
        else
            echo "删除未执行，正常退出!"
            exit
        fi
    elif [ $1 == "-n" -o $1 == "-N" -o $1 == "--new" -o $1 == "--NEW" ]; then
        for ((i = 1; $i <= ${#USB_REMORT_MAP_ALL[*]}; i++ )); do
            echo "[$i] ${USB_REMORT_MAP_ALL[$i-1]}"
        done
        DY_MKLINE
        echo -n "请输入新的仓库名: "; read SFNum
        if [[ "${USB_REMORT_MAP_ALL[*]}" =~ "$SFNum" ]]; then
            echo "$SFNum 已经存在，请重新命名!"
        else
            USB_OUT_REM="${USB_REMORT}/$SFNum$USB_TAG"
            mkdir $USB_OUT_REM
            cd $USB_OUT_REM
            git init --bare --quiet &> /dev/null
            git branch -m $USB_BNAME &> /dev/null
            USB_TEMP="$USB_LOCAL/$SFNum"
            if [ ! -e $USB_TEMP ]; then
                mkdir $USB_TEMP
            fi
            git clone "$USB_OUT_REM" "$USB_TEMP"  &> /dev/null
            cd "$USB_TEMP"
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
        for ((i = 0; i < ${#USB_RELOCA_MAP_ALL[@]}; i++)); do
            mkdir ${USB_RELOCA_MAP_ALL[$i]}
            cd ${USB_RELOCA_MAP_ALL[$i]}
            git init --bare  &> /dev/null
            git config --global init.defaultBranch $USB_BNAME &> /dev/null
            cd ${USB_DELETE_MAP_ALL[$i]}
            rm -rf .git
            git init &> /dev/null
            git remote add origin ${USB_RELOCA_MAP_ALL[$i]} &> /dev/null
            git add . &> /dev/null
            git commit -m "RELOCATE" &> /dev/null
            git push --set-upstream origin $USB_BNAME &> /dev/null
            echo "${USB_DELETE_MAP_ALL[$i]} 迁移成功!"
        done
    elif [ $1 == "-s" -o $1 == "-S" -o $1 == "--sync" -o $1 == "--SYNC" ]; then
        ugit --pull
        DY_MKLINE
        ugit --push
    fi
else
    ugit --sync
fi
