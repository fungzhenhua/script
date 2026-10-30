#! /bin/sh
#
# Program  : archsync.sh
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# Date     : 2026-10-30 01:01
# CopyRight: Copyright (C) 2022-2030 Zhen-Hua Feng(冯振华)
# License  : Distributed under terms of the MIT license.
# History  :
#           V1.0 2026-10-30 01:05 初步完成ArchLinux系统下pacman的离线升级, 相互校检需要增强
#           V1.1 2026-10-30 01:12 增加版本显示
#           V1.2 2026-10-30 15:30 增加机器码校检，并以机器码+标记方式命名缓存仓库
#           V1.3 2026-10-30 15:53 增加多源选择机制
#           V1.4 2026-10-30 19:58 增加源备份机制
#           V1.5 2026-10-30 20:07 修复若干bug
#           V1.6 2026-10-30 20:37 增加升级前是否更新过的检测
#           V1.7 2026-10-30 20:43 增强cp健壮性
#           V1.8 2026-10-30 20:50 增加脚本安装程序
#
# 调入私有函数库
source ~/.Share_Fun/Share_Fun_Menu.sh
source ~/.Share_Fun/Share_Fun_KeySudo.sh
source ~/.Share_Fun/Share_Fun_Install.sh
#
# 脚本版本号
ASY_VERSION="V1.8"
# 保存脚本变量
ASY_ARGS=( "$0" "$@" )
DY_VERSION="${ASY_ARGS[0]##*/}-$ASY_VERSION"
#=========================安装脚本=========================
SFI_INSTALL ${ASY_ARGS[1]} ${ASY_ARGS[0]} $DY_VERSION
# 脚本变量
ASY_PACMAN_PKG="/var/cache/pacman/pkg"
ASY_PACMAN_SYNC="/var/lib/pacman/sync"
ASY_MACHINE_ID="$(cat /etc/machine-id)@$(date +%s)"
ASY_LOCAL="arch_update"
# 检测发行版, 当前只支持ArchLinux缓存升级
source /etc/os-release
if [ "${ID:-}" != "arch" ]; then
    echo "非ArchLinux系统, 暂不支持离线升级!"
    exit 1
fi
# 检测是否插入U盘，插入则建立U盘内容列表
USB_REMORT="/run/media/$USER" # udisks2 默认u盘挂载点
unset USB_ARR
if [ -e $USB_REMORT ]; then
    USB_ARR=($(lsblk -o UUID,MOUNTPOINT | grep "/run/media/"|awk '{print $2}'))
fi
if [[ "${#USB_ARR[*]}" -eq 0 ]]; then
    echo "${ASY_VERSION} 未检测到U盘， 请插入U盘后重试!"
    exit 1
fi
# 执行任务
case ${1:-} in
    "-v"|"-V"|"--version")
        echo $ASY_VERSION
        ;;
    "-b"|"-B"|"-build")
        # 检测 sync 数据库签名是否完整
        if ! compgen -G "$ASY_PACMAN_SYNC/*.db.sig" >/dev/null; then
            echo "检测到 sync 数据库缺少签名文件，将执行 sudo pacman -Syu 强制同步..."
            SYN_KEY_GET
            echo $SYN_KEY_X | sudo pacman -Syu
            rc=$?
            unset SYN_KEY_X
            if [ $rc -ne 0 ]; then
                echo "pacman -Syu 失败，请检查网络后重试"
                exit 1
            fi
            # 复查：sync 后仍无 .db.sig 说明是 SigLevel = Never 的仓库
            if ! compgen -G "$ASY_PACMAN_SYNC/*.db.sig" >/dev/null; then
                echo "警告：同步后仍无 .db.sig，可能是 SigLevel = Never 的自定义仓库"
                echo "继续将只复制 .db 文件，B 机若要求数据库签名将无法使用"
                printf "是否继续 Y/N "; read YES_NO
                [[ "$YES_NO" =~ ^[yY]$ ]] || exit 0
            fi
        else
            echo "重要提醒！建议创建离线升级源前执行更新：sudo pacman -Syu"
        fi
        # 创建升级源：用本地软件库创建升级源
        NEO_LIST "${USB_ARR[@]}" 1
        ASY_SOURCE="$EDFILE/$ASY_LOCAL/$(cat /etc/machine-id)_SOURCE"
        # 如果本地缓存目录不存在则新建
        if [ -e "$ASY_SOURCE" ]; then
            printf "\n早些时间的源已存在，是否需要备份 Y/N "; read YES_NO  # 列出目录供用户选择
            if [[ "$YES_NO" =~ ^[yY]$ ]]; then
                mv -T "$ASY_SOURCE" "${ASY_SOURCE%/*}/$(date +%s)@${ASY_SOURCE##*/}"
            else
                rm -rf -- "$ASY_SOURCE"
            fi
        fi
        mkdir -p "$ASY_SOURCE"
        # 检测本机是否达到最新状态
        echo "复制Pacman缓存到$ASY_SOURCE"
        SYN_KEY_GET
        echo $SYN_KEY_X |sudo cp "$ASY_PACMAN_PKG"/*.pkg.tar.zst "$ASY_SOURCE"/
        echo $SYN_KEY_X |sudo cp "$ASY_PACMAN_SYNC"/*.db  "$ASY_SOURCE"/
        compgen -G "$ASY_PACMAN_SYNC/*.db.sig" >/dev/null && \
            echo $SYN_KEY_X |sudo cp  "$ASY_PACMAN_SYNC"/*.db.sig "$ASY_SOURCE"/
        unset SYN_KEY_X
        echo "本地Pacman缓存创建成功!"
        ;;
    *)
        # 离线升级：逐盘检测是否存在缓存升级目录, 如果检测到则询问是否执行升级
        i=0
        while [[ $i -lt "${#USB_ARR[*]}" ]]; do
            if [ -d "${USB_ARR[$i]}/$ASY_LOCAL" ]; then                             # 前者包含后者
                # 选择源, 使用for而不是ls因为，若使用ls, 则匹配*_SOURCE时，若没有对应量，会有一个字面意思的*_SOURCE
                ASY_SOURCES=()
                for s in "${USB_ARR[$i]}/$ASY_LOCAL"/*_SOURCE; do
                    if [ -d "$s" ] && [[ "${s##*/}" !=  *$(cat /etc/machine-id)_SOURCE* ]]; then # 排除本机自升级
                        ASY_SOURCES+=("$s")
                    fi
                done
                case ${#ASY_SOURCES[@]} in
                    0)
                        echo "本盘未找到升级源，退出!"
                        let i+=1; continue
                        ;;
                    1)
                        ASY_SOURCE="${ASY_SOURCES[0]}"
                        ;;
                    *)
                        NEO_LIST "${ASY_SOURCES[@]}" 1
                        ASY_SOURCE="$EDFILE"
                        ;;
                esac
                printf "\n检测到升级缓存盘 ${USB_ARR[$i]}, 是否选择 Y/N "; read YES_NO  # 列出目录供用户选择
                if [[ "$YES_NO" =~ ^[yY]$ ]]; then
                    ASY_PACMAN_BAK="${USB_ARR[$i]}/$ASY_LOCAL/$ASY_MACHINE_ID"
                    if [ ! -e  "$ASY_PACMAN_BAK" ]; then                                # 只在第一次执行时备份此目录
                        mkdir -p "$ASY_PACMAN_BAK"
                        SYN_KEY_GET
                        echo $SYN_KEY_X |sudo cp "$ASY_PACMAN_PKG"/*.pkg.tar.zst "$ASY_PACMAN_BAK"/
                        echo $SYN_KEY_X |sudo cp "$ASY_PACMAN_SYNC"/*.db "$ASY_PACMAN_BAK"/
                        compgen -G "$ASY_PACMAN_SYNC/*.db.sig" >/dev/null && \
                            echo $SYN_KEY_X |sudo cp "$ASY_PACMAN_SYNC"/*.db.sig "$ASY_PACMAN_BAK"/
                        unset SYN_KEY_X
                        echo "本地Pacman缓存备份完毕!"
                    fi
                    SYN_KEY_GET
                    echo $SYN_KEY_X |sudo cp "$ASY_SOURCE"/*.pkg.tar.zst "$ASY_PACMAN_PKG"/
                    echo $SYN_KEY_X |sudo cp "$ASY_SOURCE"/*.db "$ASY_PACMAN_SYNC"/
                    compgen -G "$ASY_SOURCE/*.db.sig" >/dev/null && \
                        echo $SYN_KEY_X |sudo cp "$ASY_SOURCE"/*.db.sig "$ASY_PACMAN_SYNC"/
                    echo $SYN_KEY_X |sudo pacman -Su
                    unset SYN_KEY_X
                    break
                else
                    echo "未执行任何操作，安全退出!"
                    exit 0
                fi
            fi
            let i+=1
        done
        ;;
esac
