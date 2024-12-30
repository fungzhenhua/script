#! /bin/sh
#
# readycmd.sh
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# Date     : 2024-06-14 15:58
# CopyRight: Copyright (C) 2022-2030 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
# Objective: 在不同的发行版中安装命令与软件包名不同的命令
#
# 包管理器列表: 管理器=安装命令
declare -A RD_PKG=(\
    ["pacman"]="pacman -S --needed --confirm"  #arch endeavour manjaro 等
    ["apt-get"]="apt-get -y install"           #debian ubuntu 等
    ["yum"]="yum -y install"                   #redhat centos7 及以下
    ["dnf"]="dnf -y install"                   #fedora centos8
    ["zypper"]="zypper -y install"             #open suse
)
# 待安装软件列表: 命令=软件名， 可以实现配置软件+相应的组件, 测试环境archlinux
declare -A RD_CMD=(\
    ["unar"]="unarchiver" ["ssh"]="openssh"
    ["nvim"]="neovim wget cargo composer php luarocks ruby julia ripgrep fd
    wl-clipboard xclip jdk-openjdk go perl npm"
    ["fcitx5"]="fcitx5-git fcitx5-gtk-git fcitx5-qt5-git fcitx5-qt4-git
    fcitx5-configtool-git fcitx5-chinese-addons-git fcitx5-material-color fcitx5-nord
    fcitx5-qt5-git fcitx5-qt6-git"
    ["python"]="python python-pynvim python-matplotlib python-requests"
    ["thunderbird"]="thunderbird thunderbird-i18n-zh-cn"
    ["libreoffice"]="libreoffice-still libreoffice-still-zh-cn"
    ["zsh"]="zsh nerd-fonts zsh-autosuggestions zsh-completions
    zsh-theme-powerlevel10k zsh-syntax-highlighting-git zoxide exa"
    ["goldendict"]="goldendict-ng-git"
)
# 待安装软件列表：命令
RD_CMD_X=(\
    reflector git curl ark p7zip-natspec lzop lrzip arj zip unzip ntfs-3g vim
    guake calibre zotero mplayer speech-dispatcher
)
# for cmdx in ${RD_CMD_X[@]}; do
#     which ${cmdx} &> /dev/null
#     if [ ! $? = 0 ]; then
#         echo ${cmdx}
#     fi
# done
# 选择发行版中的包管理器
for sh_pkg in ${!RD_PKG[*]}; do
    which $sh_pkg &> /dev/null
    if [ $? = 0 ]; then
        RD_PKG_INS=${RD_PKG[$sh_pkg]}
    fi
done
# 使用发行版中的包管理器安装系统中缺失的命令
for sh_cmd in ${!RD_CMD[*]}; do
    which ${sh_cmd} &> /dev/null
    if [ ! $? = 0 ]; then
        sudo ${RD_PKG_INS} ${RD_CMD[$sh_cmd]}
    fi
done
