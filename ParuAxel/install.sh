#! /bin/sh
#
# 项目：install.sh
# 版本：V1.2
# 功能：解决paru 或yay 无法从https://github.com下载资源的问题
# 注意：脚本ParuAxel重新将https://github.com 定义到了镜像网址，如果失效请打开ParuAxel脚本更换可行的镜像
# 历史：2023-11-27 正式解决问题
# Copyright (C) 2023 feng <feng@arch>
#
# Distributed under terms of the MIT license.
#
# 安装多线程下载工具axel
sudo pacman -S --needed --noconfirm axel &> /dev/null
sudo cp ./makepkg.conf /etc/makepkg.conf
sudo cp ./ParuAxel.sh  /usr/bin/ParuAxel
sudo chmod 755 /usr/bin/ParuAxel
echo "ParuAxel 安装成功，paru配置完毕 !! "
exit
