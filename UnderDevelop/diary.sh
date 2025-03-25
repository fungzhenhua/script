#! /bin/sh
#
# Program  : diary.sh
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# Date     : 2025-03-25 21:45
# CopyRight: Copyright (C) 2022-2030 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
# 变量配置
DY_NAME=diary ; DY_NAME_SH="diary.sh" ; DY_BNAME=main
DY_VERSION="${DY_NAME}-V14.7"
DY_REMOTE=origin
DY_BRANCH=main
if [ $# -gt 0 ]; then
    if [ $1 == "-V" -o $1 == "-v" -o $1 == "--version" ]; then
        echo "${DY_VERSION}"
        exit
    fi
fi
DY_SOURCE=~/.DY_SCE
DY_CFG=~/.DY_DATA
DY_KEY_CFG=~/.DY_KEY
DY_EXEPATH=/usr/local/bin
DY_DATE=$(date +"%Y年%m月%d日 %A")
DY_EXE="$DY_EXEPATH/$DY_NAME"
DY_TAG="\u258B"
DY_LINE="\u2584"
USB_REMORT_SH="$DY_BNAME/$DY_NAME_SH"
NEO_ESC=`echo -ne "\033"`
# DY_NEXT_COLOR=#006600
DY_NEXT_COLOR=#9400D3
USB_TIMEOUT=1
NEO_FORMAT="44;39"
NEO_WARNING="7"
## 密码存储和管理系统
# 定义标识符
SYN_KEY="syndns_password"  # 密钥环中的唯一标识符
SYN_SUDO_NUM_MAX="3"       # 确保这个数值与您系统中sudo验证次数一致，以免进入死循环
# 检测依赖，确保secret-tool正确安装
if ! command -v secret-tool &>/dev/null; then
  echo "错误：需要安装 secret-tool（包名：libsecret-tools）" >&2
  exit 1
fi
# 探测系统sud解锁程序
SYN_RES_CMD=""
if command -v faillock &>/dev/null; then
    SYN_RES_CMD="faillock --user $USER --reset"
elif command -v pam_tally2 &>/dev/null; then
    SYN_RES_CMD="pam_tally2 --user $USER --reset"
else
    echo "错误：未找到可用SUDO解锁工具 !" >&2
    echo "请安装：Arch系安装pambase，RHEL系安装pam" >&2
    exit 1  # 正确终止脚本
fi
# 存储密码到 GNOME Keyring
# 测试密码过程中存在sudo次数限制，如果sudo被锁定了，那本脚本在首次没有完成密码保存的工作后将处于锁定状态
SYN_KEY_GET(){
    local SYN_AMT="$SYN_SUDO_NUM_MAX"
    while [[ "$SYN_AMT" -gt 0 ]]; do
        SYN_KEY_X=$(secret-tool lookup syndns_password_key "$SYN_KEY")
        if [[ -z "$SYN_KEY_X" ]]; then
            unset SYN_KEY_DATA
            # 使用专业密码输入工具
            if command -v systemd-ask-password &>/dev/null; then
                SYN_KEY_DATA=$(systemd-ask-password --timeout=30 "请求sudo密码:")
            else
                printf "$0 请求输入sudo密码(30秒超时):" >&2
                # 增加超时后的清理逻辑
                if ! read -rs -t 30 SYN_KEY_DATA; then
                    printf "\n输入超时，操作取消。\n" >&2
                    unset SYN_KEY_DATA
                    exit 1
                fi
            fi
            if [[ -z "$SYN_KEY_DATA" ]]; then
                printf "\n密码不能为空，请重新输入。\n" >&2
            else
                if printf "%s" "$SYN_KEY_DATA" | secret-tool store --label="Syndns Password" syndns_password_key "$SYN_KEY"; then
                    sudo -k
                    if printf "%s" "$SYN_KEY_DATA" | sudo -S -v 2>/dev/null; then
                        # 存储成功后立即清理
                        unset SYN_KEY_DATA
                        printf "\n密码已成功存储到 GNOME Keyring 中。\n" >&2
                        return 0
                    else
                        SYN_AMT=$((SYN_AMT - 1))
                        SYN_FAIL_RES "警告：当前系统可能需要手动重置失败计数!"
                    fi
                else
                    printf "\n无法存储密码，请检查 GNOME Keyring 是否可用。\n" >&2
                    exit 1
                fi
            fi
        else
            sudo -k
            if ! printf "%s" "$SYN_KEY_X" | sudo -S -v 2>/dev/null; then
                SYN_AMT=$((SYN_AMT - 1))
                secret-tool clear syndns_password_key "$SYN_KEY" # 清空密码，重新循环才能进入设置
                SYN_FAIL_RES "警告：当前系统可能需要手动重置失败计数!"
            else
                return 0
            fi
        fi
    done
    printf "尝试次数已达上限，操作终止。\n" >&2
    SYN_FAIL_RES "请切换至ROOT权限解除锁定: $SYN_RES_CMD"
    exit 1
}
SYN_FAIL_RES(){
    if grep -qi 'arch' /etc/os-release 2>/dev/null; then
        faillock --user $USER --reset
    else
        # 优先显示传入的定制化提示
        printf "$1 \n" >&2
        # 补充建议命令（带sudo前缀）
        [ -n "$SYN_RES_CMD" ] && echo "可尝试执行: sudo $SYN_RES_CMD" >&2
    fi
}
# 检测/etc/hosts中对github.com的解析，以确保文章可以正常推送
DY_HOST="/etc/hosts"
DY_DNS_GITHUB=$(dig @119.29.29.29 +short github.com)
cat $DY_HOST |grep "$DY_DNS_GITHUB * github.com" &> /dev/null
if [[ $? = 0 ]]; then
    DY_DNS_GITHUA=$(dig @4.2.2.1 +short github.com)
    SYN_KEY_GET
    echo $SYN_KEY_X |sudo -S sed -ie "s/"${DY_DNS_GITHUB}" * github.com/"${DY_DNS_GITHUA}" github.com /g" "$DY_HOST"
fi
# 定义博客分类
DY_TAGS=( 电脑技术 科研笔记 心情随笔 )
unset USB_UPDATE_URLS
USB_UPDATE_URLS[0]=https://gitee.com/fengzhenhua/script/raw/$USB_REMORT_SH\?inline\=false      # 默认升级地址
# USB_UPDATE_URLS[1]=https://gitlab.com/fengzhenhua/script/-/raw/$USB_REMORT_SH\?inline\=false # 备用升级地址
DY_DEPENDENT="github-cli unzip curl nodejs npm git pandoc gawk sed"                            # 依赖程序
DY_EDIT="nvim"
which ${DY_EDIT} &>  /dev/null 
if [ ! $? -eq 0 ]; then
    DY_EDIT="vim"
    which ${DY_EDIT} &>  /dev/null 
    if [ ! $? -eq 0 ]; then
        SYN_KEY_GET
        echo $SYN_KEY_X |sudo -S pacman -S neovim vim &> /dev/null
        echo “已经为您安装默认编辑器：neovim vim , 请重新运行脚本！”
        exit
    fi
fi
DY_SET_SIZE(){
    TTY_H=$(stty size|awk '{print $1}')
    let TTY_H-=2
    TTY_W=$(stty size|awk '{print $2}')
}
DY_SET_SIZE
#=========================安装脚本=========================
DY_INSTALL(){
    SYN_KEY_GET
    # 检测并安装依赖
    if [[ $(which ssh) == 1 ]]; then
        echo $SYN_KEY_X |sudo -S pacman --needed --noconfirm -S openssh unzip curl
        echo "您的SSH还未设置，请设置您博客的SSH密钥以关联发布网址！"
    fi
    echo $SYN_KEY_X |sudo -S pacman --needed --noconfirm -S $DY_DEPENDENT &> /dev/null
    if [[ $(which hexo) == 1 ]]; then echo $SYN_KEY_X |sudo -S yarn global add hexo-cli ;  fi
    # 安装脚本
    if [ $0 == $DY_NAME ]; then
        echo "请切换到最新的脚本目录执行: ./install.sh -i "
    else
        echo $SYN_KEY_X |sudo -S cp -f $0 $DY_EXE
        echo $SYN_KEY_X |sudo -S chmod 755 $DY_EXE
        echo "${DY_VERSION}成功安装到标准位置$DY_EXEPATH，帮助请执行： diary --help "
    fi
    exit
}
if [ ! -e $DY_EXE ]; then
    DY_INSTALL
elif [ ! $# -eq 0 ]; then
    if [  $1 == "-i" -o $1 == "--install" ]; then
        if [ ! $1 == $DY_NAME ]; then
            DY_INSTALL
        fi
    fi
fi
COMMENT="${USER}@$(hostname -i)"
# 私人信息设置
if [ ! -e $DY_KEY_CFG ]; then
    touch $DY_KEY_CFG
    chmod +w $DY_KEY_CFG
    echo "个人信息配置：注意下面直接按示例填写配置信息，去掉第1行之外的所有中文!!" > $DY_KEY_CFG
    echo "博客的远程地址，如git@github.com:xiaoming/xiaoming.github.io" >> $DY_KEY_CFG
    echo "博客的本地名称，如xiaoming.github.io" >> $DY_KEY_CFG
    echo "高德地图密钥，用来获取天气预报，如79a3976b38e0b544d0d19dd643c4634e" >> $DY_KEY_CFG
    echo "Gitlab博客仓库Token，如glpat-t3T_ZzJkcqp45kuiaNiP" >> $DY_KEY_CFG
    echo "gitlab-runner的Token，如GR1248741HKoaT483PhaqA1N894AY" >> $DY_KEY_CFG
    echo "博客发布地址，如https://gitlab.com/" >> $DY_KEY_CFG
    echo "配置文件已经生成在$DY_KEY_CFG, 请打开此文件按说明填写信息!"
    exit
else
    DY_INFO=($(cat $DY_KEY_CFG))
    DY_PCLONESITE=${DY_INFO[1]}
    DY_PATH=$DY_SOURCE/${DY_INFO[2]}
    GAO_DE_KEY=${DY_INFO[3]}
    DY_TOKEN=${DY_INFO[4]}  #2024-04-18至2025-04-17
    REGISTRATION_TOKEN=${DY_INFO[5]}
    GITLAB_SIT=${DY_INFO[6]}
fi
DY_IGNORE="$DY_PATH/.gitignore"
if [[ ! -e $DY_IGNORE ]]; then
    touch $DY_IGNORE
    echo ".deploy_git/" > $DY_IGNORE
    echo "public/" >> $DY_IGNORE
    echo "db.json" >> $DY_IGNORE
fi
#=========================下载博客=========================
DY_CLONE(){
    git  clone $DY_PCLONESITE  $DY_PATH
    echo "博客源文档目录$DY_PATH已经下载成功，Happy diarying ！"
    exit
}
if [ ! -e $DY_SOURCE ]; then
    mkdir -p $DY_SOURCE
fi
if [ ! -e $DY_PATH ]; then
    mkdir -p $DY_PATH
    DY_CLONE
else
    if [ ! -s $DY_PATH ];  then
        rm -rf $DY_PATH
        DY_CLONE
    fi
fi
# 检测联网条件，不联网直接退出
USB_DETECT_URL(){
    wget --spider -T 5 -q -t 2 $1
}
USB_DETECT_URL "https://fungzhenhua.github.io"
if [ $? = 0 ]; then
    echo "网络畅通，$DY_VERSION 启动成功!"
    cd $DY_PATH
    git pull &> /dev/null
else
    echo "网络不通，请确保联网后撰写博客!"
    exit
fi
# 获取日记配置位置
DY_ART="$DY_PATH/source/_posts"
DY_SOC="$DY_PATH/source"
DY_FILES=($(ls $DY_ART))
DY_SOURC=($(ls $DY_SOC))
DY_DEL=(404 PDF Picture _posts tags)
for DEL_LS in ${DY_DEL[*]} ; do
    DY_SOURC=(${DY_SOURC[*]/$DEL_LS})
done
#=========================脚本更新=========================
SelfUpdate(){
    USB_DETECT_URL "${USB_UPDATE_URLS[0]}"
    if [ $? = 0 ]; then
        USB_UPDATE_URL=${USB_UPDATE_URLS[0]}
    else
        USB_UPDATE_URL=${USB_UPDATE_URLS[1]}
    fi
    USB_DETECT_URL "${USB_UPDATE_URL}"
    if [ $? = 0 ]; then
        SYN_KEY_GET
        echo "Diary is updating, please wait ......"
        echo $SYN_KEY_X |sudo -S curl -o $DY_EXE $USB_UPDATE_URL
        echo "Update completed, please run diary again"
        exit
    else
        echo "无法连接到升级仓库，请确保网络畅通后重试！"
    fi
}
ThemeUpdate(){
    rm -rf $DY_PATH/themes/next
    git clone https://github.com/next-theme/hexo-theme-next.git $DY_PATH/themes/next
    cd $DY_PATH/themes/next
    git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
    sed -i "s/^\$black-deep.*$/\$black-deep = "$DY_NEXT_COLOR"/g" \
        $DY_PATH/themes/next/source/css/_variables/base.styl
    sed -i "s/#222/"$DY_NEXT_COLOR"/g" $DY_PATH/_config.next.yml
    echo "\$content-desktop     = 900px;" >> $DY_PATH/themes/next/source/css/_variables/Muse.styl
    echo "\$content-desktop-large     = 1200px;" >> $DY_PATH/themes/next/source/css/_variables/Muse.styl
    sed -i "s/background: var(--btn-default-bg);//g" \
        $DY_PATH/themes/next/source/css/_schemes/Muse/_header.styl
    cd $DY_PATH
    hexo g
    echo "The next theme of hexo has been updated, happy diary !!"
}
#=========================定义函数=========================
# 此处应当在电脑上配置好帐号 fongzhenhua 和 fungzhenhua 的github-cli 登录, 因为时间关系暂不写成通用程序
DY_PUSHX(){
    cd $DY_PATH
    hexo g
    hexo d
    git add .  &> /dev/null
    git commit  -m  "$COMMENT" &> /dev/null
    git push "$DY_REMOTE" "$DY_BRANCH" &> /dev/null
    gh auth switch -u fongzhenhua
    gh repo sync --force fongzhenhua/fongzhenhua.github.io --source fungzhenhua/fungzhenhua.github.io
    gh auth switch -u fungzhenhua
    echo -e "文章发布成功，期待您的下一篇文章!"
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
DY_PUSH(){
    clear # 参数$1 的唯一作用是提供编辑文件的名字，然后提示编辑的文件
    DY_TEMP=$1 ; DY_TEMP=${DY_TEMP##*/}; DY_TEMP=${DY_TEMP%%.*}
    DY_PU_INF=("[d]发布博客"  "[s]预览博客" "[b]回归编辑" "[q]退出")
    echo -e "\033[${NEO_WARNING}m正在编辑\033[0m：$DY_TEMP "
    DY_BUT_LIST 0 0 "${DY_PU_INF[*]}"
    case "$QueRen" in
        0|d|D)
            echo -e "\r\e[${NEO_FORMAT}m${DY_PU_INF[0]}\e[0m\033[K"
            DY_PUSHX
            ;;
        1|s|S)
            echo -e "\r\e[${NEO_FORMAT}m${DY_PU_INF[1]}\e[0m\033[K"
            hexo s
            DY_PUSH $1
            ;;
        2|b|B)
            echo -e "\r\e[${NEO_FORMAT}m${DY_PU_INF[2]}\e[0m\033[K"
            $DY_EDIT $1
            DY_PUSH $1
            ;;
        3|q|Q)
            echo -e "\r\e[${NEO_FORMAT}m${DY_PU_INF[3]}\e[0m\033[K"
            echo -e "\033[91m手动发布博客，请使用选项:\033[0m -d "
            exit
            ;;
    esac
}
DY_INIT(){
    cd $DY_PATH
    rm -rf .git 
    git init  &> /dev/null
    git branch -m $DY_BRANCH
    git add .
    git commit -m "Clean"
    git remote add "$DY_REMOTE" "$DY_PCLONESITE"
    git push -f "$DY_REMOTE" "$DY_BRANCH"
}
#=========================帮助菜单=========================
DY_HELP(){
cat << EOF
用法：$DY_NAME [选项] 文章标题
版本：$DY_VERSION
选项：
    -c --config            修改主站配置文件
    -c-next --config--next 修改主题配置文件
    -d                     上载博客文章
    -h --help              帮助
    -i --install           重新安装
    -l --list              列出所有文章
    -o                     清理Commit
    -r                     删除博客文章
    -s                     预览博客
    --theme                选择主题
    --Setsym *             设置分隔符为: *
    -tu --ThemeUpdate      升级Next主题
    -u  --update           更新软件
    -xl                    修改目录后再列出
EOF
}
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
    echo $SYN_KEY_X |sudo -S sed -i "s/^$1.*$/$1=\"${NEO_THEME_COLOR}\"/" $DY_EXE
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
# 参数：列出的数组， 1开启选择/0关闭选择, 根据实际需要略作格式变更
NEO_LIST(){
    unset NEO_ARR ; NEO_ARRX=($1) ; NEO_ARR=(${NEO_ARRX[*]%.*}); NEO_SEL_ON=$2
    DY_NUM_WTX="${#NEO_ARR[*]}"
    DY_NUM_WT="${#DY_NUM_WTX}"
    clear
    DY_SET_SIZE
    if [ "${#NEO_ARR[*]}" -gt $TTY_H ]; then
        NEO_LISA 0 "${#NEO_ARR[*]}" 1
    else
        NEO_LISB 0 "${#NEO_ARR[*]}" 1
    fi
    EDFILE="${NEO_ARRX[$NEO_OUT_H-1]}"
}
#=====================配置文件设置顶置=====================
if [ ! -e $DY_CFG ]; then 
    echo "默认文章未设置，设置默认文章启动 ... ..."
    sleep 2
    NEO_LIST "${DY_FILES[*]}" 1
    echo "$COMMENT" > $DY_CFG
    echo "$DY_ART/$EDFILE" >> $DY_CFG
    echo "默认文章已经设置为:$EDFILE !"
    exit
else
    unset DY_DATAX
    DY_DATAX=($(cat $DY_CFG))
    # COMMENT=${DY_DATAX[0]}
    DY_DEF=${DY_DATAX[1]}
fi
#=========================取得天气=========================
AdIp=$(curl -s ip.threep.top |sed 's/ //g')
# 通过高德地图api获取位置、IP、天气情况
AdIpGD=$(curl -s "https://restapi.amap.com/v3/ip?ip=$AdIp&output=xml&key=$GAO_DE_KEY"|sed 's/ //g')
Adcode=$(echo $AdIpGD | awk -F'<adcode>' '{print $2}'|sed 's/ //g')
Adcode=$(echo $Adcode | awk -F'</adcode>' '{print $1}'|sed 's/ //g')
Adprovince=$(echo $AdIpGD | awk -F'<province>' '{print $2}'|sed 's/ //g')
Adprovince=$(echo $Adprovince | awk -F'</province>' '{print $1}'|sed 's/ //g')
AdCity=$(echo $AdIpGD | awk -F'<city>' '{print $2}'|sed 's/ //g')
AdCity=$(echo $AdCity | awk -F'</city>' '{print $1}'|sed 's/ //g')
WeatherIfo=$(curl -s "https://restapi.amap.com/v3/weather/weatherInfo?city=$Adcode&key=$GAO_DE_KEY")
AdWeather=$(echo $WeatherIfo | awk -F'weather' '{print $2}' | awk -F':' '{print $2}'| \
    awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
AdTemp=$(echo $WeatherIfo | awk -F'temperature' '{print $2}' | awk -F':' '{print $2}'| \
    awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
AdTempFloat=$(echo $WeatherIfo | awk -F'temperature_float' '{print $2}' | awk -F':' '{print $2}'| \
    awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
AdWindDir=$(echo $WeatherIfo | awk -F'winddirection' '{print $2}' | awk -F':' '{print $2}'| \
    awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
AdWindPow=$(echo $WeatherIfo | awk -F'windpower' '{print $2}' | awk -F':' '{print $2}'| \
    awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
AdHumidity=$(echo $WeatherIfo | awk -F'humidity' '{print $2}' | awk -F':' '{print $2}'| \
    awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
AdHumidityFloat=$(echo $WeatherIfo | awk -F'humidity_float' '{print $2}' | awk -F':' '{print $2}'| \
    awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
AdTepTime=$(echo $WeatherIfo | awk -F'reporttime' '{print $2}' | awk -F':' '{print $2}'| \
    awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
#
#=====================检测密钥是否过期=====================
# DY_AUTHOR=$(curl --header "PRIVATE-TOKEN: $DY_TOKEN" -s --request GET \
#     "https://gitlab.com/api/v4/projects/39402992/repository/commits" |grep "Unauthorized") 
# if [[ ! $DY_AUTHOR = "" ]]; then
#     echo "DY_TOKEN过期，请重新设置！"
# fi
#=========================管理博客=========================
if [ $# -eq 0 ]; then
    if [[ "${DY_FILES[*]}" =~ "${DY_DEF##*/}"  && "${DY_ART}" == "${DY_DEF%/*}" ]]; then
        sed -i "1,/^$/{s/^$/\n## $DY_DATE $AdWeather $AdCity ##\n\n<++>\n/}"  $DY_DEF
        $DY_EDIT +%s/"<++>"//g $DY_DEF
        DY_PUSH   $DY_DEF
    else
        mv  -t ~/.local/share/Trash/files --backup=t ${DY_CFG}
        echo "${DY_DEF} 不存在，无效配置${DY_CFG} 己移除到回收站，重新设置默认文章请运行：diary !"
    fi
else
    if [ $1 == "--Setsym" -o $1 == "--SetSym" ]; then
        echo $SYN_KEY_X |sudo -S sed -i "s/^DY_LINE.*$/DY_LINE=\"$2\"/g"  $0
        echo "分隔符已经修改为:$2"
        exit
    elif [ $1 == "-XL" -o $1 == "-xl" ]; then
        NEO_LIST "${DY_SOURC[*]}" 1
        $DY_EDIT "$DY_SOC/$EDFILE/index.md"
        DY_PUSH "$DY_SOC/$EDFILE"
    elif [ $1 == "--Setedit" -o $1 == "--SetEdit" ]; then
        echo $SYN_KEY_X |sudo -S pacman -S --needed --noconfirm $2 &> /dev/null
        if [ $? == 0 ]; then
            if [ $2 == "neovim" ]; then
                SetEdited="nvim"
            else
                SetEdited="$2"
            fi
            echo $SYN_KEY_X |sudo -S sed -i "s/^DY_EDIT.*$/DY_EDIT=\"$SetEdited\"/g"  $0
            echo "$2已经成功设置，Happy diaring !"
        else
            echo "$2无法识别，请输入正确的编辑器！建议：neovim vim vi"
        fi
        exit
    elif [ $1 == "-H" -o $1 == "-h" -o $1 == "--help" ]; then
        DY_HELP
    elif [ $1 == "-U" -o $1 == "-u" -o $1 == "--update" ]; then
        SelfUpdate
    elif [ $1 == "-TU" -o $1 == "-tu" -o $1 == "--ThemeUpdate" ]; then
        ThemeUpdate
    elif [ $1 == "-C" -o $1 == "-c" -o $1 == "--config" ]; then
        $DY_EDIT  $DY_PATH/_config.yml
        echo "主站配置文件修改完毕，请手动执行推送任务：diary -d"
    elif [ $1 == "-C-next" -o $1 == "-c-next" -o $1 == "--config--next" ]; then
        $DY_EDIT  $DY_PATH/_config.next.yml
        hexo clean
        hexo g
        echo "Next主题配置文件修改完毕，请手动执行推送任务：diary -d"
    elif [ $1 == "--theme" -o $1 == "--THEME" ];then
        NEO_THEME_SET "NEO_FORMAT"
    elif [ $1 == "-S" -o $1 == "-s" ];then
        hexo s
    elif [ $1 == "-D" -o $1 == "-d" ];then
        DY_PUSHX
    elif [ $1 == "-O" -o $1 == "-o" ];then
        DY_INIT
    elif [ $1 == "-L" -o $1 == "-l" -o $1 == "--list" ]; then
        NEO_LIST "${DY_FILES[*]}" 1
        $DY_EDIT "$DY_ART/$EDFILE"
        DY_PUSH  "$DY_ART/$EDFILE"  
    elif [ $1 == "-R" -o $1 == "-r" ];then
        NEO_LIST "${DY_FILES[*]}" 1
        echo -ne "\r\033[5m\033[101m\u26A0 \033[0m\033[${NEO_WARNING}m《${EDFILE%.*}》\033[0m [y] 删除 [q] 退出 $DY_TAG\033[K"; read Snum
        DY_SET_SIZE
        let NEO_LINENO=${TTY_H}+1
        if [ $Snum == "Y" -o $Snum == "y" ]; then
            rm "$DY_ART/$EDFILE"
            rm -rf .deploy_git
            printf "\033[${NEO_LINENO};1H\u2705删除: \033[${NEO_WARNING}m《${EDFILE%.*}》\033[0m"
        else
            printf "\033[${NEO_LINENO};1H\u274E退出: \033[${NEO_WARNING}m《${EDFILE%.*}》\033[0m"
            exit
        fi
    else
        DY_DEF="$DY_ART/$1.md"
        if [[ "${DY_FILES[*]}" =~ "$1.md" ]]; then
            echo -n "文章《$1》已经存在，编辑 y/n : "; read QueRen
            if [ $QueRen == "Y" -o $QueRen == "y" ]; then
                $DY_EDIT "$DY_DEF"
                DY_PUSH  "$DY_DEF"
            else
                exit
            fi
        else
            hexo n $1  &> /dev/null
            NEO_LIST "${DY_TAGS[*]}" 1
            sed -i "s/^tags:$/tags: $EDFILE/g" $DY_DEF
            sed -i "2,/---/{s/---/---\n\n <++>/}"  $DY_DEF
            $DY_EDIT +%s/"<++>"//g "$DY_DEF"
            DY_PUSH  "$DY_DEF"
        fi
    fi
fi
