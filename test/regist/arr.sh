#! /bin/sh
#
# arr.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#


# declare -A arr
USB_HOME_ID=$(lsblk -o UUID,MOUNTPOINT | grep "/home"|awk '{print $1}')
ls -lid $HOME/*@UGIT/*|awk '{print $1 " " $9 }' | sed "s/^/"$USB_HOME_ID" &/g" > ./reg
# lsblk -o UUID,MOUNTPOINT | grep "/run/media/"|awk '{print $1 " " $2}'
