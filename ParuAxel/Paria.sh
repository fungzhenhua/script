#! /bin/sh
#
# Program: Paria.sh
# Version: V2.1
# Author : Zhen-Hua Feng
# Email  : fengzhenhua@outlook.com
# Date   : 2025-03-24 11:45
# Copyright (C) 2023-2025 feng <feng@arch>
#
# Distributed under terms of the MIT license.
#
# 取得基本信息
GIT_DOMIN=`echo "$2" | cut -f3 -d'/'`;
GIT_OTHER=`echo "$2" | cut -f4- -d'/'`;
GIT_INIT="https://github.com/"
DNS_SERVERS="4.2.2.1,4.2.2.2,4.2.2.3,4.2.2.4,4.2.2.5,4.2.2.6 \
    1.0.0.1,1.0.0.2,1.0.0.3 \
    9.9.9.9,149.112.112.112,149.112.112.9"
GCF=/home/$USER/.gitconfig
GIT_SIT=($(grep -oP '\[url\s+"\Khttps://[^"]+' $GCF))
# 取得sudo密码, 这部分不加密有风险
SYN_KEY="$HOME/.syndns_conf"
SYN_KEY_SET(){
    if [[ ! -e $SYN_KEY ]]; then
        touch $SYN_KEY
        read -p "请输入sudo密码：" SYN_KEY_DATA
        echo "$SYN_KEY_DATA"|base64 -i | tee $SYN_KEY
    fi
    SYN_KEY_X=$(echo $(cat $SYN_KEY)| base64 -d)
    sudo -k
    echo $SYN_KEY_X | sudo -lS &> /dev/null
    if [[ $? != 0 ]]; then
        SYN_KEY_SET
    fi
}
SYN_KEY_SET
# 检测软件依懒, 若未检测到，则自动安装
GIT_DEPEND(){
    for VAR in $1 ;do
        pacman -Qq "$VAR" &> /dev/null
        if [[ $? != 0 ]]; then
           echo "$SYN_KEY_X" | sudo -S pacman -S --needed --noconfirm "$VAR"
        fi
    done
}
GIT_DEPEND "aria2 cmake"
# 定义处理程序
mirror_available() {
    local url="$1"
    if curl -fsL --max-time 5 --head "$url" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}
case "$GIT_DOMIN" in
    "github.com")
        GIT_URL="$2"
        echo "Download from mirror $GIT_URL";
        /usr/bin/aria2c --async-dns-server="$DNS_SERVERS" --split=12 --max-connection-per-server=15 -k 1M --auto-file-renaming=false -o "$1" "$GIT_URL" ;
        if [[ $? -ne 0 ]]; then
            echo "[WARN] GitHub 原始地址下载失败，启动镜像检测..."
            if [ -e $GCF ]; then
                GIT_SIT=($(grep -oP '\[url\s+"\Khttps://[^"]+' $GCF))
                for mirror in "${GIT_SIT[@]}"; do
                    if [[ "${mirror}" =~ "/$" ]]; then
                        GIT_URL="${mirror}${GIT_OTHER}"
                    else
                        GIT_URL="${mirror}/${GIT_OTHER}"
                    fi
                    if mirror_available "${GIT_URL}"; then
                        /usr/bin/aria2c --split=12 --max-connection-per-server=15 -k 1M --auto-file-renaming=false -o "$1" "$GIT_URL" ;
                        if [[ $? -eq 0 ]]; then
                            exit 0  # 下载成功则退出
                        else
                            echo "[ERROR] 镜像下载失败: $GIT_URL (状态码: $?)" >&2
                        fi
                    fi
                done
            fi
            # 所有镜像失败后直接退出（不回退 GitHub）
            echo "[FATAL] 所有下载尝试失败，请检查网络或镜像配置"
            exit 1
        fi
        ;;
    *)
        /usr/bin/aria2c --split=12 --max-connection-per-server=15 -k 1M --auto-file-renaming=false -o "$1" "$2" ;
        ;;
esac
