#! /bin/sh
#
# time.sh
# Copyright (C) 2024 Zhen-hua Feng <fengzhenhua@outlook.com>
#
# Distributed under terms of the MIT license.
#



USB_TIMEOUT=1
USB_TARGET=https://gitee.com

USB_RET_CODE=`curl -I -s --connect-timeout ${USB_TIMEOUT} $USB_TARGET -w %{http_code} | tail -n1`

echo ${USB_RET_CODE}
