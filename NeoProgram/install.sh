#! /bin/bash
#
# Program  : install.sh
# Version  : V2.0
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# Date     : 2025-03-26 01:20
# CopyRight: Copyright (C) 2022-2030 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
#
# 调入私有函数库
source ./Share_Fun/Share_Fun_KeySudo.sh
source ./Share_Fun/Share_Fun_Menu.sh
# 安装函数库到本地
INS_Share_Fun="~/.Share_Fun"
if [ -e "$INS_Share_Fun" ]; then
    rm -rf "$INS_Share_Fun"
fi
cp -r ./Share_Fun "$INS_Share_Fun"
## 安装脚本到指定位置
#------------------------------------------------------------
SYN_INS_Paru(){
    GIT_DEPEND "aria2 cmake"
    SYN_KEY_GET
    echo "$SYN_KEY_X" | sudo -S cp ./makepkg.conf /etc/makepkg.conf
    echo "$SYN_KEY_X" | sudo -S cp ./Paria.sh  /usr/bin/Paria
    echo "$SYN_KEY_X" | sudo -S chmod 755 /usr/bin/Paria
    unset SYN_KEY_X
    echo "Paria 安装成功，paru配置完毕 !! "
}
#------------------------------------------------------------
SYN_INS_Diary(){
    INS_NAME=diary
    INS_EXEPATH=/usr/local/bin
    INS_EXE="$INS_EXEPATH/$INS_NAME"
    GIT_DEPEND "github-cli unzip curl nodejs npm git pandoc gawk sed unzip curl"
    SYN_KEY_GET
    if [[ $(which ssh) == 1 ]]; then
        echo $SYN_KEY_X |sudo -S pacman --needed --noconfirm -S openssh
        echo "请设置您博客的SSH密钥以关联发布网址！"
    fi
    if [[ $(which hexo) == 1 ]]; then echo $SYN_KEY_X |sudo -S yarn global add hexo-cli ;  fi
    echo $SYN_KEY_X |sudo -S cp -f ./diary.sh $INS_EXE
    echo $SYN_KEY_X |sudo -S chmod 755 $INS_EXE
    unset SYN_KEY_X
    echo "${INS_NAME} 安装成功，${INS_NAME}配置完毕 !!"
}
#------------------------------------------------------------
SYN_INS_Weather(){
    INS_NAME=weather
    INS_EXEPATH=/usr/local/bin
    INS_EXE="$INS_EXEPATH/$INS_NAME"
    GIT_DEPEND "gawk sed curl"
    SYN_KEY_GET
    echo $SYN_KEY_X |sudo -S cp -f ./Share_Fun/weather.sh $INS_EXE
    echo $SYN_KEY_X |sudo -S chmod 755 $INS_EXE
    unset SYN_KEY_X
    echo "${INS_NAME} 安装成功，${INS_NAME}配置完毕 !!"
}
#------------------------------------------------------------
SYN_INS_Syndns(){
    INS_NAME=syndns
    INS_EXEPATH=/usr/local/bin
    INS_EXE="$INS_EXEPATH/$INS_NAME"
    GIT_DEPEND "dnsutils inetutils dnsmasq jq"
    SYN_KEY_GET
    echo $SYN_KEY_X |sudo -S cp -f ./syndns.sh $INS_EXE
    echo $SYN_KEY_X |sudo -S chmod 755 $INS_EXE
    unset SYN_KEY_X
    echo "${INS_NAME} 安装成功，${INS_NAME}配置完毕 !!"
}
#------------------------------------------------------------
#
echo "统一安装程序，正在为您安装..."
SYN_INS_Paru
SYN_INS_Diary
SYN_INS_Syndns
SYN_INS_Weather
echo "统一安装程序，安装完毕."
