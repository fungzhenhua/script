#! /bin/sh
#
# auto.sh
# Copyright (C) 2026 Zhen-hua Feng <fengzhenhua@outlook.com>
#
# Distributed under terms of the MIT license.
#


#!/bin/bash

if [ -n "$DESKTOP_AUTOSTART_ID" ]; then
    # 由 GNOME 自动启动（刚登录时）
    echo "检测到自动启动环境变量，执行初始化命令..."
    # 在这里放置你希望在开机时自动执行的命令
    # 例如：设置环境变量、启动后台服务、加载配置等
else
    # 手动执行（在终端中运行）
    echo "未检测到自动启动变量，执行手动命令..."
    # 在这里放置你手动执行时希望运行的命令
    # 例如：启动应用程序、执行维护任务等
fi

#!/bin/bash
if systemctl is-active --quiet dnsmasq.service; then
    echo "dnsmasq.service is already running. No action taken."
else
    echo "dnsmasq.service is not running. Starting..."
    systemctl start dnsmasq.service
fi
