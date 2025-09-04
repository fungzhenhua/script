#! /bin/sh
#
# Program  : zbftp.sh
# Version  : v1.0
# Date     : 2025-09-04 18:29
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2022-2025 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
# 调入私有函数库
source ~/.Share_Fun/Share_Fun_KeySudo.sh
#
# 定义变量
ZB_EXE="/usr/local/bin/${0%.sh}"
ZB_FTP_REMOTE="ftp://2025wuli:2025wuli@192.168.1.15:2180/"
ZB_FTP_LOCAL="$HOME/ZBFTP"
# 检查建立目录
if [ ! -e $ZB_FTP_LOCAL ]; then
    mkdir $ZB_FTP_LOCAL
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
    curlftpfs -o codepage=gbk,allow_other $ZB_FTP_REMOTE $ZB_FTP_LOCAL
fi
