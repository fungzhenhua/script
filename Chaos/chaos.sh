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
# # 变量配置
CH_NAME=tch ; CH_NAME_SH="texchief.sh" ; CH_VERSION="${CH_NAME-V1.0}"
CH_SOURCE="$HOME/.chaos"
CH_CFG="$CH_SOURCE/.CH_DATA"
# CH_PATH="$PWD"
CH_PATH="./test"
if [ ! -e $CH_SOURCE ]; then
    mkdir $CH_SOURCE
fi
if [ ! -e $CH_CFG ]; then
   touch $CH_CFG 
   chmod +w $CH_CFG
   echo "个人信息配置：注意下面直接按示例填写配置信息，去掉第1行之外的所有中文!!" > $CH_CFG
   echo "作者：" >> $CH_CFG
else
    CH_INFO=($(cat $CH_CFG))
    CH_AUTHOR=${CH_INFO[1]}
fi
CH_DATE=$(date +"%Y-%m-%d")
DY_FILES=($(ls $CH_SOURCE))

# 列出模板
NEO_LIST "${DY_FILES[*]}" 1

# 建立文件目录
if [[ ! -e $1 ]]; then
    cp -r "$CH_SOURCE/$EDFILE" "${CH_PATH}/$1"
fi

# 分类处理文档
case ${EDFILE} in
    "Article")
        CH_TARGET="${CH_PATH}/$1/${1}.tex"
        mv "${CH_PATH}/$1/article.tex" "${CH_TARGET}"
        sed -i "s/<+title+>/$1/" ${CH_TARGET}
        sed -i "s/<+author+>/${CH_AUTHOR}/" ${CH_TARGET}
        sed -i "s/<+date+>/${CH_DATE}/" ${CH_TARGET}
        ;;
    "Book")
        echo "book!"
        ;;
esac
