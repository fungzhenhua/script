#! /bin/sh
#
# group.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#


a=(feng.git wang.git li.git)
b+=(${a[*]})
c=(${a[@]%.*})
echo ${c[*]}
