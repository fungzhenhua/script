#! /bin/sh
#
# Program  : weather.sh
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2022-2025 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
# Version  : V3.0
# Date     : 2025-03-26 00:42
#
# 调入私有函数库
source ~/.Share_Fun/Share_Weather.sh
# 输出天气、地址信息
if [ $# -gt 0 ]; then
   if [ $1 == "-I" -o $1 == "-i" -o $1 == "--install" ]; then
      sudo cp -f $0 $WTPath
      sudo chmod 755 $WTPath
   elif [ $1 == "-U" -o $1 == "-u" ]; then
      SelfUpdate
   elif [ $1 == "-F" -o $1 == "-f" ]; then
      GetNetWeather
   elif [ $1 == "-A" -o $1 == "-a" ]; then
      echo -n $Adprovince
   elif [ $1 == "-C" -o $1 == "-c" ]; then
      echo -n $AdCity
   elif [ $1 == "-W" -o $1 == "-w" ]; then
      echo -n $AdWeather
   elif [ $1 == "-D" -o $1 == "-d" ]; then
      echo -n "$CWTDate"
   elif [ $1 == "-dcw" -o $1 == "-DCW" ]; then
      echo -n "$CWTDate $AdCity $AdWeather"
   elif [ $1 == "-dwc" -o $1 == "-DWC" ]; then
      echo -n "$CWTDate $AdWeather $AdCity"
   elif [ $1 == "-cwd" -o $1 == "-CWD" ]; then
      echo -n "$AdCity $AdWeather $CWTDate"
   elif [ $1 == "-cdw" -o $1 == "-CDW" ]; then
      echo -n "$AdCity $CWTDate $AdWeather"
   elif [ $1 == "-wdc" -o $1 == "-WDC" ]; then
      echo -n "$AdWeather $CWTDate $AdCity"
   elif [ $1 == "-wcd" -o $1 == "-WCD" ]; then
      echo -n "$AdWeather $AdCity $CWTDate"
   fi
else
   echo -n "$CWTDate$AdWeather$AdCity"
fi
#**********************************************************************
# 本脚本为了方便书写各类脚本及文本时，及时插入时间、日期和IP对应的地理
# 位置所以您可以结合UltiSnipe片段插件来使用,使用方法为：
# ~/.vim/bundle/vim-snippets/UltiSnips/all.snippets
# 追加片段
#
############
#  Weather #
############
#snippet weather "Weather" im
#`weather -w`
#endsnippet
#snippet city "City" im
#`weather -c`
#endsnippet
#snippet address "Address" im
#`weather -a`
#endsnippet
#snippet dcw "date city weather" im
#`weather -dcw`   
#endsnippet
#snippet dwc "date city weather" im
#`weather -dwc`   
#endsnippet
#snippet wcd "date city weather" im
#`weather -wcd`   
#endsnippet
#snippet wdc "date city weather" im
#`weather -wdc`   
#endsnippet
#snippet cwd "date city weather" im
#`weather -cwd`   
#endsnippet
#snippet cdw "date city weather" im
#`weather -cdw`   
#endsnippet
#snippet dwca "date city weather" im
#`weather`   
#endsnippet
#
#**********************************************************************
