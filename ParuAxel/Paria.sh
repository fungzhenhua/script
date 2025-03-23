#! /bin/sh
#
# Program: ParuAxel.sh
# Version: V2.0
# Author : Zhen-Hua Feng
# Email  : fengzhenhua@outlook.com
# Date   : 2025-03-24 05:10
# Copyright (C) 2023-2025 feng <feng@arch>
#
# Distributed under terms of the MIT license.
#
GIT_DOMIN=`echo "$2" | cut -f3 -d'/'`;
GIT_OTHER=`echo "$2" | cut -f4- -d'/'`;
GIT_INIT="https://github.com/"
DNS_SERVERS="4.2.2.1,4.2.2.2,4.2.2.3,4.2.2.4,4.2.2.5,4.2.2.6 \
    1.0.0.1,1.0.0.2,1.0.0.3 \
    9.9.9.9,149.112.112.112,149.112.112.9"
GCF=/home/$USER/.gitconfig
GIT_SIT=($(grep -oP '\[url\s+"\Khttps://[^"]+' $GCF))
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
        /usr/bin/aria2c --async-dns-server="$DNS_SERVERS" --split=15 --max-connection-per-server=15 -o "$1" "$GIT_URL" ;
        if [[ $? -ne 0 ]]; then
            echo "[WARN] GitHub 原始地址下载失败，启动镜像检测..."
            if [ -e $GCF ]; then
                GIT_SIT=($(grep -oP '\[url\s+"\Khttps://[^"]+' $GCF))
                for mirror in "${GIT_SIT[@]}"; do
                    if [[ "${mirror}" =~ "/$" ]]; then
                        GIT_URL="${mirror}${GIT_PATH}"
                    else
                        GIT_URL="${mirror}/${GIT_PATH}"
                    fi
                    if mirror_available "${GIT_URL}"; then
                        /usr/bin/aria2c --split=15 --max-connection-per-server=15 -o "$1" "$GIT_URL" ;
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
        /usr/bin/aria2c --split=15 --max-connection-per-server=15 -o "$1" "$2";
        ;;
esac
