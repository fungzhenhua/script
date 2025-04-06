#! /bin/bash
#
# 项目：Share_Fun_KeySudo.sh
# 版本：V1.2
# 时间：2025-04-06 20:02
# Copyright (C) 2023 feng <feng@arch>
# Distributed under terms of the MIT license.
#
## 密码存储和管理系统
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
# 初始化包管理器检测（只执行一次）
_PKG_INIT() {
    # 检测包管理器路径
    local PM_PATH=$(command -v apt-get || command -v dnf || command -v yum || command -v pacman || command -v zypper)
    # 使用参数扩展提取二进制名称
    [[ -n "$PM_PATH" ]] && PM_NAME=${PM_PATH##*/} || {
        echo "ERROR: No package manager found" >&2
        return 2
    }
    # 定义包管理参数
    case "$PM_NAME" in
        apt-get)
            _INSTALL_CMD="apt-get install -yq"
            _CHECK_CMD="dpkg -s"
            ;;
        dnf|yum)
            _INSTALL_CMD="$PM_NAME install -y"
            _CHECK_CMD="$PM_NAME list installed"
            ;;
        pacman)
            _INSTALL_CMD="pacman -S --needed --noconfirm"
            _CHECK_CMD="pacman -Qi"
            ;;
        zypper)
            _INSTALL_CMD="zypper -n install"
            _CHECK_CMD="rpm -q"
            ;;
        *)
            echo "Unsupported package manager: $PM_NAME" >&2
            return 3
            ;;
    esac
    # 导出为只读全局变量
    declare -gr PM_NAME
    declare -gr _INSTALL_CMD
    declare -gr _CHECK_CMD
}
# 执行初始化（脚本加载时运行一次）
_PKG_INIT || exit $?
# 检测软件依懒, 若未检测到，则自动安装
GIT_DEPEND(){
    # 获取sudo密码
    SYN_KEY_GET
    # 安装依赖
    for PKG in "$@"; do
        if ! $_CHECK_CMD "$PKG" &>/dev/null; then
            echo "$SYN_KEY_X" | sudo -S $_INSTALL_CMD "$PKG"
            local INSTALL_STATUS=$?
            # 处理Arch系更新问题
            if [[ $PM_NAME == "pacman" && $INSTALL_STATUS -ne 0 ]]; then
                echo "$SYN_KEY_X" | sudo -S pacman -Sy && \
                    echo "$SYN_KEY_X" | sudo -S $_INSTALL_CMD "$PKG"
            fi
        fi
    done
    # 清理凭证
    sudo -k
    unset SYN_KEY_X
}
# 探测网址是否连通
mirror_available() {
    local url="$1"
    if curl -fsL --max-time 5 --head "$url" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}
