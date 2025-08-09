#! /bin/sh
#
# Share_Fun_Install.sh
# Copyright (C) 2025 Zhen-hua Feng <fengzhenhua@outlook.com>
#
# Distributed under terms of the MIT license.
#
source ~/.Share_Fun/Share_Fun_KeySudo.sh
if [[ $SFI_LOADED == "" ]]; then
    #
    SFI_PATH="/usr/local/bin"
    SFI_INSTALL(){
        if [[ $1 == "-i" || $1 == "-I" || $1 == "--install" || $1 == "--INSTALL" ]]; then
            SFI_EXE="$SFI_PATH/${2%.sh}"
            if [ $2 == ${2%.sh} ]; then
                echo "请切换到脚本目录执行: ./$2 -i "
            else
                if [ -e $SFI_EXE ]; then
                    echo -n "${2%.sh}已经存在，是否仍然安装？y/n : "; read SFI_YN
                else
                    SFI_YN=y
                fi
                if [[ $SFI_YN == y || $SFI_YN == Y ]]; then
                    SYN_KEY_GET
                    echo $SYN_KEY_X |sudo -S cp -f $2  $SFI_EXE
                    echo $SYN_KEY_X |sudo -S chmod 755 $SFI_EXE
                    echo "$3 成功安装到标准位置$SFI_PATH !"
                fi
            fi
            unset SYN_KEY_X
            exit
        elif [[ $1 == "-v" || $1 == "-V" || $1 == "--version" || $1 == "--VERSION" ]]; then
            echo $3
            exit
        fi
    }
SFI_LOADED="yes"
fi
# 使用方法
# SFI_INSTALL -i $0
