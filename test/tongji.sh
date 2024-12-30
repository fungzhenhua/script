#! /bin/sh
#
# tongji.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#


str="https://github.com/fengzhenhua/script"
echo $str |sed -e 's/\(.\)/\1\n/g' |grep "/" |wc -l
