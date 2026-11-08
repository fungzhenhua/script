#! /bin/sh
#
# Program  : diary.sh
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# Date     : 2026-11-08 21:02
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
DY_VERSION="${DY_ARGS[0]##*/}-V19.4"
#=========================安装脚本=========================
SFI_INSTALL ${DY_ARGS[1]} ${DY_ARGS[0]} $DY_VERSION
# 变量配置
DY_NAME=diary ; DY_NAME_SH="diary.sh" ; DY_BNAME=main
DY_REMOTE=origin
DY_BRANCH=main
DY_SOURCE="$HOME/.DY_SCE"
DY_CFG="$HOME/.diary_config.sh"
DY_EXEPATH="/usr/local/bin"
DY_DATE=$(date +"%Y年%m月%d日 %A")
DY_EXE="$DY_EXEPATH/$DY_NAME"
DY_TAG="\u258B"
USB_REMORT_SH="$DY_BNAME/$DY_NAME_SH"
NEO_ESC=`echo -ne "\033"`
# DY_NEXT_COLOR=#006600
DY_NEXT_COLOR=#9400D3
USB_TIMEOUT=1
NEO_WARNING="7"
DY_EDIT="nvim"                      # 默认编辑器 nvim/vim
COMMENT="${USER}@$(hostname -i)"
DY_HOST="/etc/hosts"
#
# 私人信息设置
DY_GET_INF(){
    if [ ! -e $DY_CFG ]; then
        touch $DY_CFG
        chmod +w $DY_CFG
        echo "# diary.sh的配置文件"                                           >  $DY_CFG
        echo "# 本地模式：local,  远程模式：remote"                           >> $DY_CFG
        echo "DY_MODEL=\"remote\""                                            >> $DY_CFG
        echo "# 博客生成器, 目前支持 hexo 和 hugo"                            >> $DY_CFG
        echo "DY_GENERATOR=\"hugo\""                                          >> $DY_CFG
        echo "# 博客的远程地址，如git@github.com:xiaoming/xiaoming.github.io" >> $DY_CFG
        echo "DY_PCLONESITE="                                                 >> $DY_CFG
        echo "# 博客在github上的帐户名"                                       >> $DY_CFG
        echo "DY_UAUTH="                                                      >> $DY_CFG
        echo "# 同步博客在github上的帐户名"                                   >> $DY_CFG
        echo "DY_SUAUTH="                                                     >> $DY_CFG
        echo "# 定义博客分类"                                                 >> $DY_CFG
        echo "DY_TAGS=( 电脑技术 科研笔记 心情随笔 )"                         >> $DY_CFG
        echo "# 默认升级地址"                                                 >> $DY_CFG
        echo "USB_UPDATE_URLS[0]="                                            >> $DY_CFG
        echo "# 备用升级地址"                                                 >> $DY_CFG
        echo "USB_UPDATE_URLS[1]="                                            >> $DY_CFG
        echo "请填写配置文件：$DY_CFG"
        exit
    else
        unset USB_UPDATE_URLS
        source $DY_CFG
        DY_UNAME="${DY_UAUTH}.github.io"
        DY_SUNAME="${DY_SUAUTH}.github.io"
        DY_URL="https://${DY_UNAME}"
        DY_PATH="$DY_SOURCE/${DY_UNAME}"
        case "$DY_GENERATOR" in
            hexo)
                DY_SOC="$DY_PATH/source"
                DY_ART="$DY_SOC/_posts"
                DY_STATION_CFG="$DY_PATH/_config.yml"
                DY_NEXT_CFG="$DY_PATH/_config.next.yml"
                DY_GEN_CMD="hexo g"
                DY_SERVE_CMD="hexo s"
                ;;
            hugo)
                DY_SOC="$DY_PATH/content"
                DY_ART="$DY_SOC/post"
                DY_STATION_CFG="$DY_PATH/hugo.yml"
                DY_NEXT_CFG="$DY_PATH/hugo.yml"
                DY_GEN_CMD="hugo"
                DY_SERVE_CMD="hugo server -D"
                ;;
            *)
                echo "${DY_GENERATOR} 目前只支持 hugo 或 hexo, 请在 $DY_CFG 中修改！"
                ;;
        esac
# 获取日记配置位置
        shopt -s nullglob
        DY_FILES=("$DY_ART"/*)
        DY_SOURC=("$DY_SOC"/*/)
        DY_FILES=("${DY_FILES[@]##*/}")
        DY_SOURC=("${DY_SOURC[@]%/*}")
        DY_SOURC=("${DY_SOURC[@]##*/}")
        shopt -u nullglob
        DY_DEL=(404 PDF Picture _posts tags archives flinks post)
        for DEL_LS in ${DY_DEL[*]} ; do
            DY_SOURC=(${DY_SOURC[*]/$DEL_LS})
        done
    fi
}
# 获取私人信息, 立刻获取各种变量
DY_GET_INF
#=========================下载博客=========================
DY_CLONE_X(){
    if [ ! -e "$2" ]; then
        mkdir -p $2
        git clone $1 $2
        echo "博客源文档目录$1 已经下载成功，Happy diarying ！"
    else
        if [ ! -s "$2" ]; then
            rm -rf $2
            git clone $1 $2
            echo "博客源文档目录$1 已经下载成功，Happy diarying ！"
        fi
    fi
    touch $DY_IGNORE
    echo "/.deploy_git/"      >  $DY_IGNORE
    echo "/public/"          >> $DY_IGNORE
    echo "/resources/"       >> $DY_IGNORE
    echo ".hugo_build.lock"  >> $DY_IGNORE
    echo "hugo_stats.json"   >> $DY_IGNORE
    echo "db.json"           >> $DY_IGNORE
}
DY_CLONE(){
    if [ ! -e $DY_SOURCE ]; then
        mkdir -p $DY_SOURCE
    fi
    DY_IGNORE="${DY_PATH}/.gitignore"
    if [ ! -e "$DY_IGNORE" ]; then
        DY_CLONE_X "$DY_PCLONESITE"  "$DY_PATH"
        exit
    fi
}
# 删除了博客模式的复杂结构
USB_DETECT_URL(){
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
}
#=========================脚本更新=========================
ThemeUpdate(){
# hexo-next 主题升级, TODO hugo-next
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
# 此处应当在电脑上配置好帐号 DY_UNAME 和 DY_SUNAME 的github-cli 登录, 因为时间关系暂不写成通用程序
DY_PUSHX(){
    cd "$DY_PATH"
    if [[ $1 = r ]]; then
        rm -rf "$DY_PATH"/public
        $DY_GEN_CMD
        cd "$DY_PATH"/public
        git init  &> /dev/null
        git branch -m $DY_BRANCH
        git add .
        git commit -m "$COMMENT" &> /dev/null
        git remote add "$DY_REMOTE" "${DY_PCLONESITE%/*}/$DY_UNAME" &> /dev/null
        git push -f "$DY_REMOTE" "$DY_BRANCH" &> /dev/null
    else
        $DY_GEN_CMD
        git add .
        git commit -m "$COMMENT" &> /dev/null
        git push &> /dev/null
    fi
    # 同步到第二个github帐号
    gh auth switch -u $DY_SUAUTH
    gh repo sync --force $DY_SUAUTH/$DY_SUNAME --source $DY_UAUTH/$DY_UNAME
    gh auth switch -u $DY_UAUTH
    # 返回源目录,并推送源码
    cd "$DY_PATH"
    git add .
    git commit -m "$COMMENT" &> /dev/null
    git push &> /dev/null
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
            DY_PUSHX 0
            ;;
        1|s|S)
            echo -e "\r\e[${NEO_FORMAT}m${DY_PU_INF[1]}\e[0m\033[K"
            if systemctl is-active --quiet caddy ; then
                echo "请访问 http://localhost:4000"
            else
                $DY_SERVE_CMD
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
            "caddy")
                DY_CANDDY
                ;;
        esac
    fi
    if [[ $1 == "--user" ]]; then
        if [[ "$DY_ACTIVE_STATE" != "active" && "$DY_ACTIVE_STATE" != "activating" && $2 == "on" ]]; then
                systemctl $1 start $3
        fi
        if [[ ("$DY_ACTIVE_STATE" == "active" || "$DY_ACTIVE_STATE" == "activating") && $2 == "off" ]]; then
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
        if [[ "$DY_ACTIVE_STATE" != "active" && "$DY_ACTIVE_STATE" != "activating" && $2 == "on" ]]; then
                echo $SYN_KEY_X | sudo -S systemctl start $3
        fi
        if [[ ("$DY_ACTIVE_STATE" == "active" || "$DY_ACTIVE_STATE" == "activating") && $2 == "off" ]]; then
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
# 处理本地模式和远程模式
if [[ $DY_MODEL = "local" ]]; then
    DY_SERVE_SWITCH --root on blog
    DY_SERVE_SWITCH --root on caddy
else
    DY_SERVE_SWITCH --root off blog
    DY_SERVE_SWITCH --root off caddy
fi
# 检测目录并下载
DY_CLONE
# 探测博客网址畅通及同步远程源
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
if [ -z "${DY_DEF+x}" ]; then
    echo "默认文章未设置，设置默认文章启动 ... ..."
    sleep 2
    NEO_LIST "${DY_FILES[*]}" 1
    echo "# 默认文章"                   >> $DY_CFG
    echo "DY_DEF=\"$DY_ART/$EDFILE\""   >> $DY_CFG
    echo "默认文章已经设置为:$EDFILE !"
    exit
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
            echo "默认文章《$DY_DEF》查询失败，重新设置默认文章启动 ... ..."
            sleep 2
            NEO_LIST "${DY_FILES[*]}" 1
            sed -i "s#^DY_DEF=.*#DY_DEF=\"$DY_ART/$EDFILE\"#"   $DY_CFG
            echo "默认文章已经设置为:$EDFILE !"
            exit
        fi
        ;;
    "-TU"|"-tu"|"--ThemeUpdate")
        # ThemeUpdate
        echo "$DY_VERSION 初步切换到hugo构建引擎，暂时不支持hugo-next主题修改，若升级请手动执行升级！"
        ;;
    "-XL"|"-xl")
        NEO_LIST "${DY_SOURC[*]}" 1
        $DY_EDIT "$DY_SOC/$EDFILE/index.md"
        DY_PUSH "$DY_SOC/$EDFILE/index.md" "$EDFILE"
        ;;
    "-C"|"-c"|"--config")
        $DY_EDIT  $DY_STATION_CFG
        echo "主站配置文件修改完毕，请手动执行推送任务：diary -d"
        ;;
    "-C-Next"|"-c-next"|"--config--next")
        $DY_EDIT  $DY_NEXT_CFG
        echo "Next主题配置文件修改完毕，请手动执行推送任务：diary -d"
        ;;
    "--theme"|"--THEME")
        NEO_THEME_SET "NEO_FORMAT"
        ;;
    "-S"|"-s")
        if [[ ${DY_MODEL} == "local" ]]; then
            echo "本地模式正在运行，请直接访问 http://localhost:4000"
            exit
        else
            $DY_SERVE_CMD
        fi
        ;;
    "-D"|"-d")
        DY_PUSHX r
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
            DY_PUSHX r
        else
            printf "\033[${NEO_LINENO};1H\u274E退出: \033[${NEO_WARNING}m《${EDFILE%.*}》\033[0m"
            exit
        fi
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
            NEO_LIST "${DY_TAGS[*]}" 1
            case "$DY_GENERATOR" in
                hugo)
                    hugo new content content/post/${1:-}.md &> /dev/null
                    sed -i "s/^categories:$/categories: [ \"$EDFILE\" ]/g" $DY_DEF
                    ;;
                hexo)
                    hexo n ${1:-}  &> /dev/null
                    sed -i "s/^tags:$/tags: $EDFILE/g" $DY_DEF
                    ;;
            esac
            sed -i "2,/---/{s/---/---\n\n <++>/}"  $DY_DEF
            $DY_EDIT +%s/"<++>"//g "$DY_DEF"
            DY_PUSH  "$DY_DEF"
        fi
        ;;
esac
