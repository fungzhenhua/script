#! /bin/sh
#
# iconfix.sh
# Copyright (C) 2025 Zhen-hua Feng <fengzhenhua@outlook.com>
# Distributed under terms of the MIT license.
# Only for Archlinux
# 调入私有函数库
source ~/.Share_Fun/Share_Fun_KeySudo.sh
# 安装依赖
GIT_DEPEND sed jdk-openjdk
# icon 路径
ICON_PATH=/usr/share/applications
# 替换有问题的图标设置
SYN_KEY_GET     # 获取本机密码
echo $SYN_KEY_X |sudo -S sed -i "/^Icon/c\Icon=java-openjdk" $ICON_PATH/java-java-openjdk.desktop
echo $SYN_KEY_X |sudo -S sed -i "/^Icon/c\Icon=java-openjdk" $ICON_PATH/jshell-java-openjdk.desktop
echo $SYN_KEY_X |sudo -S sed -i "/^Icon/c\Icon=java-openjdk" $ICON_PATH/jconsole-java-openjdk.desktop
echo $SYN_KEY_X |sudo -S sed -i "/^Icon/c\Icon=/usr/share/icons/Singular.png" $ICON_PATH/Singular.desktop
echo $SYN_KEY_X |sudo -S update-desktop-database
echo $SYN_KEY_X |sudo -S update-desktop-database /usr/share/mime
unset SYN_KEY_X # 取消密码
