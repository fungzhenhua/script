#! /bin/sh
#
# Program  : chaos.sh
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# Date     : 2025-08-03 11:57
# CopyRight: Copyright (C) 2022-2030 Zhen-Hua Feng(冯振华)
# License  : Distributed under terms of the MIT license.
# 功能：一键创建结构化 LaTeX 项目，智能管理章节与资源
#
# 注解：本程序之所以用chaos命名，因为在研究生毕业时，某博士导师当众纠正我的发音“Kei-阿丝”为"超丝“，这个纠正是极其错误的，为纪念这一事件，程序命名为chaos.
#
# 调入私有函数库
source "$HOME/.Share_Fun/Share_Fun_Menu.sh"
source "$HOME/.Share_Fun/Share_Fun_KeySudo.sh"
source "$HOME/.Share_Fun/Share_Fun_Weather.sh"
# 保存脚本变量
CH_ARGS=( "$0" "$@" )
# 变量配置
CH_NAME="chaos" ; CH_NAME_SH="chaos.sh" ; CH_VERSION="${CH_NAME}-V1.1"
CH_EXEPATH=/usr/local/bin
CH_EXE="$CH_EXEPATH/$CH_NAME"
CH_SOURCE="$HOME/.chaos"
CH_CFG="$CH_SOURCE/info.sh"
CH_PATH="$PWD"
CH_INSTALL(){
    # 安装依赖
    GIT_DEPEND neovim vim sed
    # 安装脚本
    if [ $0 == $CH_NAME ]; then
        echo "请切换到最新的脚本目录执行: ./chaos.sh -i "
    else
        SYN_KEY_GET
        echo $SYN_KEY_X |sudo -S cp -f $0 $CH_EXE
        echo $SYN_KEY_X |sudo -S chmod 755 $CH_EXE
        echo "${CH_VERSION}成功安装到标准位置$CH_EXEPATH，帮助请执行： diary --help "
    fi
    unset SYN_KEY_X
    exit
}
# 检测是否已经安装
if [[ ! -e $CH_EXE || $1 == "-i" ]]; then
    CH_INSTALL
elif [[ $1 == "-v" || $1 == "-V" ]]; then
    echo $CH_VERSION
    exit
fi
# 建立模板源
if [ ! -e $CH_SOURCE ]; then
    mkdir $CH_SOURCE
fi
if [ ! -e $CH_CFG ]; then
   touch $CH_CFG
   chmod +w $CH_CFG
   echo "#! /bin/sh"               > $CH_CFG
   echo "CH_AUTHOR_ZH=\" \""      >> $CH_CFG
   echo "CH_AUTHOR_EN=\" \""      >> $CH_CFG
   echo "CH_EMAIL=\" \""          >> $CH_CFG
   echo "CH_OCID=\" \""           >> $CH_CFG
   echo "CH_CITY_ZH=\" \""        >> $CH_CFG
   echo "CH_CITY_EN=\" \""        >> $CH_CFG
   echo "CH_POSTCODE=\" \""       >> $CH_CFG
   echo "CH_SCHOOL_ZH=\" \""      >> $CH_CFG
   echo "CH_SCHOOL_EN=\" \""      >> $CH_CFG
   echo "CH_INSTITUTE_ZH=\" \""   >> $CH_CFG
   echo "CH_INSTITUTE_EN=\" \""   >> $CH_CFG
   echo "CH_AFFILIATION_EN=\" \"" >> $CH_CFG
else
    source $CH_CFG
fi
CH_DATE_EN=$(date +"%Y-%m-%d")
CH_DATE_ZH=$(date +"%Y年%m月%d日")
# 读取模板
CH_FILES=($(ls $CH_SOURCE))
# 替换关键字
CH_ADD_INFO(){
    sed -i "s/<+title+>/${CH_ARGS[1]}/" "$2"
    if [[ $1 == "zh" ]]; then
        sed -i "s/<+author+>/$CH_AUTHOR_ZH/" "$2"
        sed -i "s/<+date+>/$CH_DATE_ZH/" "$2"
        sed -i "s/<+city+>/$CH_CITY_ZH/" "$2"
        sed -i "s/<+institute+>/$CH_INSTITUTE_ZH/" "$2"
    else
        sed -i "s/<+author+>/$CH_AUTHOR_EN/" "$2"
        sed -i "s/<+date+>/$CH_DATE_EN/" "$2"
        sed -i "s/<+city+>/$CH_CITY_EN/" "$2"
        sed -i "s/<+institute+>/$CH_INSTITUTE_EN/" "$2"
        sed -i "s/<+affiliation+>/$CH_AFFILIATION_EN/" "$2"
    fi
    sed -i "s/<+email+>/$CH_EMAIL/" "$2"
    sed -i "s/<+orcid+>/$CH_ORCID/" "$2"
    sed -i "s/<+postcode+>/$CH_POSTCODE/" "$2"
}
# 列出模板
NEO_LIST "${CH_FILES[*]}" 1
# 建立文件目录
if [[ ! -e ${CH_ARGS[1]} ]]; then
    cp -r "$CH_SOURCE/$EDFILE" "${CH_PATH}/${CH_ARGS[1]}"
fi
# 分类处理文档
case ${EDFILE} in
    "article")
        CH_TARGET="${CH_PATH}/${CH_ARGS[1]}/${CH_ARGS[1]}.tex"
        mv "${CH_PATH}/${CH_ARGS[1]}/article.tex" "${CH_TARGET}"
        CH_ADD_INFO "en" "${CH_TARGET}"
        ;;
    "ctexart")
        CH_TARGET="${CH_PATH}/${CH_ARGS[1]}/${CH_ARGS[1]}.tex"
        mv "${CH_PATH}/${CH_ARGS[1]}/article.tex" "${CH_TARGET}"
        CH_ADD_INFO "zh" "${CH_TARGET}"
        ;;
    "ctexbeamer")
        CH_TARGET="${CH_PATH}/${CH_ARGS[1]}/${CH_ARGS[1]}.tex"
        mv "${CH_PATH}/${CH_ARGS[1]}/beamer.tex" "${CH_TARGET}"
        CH_ADD_INFO "zh" "${CH_TARGET}"
        ;;
    "ctexbook")
        CH_TARGET="${CH_PATH}/${CH_ARGS[1]}/main/${CH_ARGS[1]}.tex"
        mv "${CH_PATH}/${CH_ARGS[1]}/main/book.tex" "${CH_TARGET}"
        CH_ADD_INFO "zh" "${CH_TARGET}"
        ;;
    *)
        echo "尚未完成模板建设，敬请期待！"
        ;;
esac
