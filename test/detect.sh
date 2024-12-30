#! /bin/sh
#
# detect.sh
# Copyright (C) 2024 Zhen-hua Feng <fengzhenhua@outlook.com>
#
# Distributed under terms of the MIT license.
#

USB_DETECT_URL(){
    wget --spider -T 5 -q -t 2 $1
}

USB_DETECT_URL "https://gitclone.com/github.com/"
USB_DETECT_URL "https://kkgithub.com/"

echo $?
