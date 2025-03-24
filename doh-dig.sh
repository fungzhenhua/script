#! /bin/sh
#
# doh-dig.sh
# Copyright (C) 2025 Zhen-hua Feng <fengzhenhua@outlook.com>
#
# Distributed under terms of the MIT license.
#

# 配置参数
DOH_SERVER="https://1.1.1.1/dns-query"  # 默认 DoH 服务器（Cloudflare）
LOCAL_PROXY_PORT="5353"                 # 本地代理监听端口
TIMEOUT=5                               # 代理启动超时时间（秒）

# 检查依赖工具
check_dependencies() {
    if ! command -v dig &> /dev/null; then
        echo "Error: 'dig' is not installed. Install it with 'apt install dnsutils' or 'yum install bind-utils'."
        exit 1
    fi
    if ! command -v cloudflared &> /dev/null; then
        echo "Error: 'cloudflared' is not installed. Download it from:"
        echo "https://github.com/cloudflare/cloudflared/releases"
        exit 1
    fi
}

# 启动本地 DoH 代理
start_proxy() {
    if ! pgrep -f "cloudflared proxy-dns" > /dev/null; then
        echo "Starting DoH proxy (cloudflared)..."
        cloudflared proxy-dns --port $LOCAL_PROXY_PORT --upstream $DOH_SERVER >/dev/null 2>&1 &
        sleep 2  # 等待代理启动
    fi
}

# 执行 DoH 查询
do_doh_query() {
    dig +nocookie @127.0.0.1 -p $LOCAL_PROXY_PORT "$@"
}

# 主流程
main() {
    check_dependencies
    start_proxy
    if ! pgrep -f "cloudflared proxy-dns" > /dev/null; then
        echo "Error: Failed to start DoH proxy!"
        exit 1
    fi
    do_doh_query "$@"
}

main "$@"
