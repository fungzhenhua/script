#! /bin/sh
#
# kersg.sh
# Copyright (C) 2025 Zhen-hua Feng <fengzhenhua@outlook.com>
#
# Distributed under terms of the MIT license.
#
# 定义标识符
SYN_KEY="syndns_password"  # 密钥环中的唯一标识符
# 存储密码到 GNOME Keyring
SYN_KEY_SET() {
    SYN_KEY_CLEAR  # 清除旧密码（如果有）
    read -sp "请输入sudo密码：" SYN_KEY_DATA
    echo "$SYN_KEY_DATA" | secret-tool store --label="Syndns Password" syndns_password_key "$SYN_KEY"
    if [[ $? == 0 ]]; then
        echo -e "\n密码已成功存储到 GNOME Keyring 中。"
    else
        echo -e "\n无法存储密码，请检查 GNOME Keyring 是否可用。"
        exit 1
    fi
}
# 从 GNOME Keyring 读取密码
SYN_KEY_GET() {
    SYN_KEY_X=$(secret-tool lookup syndns_password_key "$SYN_KEY")
    if [[ -z "$SYN_KEY_X" ]]; then
        echo "无法从 GNOME Keyring 中读取密码，请重新设置密码。"
        SYN_KEY_SET
    else
        echo "$SYN_KEY_X"
    fi
}
# 删除 GNOME Keyring 中的密码
SYN_KEY_CLEAR() {
    secret-tool clear syndns_password_key "$SYN_KEY"
    if [[ $? == 0 ]]; then
        echo "密码已从 GNOME Keyring 中删除。"
    else
        echo "无法删除密码，请检查 GNOME Keyring 是否可用。"
    fi
}
# 验证密码
SYN_KEY_VERIFY() {
    SYN_KEY_X=$(SYN_KEY_GET)
    sudo -k
    echo "$SYN_KEY_X" | sudo -lS &> /dev/null
    if [[ $? != 0 ]]; then
        echo -e "\n密码验证失败。"
        while true; do
            read -p "是否要重新设置密码？[y/N] " CHOICE
            if [[ "$CHOICE" == "y" || "$CHOICE" == "Y" ]]; then
                SYN_KEY_SET
                break
            elif [[ "$CHOICE" == "n" || "$CHOICE" == "N" || -z "$CHOICE" ]]; then
                echo "取消操作，退出程序。"
                exit 1
            else
                echo "无效输入，请输入 y 或 n。"
            fi
        done
    else
        echo -e "\n密码验证成功。"
    fi
}
# 初始化
SYN_KEY_CLEAR

# SYN_KEY_VERIFY
