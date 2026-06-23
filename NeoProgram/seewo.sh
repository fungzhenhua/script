#! /bin/sh
#
# Program  : seewo.sh
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# Date     : 2026-06-23 11:02
# CopyRight: Copyright (C) 2026-2030 Zhen-Hua Feng(冯振华)
# License  : Distributed under terms of the MIT license.
# Seewo Board Synthesizer: Automated Teaching Whiteboard Content Compiler
#
# 调入私有函数库
source ~/.Share_Fun/Share_Fun_KeySudo.sh
source ~/.Share_Fun/Share_Fun_Install.sh
# 保存脚本变量
SW_ARGS=( "$0" "$@" )
SW_VERSION="${SW_ARGS[0]##*/}-V1.7"
SFI_INSTALL ${SW_ARGS[1]} ${SW_ARGS[0]} $SW_VERSION
GIT_DEPEND imagemagick
# 输出PDF文件命名
if [[ ${SW_ARGS[1]} == "" ]] ; then
    OUTNAME=${PWD##*/}
else
    OUTNAME=${SW_ARGS[1]}
fi
shopt -s globstar nullglob # globstar 确保目录穿透深度，nullglob 确保没有匹配到文件，通配符返回空
SW_FILES=( **/*.{png,jpg,jpeg} )
shopt -u globstar nullglob # 恢复默认设置
# 如果未发现图片则不执行操作，发现图片则合成pdf
if [ ${#SW_FILES[@]} -gt 0 ]; then
    readarray -t sorted < <(printf '%s\n' "${SW_FILES[@]}" | sort -V)
    magick "${sorted[@]}" "./${OUTNAME}.pdf"
else
    echo "当前目录及各级子目录内均未发现PNG、JPG和JPEG格式图片，不执行合成操作!"
fi
