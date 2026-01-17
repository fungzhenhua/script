#! /bin/sh
#
# seewo.sh
# Copyright (C) 2026 Zhen-hua Feng <fengzhenhua@outlook.com>
#
# Distributed under terms of the MIT license.
#
# Seewo Board Synthesizer: Automated Teaching Whiteboard Content Compiler
#
# 调入私有函数库
source ~/.Share_Fun/Share_Fun_KeySudo.sh
source ~/.Share_Fun/Share_Fun_Install.sh
# 保存脚本变量
SW_ARGS=( "$0" "$@" )
SW_VERSION="${SW_ARGS[0]##*/}-V1.1"
SFI_INSTALL ${SW_ARGS[1]} ${SW_ARGS[0]} $SW_VERSION
GIT_DEPEND imagemagick
# 脚本主程序
OUTNAME=$(basename $PWD)
shopt -s nullglob # 如果没有匹配到文件，通配符返回空
SW_FILES=( "$PWD"/*.png )
shopt -u nullglob # 恢复默认设置
# 如果未发现图片则不执行操作，发现图片则合成pdf
if [ ${#SW_FILES[@]} -gt 0 ]; then
    magick $(ls $PWD/*.png |sort -V) $PWD/${OUTNAME}.pdf
else
    echo "目录内未发现图片，不执行合成操作!"
fi
