#! /bin/sh
#
# Program  : zbftp.sh
# Version  : v1.4
# Date     : 2025-09-22 18:24
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2022-2025 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
# 调入私有函数库
source ~/.Share_Fun/Share_Fun_KeySudo.sh
#
# 定义变量
ZB_NAME=${0%.sh}
ZB_NAME=${ZB_NAME##*/}
ZB_EXE="/usr/local/bin/$ZB_NAME"
ZB_FTP_ARR=( "ftp://2025wuli:2025wuli@192.168.1.15:2180/" "ftp://xkzxz:xkzxz%402020@192.168.1.15:2180/")
ZB_AUTO="$HOME/.config/autostart/$ZB_NAME.desktop"
# 设置自启动
if [ ! -e $ZB_AUTO ]; then
   touch $ZB_AUTO
cat > $ZB_AUTO <<EOF
[Desktop Entry]
Name=$ZB_NAME
TryExec=$ZB_NAME
Exec=$ZB_EXE
Type=Application
Categories=GNOME;GTK;System;Utility;TerminalEmulator;
StartupNotify=true
X-Desktop-File-Install-Version=0.22
X-GNOME-Autostart-enabled=true
Hidden=false
NoDisplay=false
EOF
fi
# 安装并启动FTP
if [ $# -gt 0 ]; then
    if [ $1 == "-i" -o $1 == "-I" ]; then
        GIT_DEPEND curlftpfs
        SYN_KEY_GET
        echo $SYN_KEY_X |sudo -S cp -f $0 $ZB_EXE
        echo $SYN_KEY_X |sudo -S chmod +x $ZB_EXE
        # 清理凭证
        sudo -k
        unset SYN_KEY_X
        exit
    fi
else
    for ZB_ITEM in ${ZB_FTP_ARR[*]}; do
        ZB_FTP_LOCAL=${ZB_ITEM#*//}
        ZB_FTP_LOCAL="$HOME/${ZB_FTP_LOCAL%%:*}"
        if [ ! -e $ZB_FTP_LOCAL ]; then
            mkdir $ZB_FTP_LOCAL
        fi
        mount | grep $ZB_FTP_LOCAL &> /dev/null
        if [[ ! $? == 0 ]]; then
            curlftpfs -o codepage=gbk,allow_other $ZB_ITEM $ZB_FTP_LOCAL
        fi
    done
fi
