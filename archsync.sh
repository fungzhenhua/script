#! /bin/sh
#
# Program  : archsync.sh
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# Date     : 2026-10-30 01:01
# CopyRight: Copyright (C) 2022-2030 Zhen-Hua Feng(冯振华)
# License  : Distributed under terms of the MIT license.
# Version  : V1.0
# History  :
#           V1.0 2026-10-30 01:05 初步完成ArchLinux系统下pacman的离线升级, 相互校检需要增强
#
# 调入私有函数库
source ~/.Share_Fun/Share_Fun_Menu.sh
source ~/.Share_Fun/Share_Fun_KeySudo.sh
source ~/.Share_Fun/Share_Fun_Install.sh
#
# 脚本变量
ASY_PACMAN_PKG="/var/cache/pacman/pkg"
ASY_PACMAN_SYNC="/var/lib/pacman/sync"
ASY_MACHINE_ID="$(cat /etc/machine-id)@$(LC_ALL=C date +"%Y-%m-%d")"
ASY_LOCAL="arch_update"
ASY_PACMAN="$ASY_LOCAL/pacman_update"
# 检测是否插入U盘，插入则建立U盘内容列表
USB_REMORT="/run/media/$USER" # udisks2 默认u盘挂载点
unset USB_ARR
if [ -e $USB_REMORT ]; then
    USB_ARR=($(lsblk -o UUID,MOUNTPOINT | grep "/run/media/"|awk '{print $2}'))
fi
if [[ "${#USB_ARR[*]}" -eq 0 ]]; then
    echo "${USB_VERSION} 未检测到U盘， 请插入U盘后重试!"
    exit
fi
# 执行任务
case ${1:-} in
    "-b"|"-B"|"-build")
        # 创建升级源：用本地软件库创建升级源
        NEO_LIST "${USB_ARR[*]}" 1
        ASY_SOURCE="$EDFILE/$ASY_PACMAN"
        # 如果本地缓存目录不存在则新建
        if [ ! -e $ASY_SOURCE ]; then
            mkdir -p $ASY_SOURCE
        fi
        SYN_KEY_GET
        echo $SYN_KEY_X |sudo cp $ASY_PACMAN_PKG/*.pkg.tar.zst $ASY_SOURCE/
        echo $SYN_KEY_X |sudo cp $ASY_PACMAN_SYNC/*.db         $ASY_SOURCE/
        unset SYN_KEY_X
        echo "本地Pacman缓存创建成功!"
        ;;
    *)
        # 离线升级：逐盘检测是否存在缓存升级目录, 如果检测到则询问是否执行升级
        i=0
        while [[ $i -lt "${#USB_ARR[*]}" ]]; do
            ASY_ARR=($(ls ${USB_ARR[$i]}))
            if [[ "${ASY_ARR[@]}" =~ "$ASY_LOCAL" ]]; then                             # 前者包含后者
                echo -n "检测到升级缓存盘 ${USB_ARR[$i]}, 是否选择 Y/N "; read YES_NO  # 列出目录供用户选择
                if [[ "$YES_NO" =~ ^[yY]$ ]]; then
                    if [ ! -e "${USB_ARR[$i]}/$ASY_LOCAL/$ASY_MACHINE_ID" ]; then      # 只在第一次执行时备份此目录
                        mkdir ${USB_ARR[$i]}/$ASY_LOCAL/$ASY_MACHINE_ID
                        SYN_KEY_GET
                        echo $SYN_KEY_X |sudo cp $ASY_PACMAN_PKG/*.pkg.tar.zst ${USB_ARR[$i]}/$ASY_LOCAL/$ASY_MACHINE_ID/
                        echo $SYN_KEY_X |sudo cp $ASY_PACMAN_SYNC/*.db         ${USB_ARR[$i]}/$ASY_LOCAL/$ASY_MACHINE_ID/
                        unset SYN_KEY_X
                        echo "本地Pacman缓存备份完毕!"
                    fi
                    SYN_KEY_GET
                    echo $SYN_KEY_X |sudo cp ${USB_ARR[$i]}/$ASY_PACMAN/*.pkg.tar.zst $ASY_PACMAN_PKG/
                    echo $SYN_KEY_X |sudo cp ${USB_ARR[$i]}/$ASY_PACMAN/*.db          $ASY_PACMAN_SYNC/
                    echo $SYN_KEY_X |sudo pacman -Su
                    unset SYN_KEY_X
                    break
                else
                    echo "未执行任何操作，安全退出!"
                    exit
                fi
            fi
            let i+=1
        done
        ;;
esac
