#! /bin/sh
#
# ss.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#
# /home/feng/BNU-FZH@UGIT/hello
#
USB_LOCAL_UUID=3e94476e-727c-4f5d-9a3b-af276a1e3b9a 
USB_TEMP_ID=16146837
# echo "$USB_LOCAL_UUID $USB_TEMP_ID"
# sed  -i "/$USB_LOCAL_UUID $USB_TEMP_ID/d" ./uregister
sed  "s#/home/feng/BNU-FZH@UGIT/hello#delete#g" ./uregister
