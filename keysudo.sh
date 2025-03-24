#! /bin/sh
#
# keysudo.sh
# Copyright (C) 2025 Zhen-hua Feng <fengzhenhua@outlook.com>
#
# Distributed under terms of the MIT license.
#
# 定义标识符
SYN_KEY="syndns_password"  # 密钥环中的唯一标识符
MAX_ATTEMPTS=3              # 最大重试次数
# 存储密码到 GNOME Keyring
SYN_KEY_GET(){
    SYN_KEY_X=$(secret-tool lookup syndns_password_key "$SYN_KEY")
    if [[ -z "$SYN_KEY_X" ]]; then
        # 清空密码
        secret-tool clear syndns_password_key "$SYN_KEY"
        while true; do
            read -sp "请输入sudo密码：" SYN_KEY_DATA
            if [[ -z "$SYN_KEY_DATA" ]]; then
                echo -e "\n密码不能为空，请重新输入。"
            else
                break
            fi
        done
        echo "$SYN_KEY_DATA" | secret-tool store --label="Syndns Password" syndns_password_key "$SYN_KEY"
        if [[ $? == 0 ]]; then
            SYN_KEY_VERIFY "$SYN_KEY_DATA"
            echo -e "\n密码已成功存储到 GNOME Keyring 中。"
        else
            echo -e "\n无法存储密码，请检查 GNOME Keyring 是否可用。"
            exit 1
        fi
    else
        SYN_KEY_VERIFY "$SYN_KEY_X"
    fi
}
SYN_KEY_VERIFY(){
    sudo -k
    echo "$1" | sudo -lS &> /dev/null
    if [[ $? != 0 ]]; then
        SYN_KEY_GET
    else
        echo "$1"
    fi
}
# secret-tool clear syndns_password_key "$SYN_KEY"
SYN_KEY_GET
# echo $SYN_KEY_X
