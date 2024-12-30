#! /bin/sh
#
# enter.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#
echo "Hit enter for default directory or insert a new directory"
read var
# if [[ $var = $'\0A' ]]; then
if [[ -z $var ]]; then
    echo "Default directory"
else
    echo "New directory: $var"
fi
