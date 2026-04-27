#! /bin/sh
#
# Program  : diary.sh
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# Date     : 2026-04-26 00:06
# CopyRight: Copyright (C) 2022-2030 Zhen-Hua Feng(冯振华)
# License  : Distributed under terms of the MIT license.
#
# 调入私有函数库
source ~/.Share_Fun/Share_Fun_Menu.sh
source ~/.Share_Fun/Share_Fun_KeySudo.sh
source ~/.Share_Fun/Share_Fun_Weather.sh
source ~/.Share_Fun/Share_Fun_Install.sh
#
# 保存脚本变量
DY_ARGS=( "$0" "$@" )
DY_VERSION="${DY_ARGS[0]##*/}-V17.8"
#=========================安装脚本=========================
SFI_INSTALL ${DY_ARGS[1]} ${DY_ARGS[0]} $DY_VERSION
# 变量配置
DY_NAME=diary ; DY_NAME_SH="diary.sh" ; DY_BNAME=main
DY_REMOTE=origin
DY_BRANCH=main
DY_SOURCE=~/.DY_SCE
DY_CFG=~/.DY_DATA
DY_KEY_CFG=~/.DY_KEY
DY_EXEPATH=/usr/local/bin
DY_DATE=$(date +"%Y年%m月%d日 %A")
DY_EXE="$DY_EXEPATH/$DY_NAME"
DY_TAG="\u258B"
USB_REMORT_SH="$DY_BNAME/$DY_NAME_SH"
NEO_ESC=`echo -ne "\033"`
# DY_NEXT_COLOR=#006600
DY_NEXT_COLOR=#9400D3
USB_TIMEOUT=1
NEO_WARNING="7"
DY_EDIT="nvim" # 默认编辑器 nvim/vim
COMMENT="${USER}@$(hostname -i)"
DY_HOST="/etc/hosts"
DY_SURL="https://gitee.com"
# 定义博客分类
DY_TAGS=( 电脑技术 科研笔记 心情随笔 )
unset USB_UPDATE_URLS
USB_UPDATE_URLS[0]=https://gitee.com/fengzhenhua/script/raw/$USB_REMORT_SH\?inline\=false      # 默认升级地址
# USB_UPDATE_URLS[1]=https://gitlab.com/fengzhenhua/script/-/raw/$USB_REMORT_SH\?inline\=false # 备用升级地址
#
# 私人信息设置
DY_GET_INF(){
    if [ ! -e $DY_KEY_CFG ]; then
        touch $DY_KEY_CFG
        chmod +w $DY_KEY_CFG
        echo "个人信息配置：注意下面直接按示例填写配置信息，去掉第1行之外的所有中文!!" > $DY_KEY_CFG
        echo "博客的模式，仅本地：0 ,  仅远程：1, 本地+远程备份：2" >> $DY_KEY_CFG
        echo "博客的远程地址，如git@github.com:xiaoming/xiaoming.github.io" >> $DY_KEY_CFG
        echo "博客的本地名称，如xiaoming.github.io" >> $DY_KEY_CFG
        echo "Gitlab博客仓库Token，如glpat-t3T_ZzJkcqp45kuiaNiP" >> $DY_KEY_CFG
        echo "gitlab-runner的Token，如GR1248741HKoaT483PhaqA1N894AY" >> $DY_KEY_CFG
        echo "博客发布地址，如https://gitlab.com/" >> $DY_KEY_CFG
        echo "配置文件已经生成在$DY_KEY_CFG, 请打开此文件按说明填写信息!"
        exit
    else
        DY_INFO=($(cat $DY_KEY_CFG))
        DY_MODEL=${DY_INFO[1]}
        DY_PCLONESITE=${DY_INFO[2]}
        DY_PCLONESITE_BAK=${DY_INFO[3]}
        DY_UNAME="${DY_INFO[4]}"
        DY_PATH_BAK="$DY_SOURCE/${DY_UNAME}"
        DY_PATH="${DY_PATH_BAK}.local"
        if [[ ${DY_MODEL} == 1 ]]; then
            DY_PCLONESITE=${DY_PCLONESITE_BAK}
            DY_PATH=${DY_PATH_BAK}
        fi
        # DY_IGNORE="$DY_PATH/.gitignore"
        DY_URL="https://${DY_UNAME}"
        DY_TOKEN=${DY_INFO[5]}
        REGISTRATION_TOKEN=${DY_INFO[6]}
        SOURCE_SIT=${DY_INFO[7]}
    fi
}
#=========================下载博客=========================
DY_CLONE_X(){
    if [ ! -e $2 ]; then
        mkdir -p $2
        git clone $1 $2
        echo "博客源文档目录$1 已经下载成功，Happy diarying ！"
    else
        if [ ! -s $2 ]; then
            rm -rf $2
            git clone $1 $2
            echo "博客源文档目录$1 已经下载成功，Happy diarying ！"
        fi
    fi
    DY_IGNORE="$2/.gitignore"
    if [[ ! -e $DY_IGNORE ]]; then
        touch $DY_IGNORE
        echo ".deploy_git/" > $DY_IGNORE
        echo "public/" >> $DY_IGNORE
        echo "db.json" >> $DY_IGNORE
    fi
}
DY_CLONE(){
    if [ ! -e $DY_SOURCE ]; then
        mkdir -p $DY_SOURCE
    fi
    if [[ ${DY_MODEL} == 2 ]]; then
        DY_CLONE_X $DY_PCLONESITE_BAK  $DY_PATH_BAK
    fi
    DY_CLONE_X $DY_PCLONESITE $DY_PATH
}
USB_DETECT_URL(){
    if [[ ${DY_MODEL} == 1 ]]; then
        if mirror_available "${DY_URL}"; then
            echo "网络畅通，$DY_VERSION 启动成功!"
            echo "源更新: ${DY_PCLONESITE}"
            cd $DY_PATH
            git pull &> /dev/null
            echo "源更新: 成功! "
        else
            DY_DNS_GITHUA=$(dig @4.2.2.1 +short github.com)
            SYN_KEY_GET
            echo $SYN_KEY_X |sudo -S sed -ie "s/"${DY_DNS_GITHUB}" * github.com/"${DY_DNS_GITHUA}" github.com /g" "$DY_HOST"
            unset SYN_KEY_X
            echo "网络探测完成，请重新运行程序!"
            exit
        fi
    else
        if [[ ${DY_MODEL} == 0 ]]; then
            echo "本地模式，$DY_VERSION 启动成功!"
        elif [[ ${DY_MODEL} == 2 ]]; then
            echo "备份模式，$DY_VERSION 启动成功!"
        fi
        if mirror_available "${SOURCE_SIT}"; then
            echo "源更新: ${DY_PCLONESITE}"
            cd $DY_PATH
            git pull &> /dev/null
            echo "源更新: 成功! "
        else
            echo "源不可达，请检查网络连接，确保网络畅通!"
            exit
        fi
    fi
}
#=========================脚本更新=========================
SelfUpdate(){
    if mirror_available "${USB_UPDATE_URLS[0]}"; then
        USB_UPDATE_URL=${USB_UPDATE_URLS[0]}
    else
        USB_UPDATE_URL=${USB_UPDATE_URLS[1]}
    fi
    if mirror_available "${USB_UPDATE_URL}"; then
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
    git add .  &> /dev/null
    git commit  -m  "$COMMENT" &> /dev/null
    # git push "$DY_REMOTE" "$DY_BRANCH" &> /dev/null
    git push &> /dev/null
    if [[ ${DY_MODEL} != 0 ]]; then
        hexo d --skip-generator
        gh auth switch -u fongzhenhua
        gh repo sync --force fongzhenhua/fongzhenhua.github.io --source fungzhenhua/fungzhenhua.github.io
        gh auth switch -u fungzhenhua
    fi
    if [[ ${DY_MODEL} == 2 ]]; then
        rsync -a --update $DY_PATH/ $DY_PATH_BAK/
        cd $DY_PATH_BAK
        git add .  &> /dev/null
        git commit  -m  "$COMMENT" &> /dev/null
        # git push "$DY_REMOTE" "$DY_BRANCH" &> /dev/null
        git push  &> /dev/null
    fi
    echo -e "文章发布成功，期待您的下一篇文章!"
}
DY_PUSH(){
    clear # 参数$1 的唯一作用是提供编辑文件的名字，然后提示编辑的文件
    local DY_ED_FILE="$1"
    DY_TEMP=$1 ; DY_TEMP=${DY_TEMP##*/}; DY_TEMP=${DY_TEMP%%.*}
    local DY_ED_INFO="${2:-$DY_TEMP}"
    DY_PU_INF=("[d]发布博客"  "[s]预览博客" "[b]回归编辑" "[q]退出")
    echo -e "\033[${NEO_WARNING}m正在编辑\033[0m：$DY_ED_INFO"
    DY_BUT_LIST 0 0 "${DY_PU_INF[*]}"
    case "$QueRen" in
        0|d|D)
            echo -e "\r\e[${NEO_FORMAT}m${DY_PU_INF[0]}\e[0m\033[K"
            DY_PUSHX
            ;;
        1|s|S)
            echo -e "\r\e[${NEO_FORMAT}m${DY_PU_INF[1]}\e[0m\033[K"
            if [[ ${DY_MODEL} == 1 ]]; then
                hexo s
            else
                $DY_EDIT "$DY_ED_FILE"
            fi
            DY_PUSH "$DY_ED_FILE" "$DY_ED_INFO"
            ;;
        2|b|B)
            echo -e "\r\e[${NEO_FORMAT}m${DY_PU_INF[2]}\e[0m\033[K"
            $DY_EDIT "$DY_ED_FILE"
            DY_PUSH  "$DY_ED_FILE" "$DY_ED_INFO"
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
#=========================配置本地服务=========================
DY_SERVE_FILE="/etc/systemd/system/blog.service"
DY_SERVE(){
if [ ! -e $DY_SERVE_FILE ]; then
SYN_KEY_GET
echo $SYN_KEY_X | sudo -S touch $DY_SERVE_FILE
echo $SYN_KEY_X | sudo -S sh -c "cat > $DY_SERVE_FILE" <<EOA
[Unit]
Description=Hexo Blog Static Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$DY_PATH/public
ExecStart=/usr/bin/python3 -m http.server 4000 --bind 127.0.0.1
Restart=always

[Install]
WantedBy=multi-user.target
EOA
echo $SYN_KEY_X | sudo -S systemctl daemon-reload
unset SYN_KEY_X
fi
}
DY_SYNC_FILE="$HOME/.config/systemd/user/diary-sync.service"
DY_SYNC(){
    if [ ! -e ${DY_SYNC_FILE%/*} ]; then
        mkdir -p ${DY_SYNC_FILE%/*}
    fi
    if [ ! -e $DY_SYNC_FILE ]; then
        touch $DY_SYNC_FILE
cat > $DY_SYNC_FILE << EOB
[Unit]
Description=Sync diary repository after network is ready
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=$DY_EXE --autostart

[Install]
WantedBy=default.target
EOB
systemctl --user daemon-reload
    fi
}
DY_CANDDY_FILE="/etc/caddy/conf.d/${DY_UNAME%%.*}.conf"
DY_CANDDY(){
    if ! grep -q "^[^#]*$DY_UNAME" "$DY_HOST"; then
SYN_KEY_GET
echo $SYN_KEY_X | sudo -S sh -c "cat >> $DY_HOST" <<EOD
127.0.0.1 ${DY_UNAME}
EOD
    fi
    if [ ! -e $DY_CANDDY_FILE ]; then
echo $SYN_KEY_X | sudo -S touch $DY_CANDDY_FILE
echo $SYN_KEY_X | sudo -S sh -c "cat > $DY_CANDDY_FILE" <<EOC
$DY_UNAME {
    tls internal
    reverse_proxy localhost:4000
}
EOC
    fi
}
DY_SERVE_SWITCH(){
    if [[ $1 == "--user" ]]; then
        DY_LOAD_STATE=$(systemctl $1 show -p LoadState --value "$3" 2>/dev/null)
        DY_ENABLE_STATE=$(systemctl $1  show -p UnitFileState --value "$3" 2>/dev/null)
        DY_ACTIVE_STATE=$(systemctl $1 show -p ActiveState --value "$3" 2>/dev/null)
    else
        DY_LOAD_STATE=$(systemctl show -p LoadState --value "$3" 2>/dev/null)
        DY_ENABLE_STATE=$(systemctl show -p UnitFileState --value "$3" 2>/dev/null)
        DY_ACTIVE_STATE=$(systemctl show -p ActiveState --value "$3" 2>/dev/null)
    fi
    if [[ "$DY_LOAD_STATE" != "loaded" ]]; then
        case "$3" in
            "blog")
                DY_SERVE
                ;;
            "diary-sync")
                DY_SYNC
                ;;
            "caddy")
                DY_CANDDY
                ;;
        esac
    fi
    if [[ $1 == "--user" ]]; then
        if [[ "$DY_ACTIVE_STATE" != "activating" && $2 == "on" ]]; then
                systemctl $1 start $3
        fi
        if [[ "$DY_ACTIVE_STATE" == "activating" && $2 == "off" ]]; then
                systemctl $1 stop $3
        fi
        if [[ "$DY_ENABLE_STATE" != "enabled"  && $2 == "on" ]]; then
                systemctl $1 enable $3
        fi
        if [[ "$DY_ENABLE_STATE" == "enabled"  && $2 == "off" ]]; then
                systemctl $1 disable $3
        fi
    else
        SYN_KEY_GET
        if [[ "$DY_ACTIVE_STATE" != "activating" && $2 == "on" ]]; then
                echo $SYN_KEY_X | sudo -S systemctl start $3
        fi
        if [[ "$DY_ACTIVE_STATE" == "activating" && $2 == "off" ]]; then
                echo $SYN_KEY_X | sudo -S systemctl stop $3
        fi
        if [[ "$DY_ENABLE_STATE" != "enabled"  && $2 == "on" ]]; then
                echo $SYN_KEY_X | sudo -S systemctl enable $3
        fi
        if [[ "$DY_ENABLE_STATE" == "enabled"  && $2 == "off" ]]; then
                echo $SYN_KEY_X | sudo -S systemctl disable $3
        fi
    fi
    if [[ $2 == "off" && $3 == "caddy" && -e "$DY_HOST" ]]; then
        if grep -q "^[^#]*$DY_UNAME" "$DY_HOST"; then
            echo $SYN_KEY_X | sudo -S sed -i "/127.0.0.1 ${DY_UNAME}/d" "$DY_HOST"
        fi
    fi
}
#=========================预先配置=========================
# 获取私人信息, 立刻获取各种变量
DY_GET_INF
# 不同模式下的服务处理
if [[ $DY_MODEL = 0 ]]; then
   DY_SERVE_SWITCH --root on blog
   DY_SERVE_SWITCH --user on diary-sync
   DY_SERVE_SWITCH --root on caddy
elif [[ $DY_MODEL = 1 ]]; then
   DY_SERVE_SWITCH --root off blog
   DY_SERVE_SWITCH --user off diary-sync
   DY_SERVE_SWITCH --root off caddy
elif [[ $DY_MODEL = 2 ]]; then
   DY_SERVE_SWITCH --root off blog
   DY_SERVE_SWITCH --user on diary-sync
   DY_SERVE_SWITCH --root off caddy
fi
# 检测目录并下载
DY_CLONE
# 获取日记配置位置
DY_ART="$DY_PATH/source/_posts"
DY_SOC="$DY_PATH/source"
DY_FILES=($(ls $DY_ART))
DY_SOURC=($(ls $DY_SOC))
DY_DEL=(404 PDF Picture _posts tags)
for DEL_LS in ${DY_DEL[*]} ; do
    DY_SOURC=(${DY_SOURC[*]/$DEL_LS})
done
# 探测博客网址是否可达以及博客设置
case ${1:-} in
    "--Setsym"|"--SetSym")
        echo $SYN_KEY_X |sudo -S sed -i "s/^DY_LINE.*$/DY_LINE=\"$2\"/g"  $0
        echo "分隔符已经修改为:$2"
        exit
        ;;
    "-H"|"-h"|"--help")
        DY_HELP
        ;;
    *)
        USB_DETECT_URL
        ;;
esac
# 检测默认文章
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
    DY_DEF=${DY_DATAX[-1]}
fi
#=========================管理博客=========================
case ${1:-} in
    "")
        if [[ "${DY_FILES[*]}" =~ "${DY_DEF##*/}"  && "${DY_ART}" == "${DY_DEF%/*}" ]]; then
            GetNetWeather &> /dev/null
            sed -i "1,/^$/{s/^$/\n## $DY_DATE $AdWeather $AdCity ##\n\n<++>\n/}"  $DY_DEF
            $DY_EDIT +%s/"<++>"//g $DY_DEF
            DY_PUSH   $DY_DEF
        else
            mv  -t ~/.local/share/Trash/files --backup=t ${DY_CFG}
            echo "${DY_DEF} 不存在，无效配置${DY_CFG} 己移除到回收站，重新设置默认文章请运行：diary !"
        fi
        ;;
    "-U"|"-u"|"--update")
        SelfUpdate
        ;;
    "-TU"|"-tu"|"--ThemeUpdate")
        ThemeUpdate
        ;;
    "-XL"|"-xl")
        NEO_LIST "${DY_SOURC[*]}" 1
        $DY_EDIT "$DY_SOC/$EDFILE/index.md"
        DY_PUSH "$DY_SOC/$EDFILE/index.md" "$EDFILE"
        ;;
    "-C"|"-c"|"--config")
        $DY_EDIT  $DY_PATH/_config.yml
        echo "主站配置文件修改完毕，请手动执行推送任务：diary -d"
        ;;
    "-C-Next"|"-c-next"|"--config--next")
        $DY_EDIT  $DY_PATH/_config.next.yml
        hexo clean
        hexo g
        echo "Next主题配置文件修改完毕，请手动执行推送任务：diary -d"
        ;;
    "--theme"|"--THEME")
        NEO_THEME_SET "NEO_FORMAT"
        ;;
    "-S"|"-s")
        if [[ ${DY_MODEL} == 1 ]]; then
            hexo s
        else
            echo "本地模式正在运行，请直接访问 http://localhost:4000"
            exit
        fi
        ;;
    "-D"|"-d")
        DY_PUSHX
        ;;
    "-O"|"-o")
        DY_INIT
        ;;
    "-L"|"-l"|"--list")
        NEO_LIST "${DY_FILES[*]}" 1
        $DY_EDIT "$DY_ART/$EDFILE"
        DY_PUSH  "$DY_ART/$EDFILE"
        ;;
    "-R"|"-r")
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
        ;;
    "--autostart")
        cd $DY_PATH || exit 1
        git pull
        ;;
    *)
        DY_DEF="$DY_ART/${1:-}.md"
        if [[ "${DY_FILES[*]}" =~ "${1:-}.md" ]]; then
            echo -n "文章《${1:-}》已经存在，编辑 y/n : "; read QueRen
            if [ $QueRen == "Y" -o $QueRen == "y" ]; then
                $DY_EDIT "$DY_DEF"
                DY_PUSH  "$DY_DEF"
            else
                exit
            fi
        else
            hexo n ${1:-}  &> /dev/null
            NEO_LIST "${DY_TAGS[*]}" 1
            sed -i "s/^tags:$/tags: $EDFILE/g" $DY_DEF
            sed -i "2,/---/{s/---/---\n\n <++>/}"  $DY_DEF
            $DY_EDIT +%s/"<++>"//g "$DY_DEF"
            DY_PUSH  "$DY_DEF"
        fi
        ;;
esac
