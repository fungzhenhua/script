#! /bin/sh
#
# Program  : diary.sh
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# Date     : 2025-08-09 17:50
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
DY_VERSION="${DY_ARGS[0]##*/}-V15.8"
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
DY_IGNORE="$DY_PATH/.gitignore"
DY_HOST="/etc/hosts"
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
        echo "博客的远程地址，如git@github.com:xiaoming/xiaoming.github.io" >> $DY_KEY_CFG
        echo "博客的本地名称，如xiaoming.github.io" >> $DY_KEY_CFG
        echo "Gitlab博客仓库Token，如glpat-t3T_ZzJkcqp45kuiaNiP" >> $DY_KEY_CFG
        echo "gitlab-runner的Token，如GR1248741HKoaT483PhaqA1N894AY" >> $DY_KEY_CFG
        echo "博客发布地址，如https://gitlab.com/" >> $DY_KEY_CFG
        echo "配置文件已经生成在$DY_KEY_CFG, 请打开此文件按说明填写信息!"
        exit
    else
        DY_INFO=($(cat $DY_KEY_CFG))
        DY_PCLONESITE=${DY_INFO[1]}
        DY_PATH=$DY_SOURCE/${DY_INFO[2]}
        DY_URL="https://${DY_INFO[2]}"
        DY_TOKEN=${DY_INFO[3]}
        REGISTRATION_TOKEN=${DY_INFO[4]}
        GITLAB_SIT=${DY_INFO[5]}
    fi
}
#=========================下载博客=========================
DY_CLONE(){
    git  clone $DY_PCLONESITE  $DY_PATH
    if [[ ! -e $DY_IGNORE ]]; then
        touch $DY_IGNORE
        echo ".deploy_git/" > $DY_IGNORE
        echo "public/" >> $DY_IGNORE
        echo "db.json" >> $DY_IGNORE
    fi
    echo "博客源文档目录$DY_PATH已经下载成功，Happy diarying ！"
    exit
}
USB_DETECT_URL(){
    if mirror_available "${DY_URL}"; then
        echo "网络畅通，$DY_VERSION 启动成功!"
        cd $DY_PATH
        git pull &> /dev/null
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
    hexo d
    git add .  &> /dev/null
    git commit  -m  "$COMMENT" &> /dev/null
    git push "$DY_REMOTE" "$DY_BRANCH" &> /dev/null
    gh auth switch -u fongzhenhua
    gh repo sync --force fongzhenhua/fongzhenhua.github.io --source fungzhenhua/fungzhenhua.github.io
    gh auth switch -u fungzhenhua
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
            hexo s
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
#=========================预先配置=========================
# 获取私人信息, 立刻获取各种变量
DY_GET_INF
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
    DY_DEF=${DY_DATAX[1]}
fi
# 检测目录是否下载
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
# 获取日记配置位置
DY_ART="$DY_PATH/source/_posts"
DY_SOC="$DY_PATH/source"
DY_FILES=($(ls $DY_ART))
DY_SOURC=($(ls $DY_SOC))
DY_DEL=(404 PDF Picture _posts tags)
for DEL_LS in ${DY_DEL[*]} ; do
    DY_SOURC=(${DY_SOURC[*]/$DEL_LS})
done
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
        hexo s
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
