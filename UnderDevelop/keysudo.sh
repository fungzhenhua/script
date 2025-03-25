#! /bin/bash
#
# keysudo.sh
# Copyright (C) 2025 Zhen-hua Feng <fengzhenhua@outlook.com>
#
# Distributed under terms of the MIT license.
#
#########################################
#            安全使用说明               #
#########################################
## 使用后立即清理变量
##   syndns_password=$(./keysudo.sh)
##  ...使用密码...
##  unset syndns_password
# ----------------------------------------
### 脚本依赖
##    Arch Linux: pambase + libsecret
##    RHEL/CentOS: pam + libsecret-tools
# ----------------------------------------
#
# 定义标识符
SYN_KEY="syndns_password"  # 密钥环中的唯一标识符
SYN_SUDO_NUM_MAX="3"       # 确保这个数值与您系统中sudo验证次数一致，以免进入死循环
# 检测依赖，确保secret-tool正确安装
if ! command -v secret-tool &>/dev/null; then
  echo "错误：需要安装 secret-tool（包名：libsecret-tools）" >&2
  exit 1
fi
# 探测系统sud解锁程序
SYN_RES_CMD=""
if command -v faillock &>/dev/null; then
    SYN_RES_CMD="faillock --user $USER --reset"
elif command -v pam_tally2 &>/dev/null; then
    SYN_RES_CMD="pam_tally2 --user $USER --reset"
else
    echo "错误：未找到可用SUDO解锁工具 !" >&2
    echo "请安装：Arch系安装pambase，RHEL系安装pam" >&2
    exit 1  # 正确终止脚本
fi
# 存储密码到 GNOME Keyring
# 测试密码过程中存在sudo次数限制，如果sudo被锁定了，那本脚本在首次没有完成密码保存的工作后将处于锁定状态
SYN_KEY_GET(){
    local SYN_AMT="$SYN_SUDO_NUM_MAX"
    while [[ "$SYN_AMT" -gt 0 ]]; do
        SYN_KEY_X=$(secret-tool lookup syndns_password_key "$SYN_KEY")
        if [[ -z "$SYN_KEY_X" ]]; then
            unset SYN_KEY_DATA
            # 使用专业密码输入工具
            if command -v systemd-ask-password &>/dev/null; then
                SYN_KEY_DATA=$(systemd-ask-password --timeout=30 "请求sudo密码:")
            else
                printf "$0 请求输入sudo密码(30秒超时):" >&2
                # 增加超时后的清理逻辑
                if ! read -rs -t 30 SYN_KEY_DATA; then
                    printf "\n输入超时，操作取消。\n" >&2
                    unset SYN_KEY_DATA
                    exit 1
                fi
            fi
            if [[ -z "$SYN_KEY_DATA" ]]; then
                printf "\n密码不能为空，请重新输入。\n" >&2
            else
                if printf "%s" "$SYN_KEY_DATA" | secret-tool store --label="Syndns Password" syndns_password_key "$SYN_KEY"; then
                    sudo -k
                    if printf "%s" "$SYN_KEY_DATA" | sudo -S -v 2>/dev/null; then
                        # 存储成功后立即清理
                        unset SYN_KEY_DATA
                        printf "\n密码已成功存储到 GNOME Keyring 中。\n" >&2
                        return 0
                    else
                        SYN_AMT=$((SYN_AMT - 1))
                        SYN_FAIL_RES "警告：当前系统可能需要手动重置失败计数!"
                    fi
                else
                    printf "\n无法存储密码，请检查 GNOME Keyring 是否可用。\n" >&2
                    exit 1
                fi
            fi
        else
            sudo -k
            if ! printf "%s" "$SYN_KEY_X" | sudo -S -v 2>/dev/null; then
                SYN_AMT=$((SYN_AMT - 1))
                secret-tool clear syndns_password_key "$SYN_KEY" # 清空密码，重新循环才能进入设置
                SYN_FAIL_RES "警告：当前系统可能需要手动重置失败计数!"
            else
                return 0
            fi
        fi
    done
    printf "尝试次数已达上限，操作终止。\n" >&2
    SYN_FAIL_RES "请切换至ROOT权限解除锁定: $SYN_RES_CMD"
    exit 1
}
SYN_FAIL_RES(){
    if grep -qi 'arch' /etc/os-release 2>/dev/null; then
        faillock --user $USER --reset
    else
        # 优先显示传入的定制化提示
        printf "$1 \n" >&2
        # 补充建议命令（带sudo前缀）
        [ -n "$SYN_RES_CMD" ] && echo "可尝试执行: sudo $SYN_RES_CMD" >&2
    fi
}
sudo -k  # 清除sudo缓存
# secret-tool clear syndns_password_key "$SYN_KEY"
SYN_KEY_GET
echo $SYN_KEY_X
