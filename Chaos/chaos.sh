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
if [ ! -e $CH_SOURCE ]; then
    mkdir $CH_SOURCE
fi
