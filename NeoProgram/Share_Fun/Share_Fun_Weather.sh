#! /bin/sh
#
# Program  : Share_weather.sh
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2022-2025 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
# Version  : V2.9
# Date     : 2025-03-26 23:54
#
if [[ $SFW_LOADED == "" ]]; then
    # 重要的参数设置
    WT_KEY_CFG=~/.WT_KEY
    WEATHEREXE=weather
    WTPath=/usr/local/bin/$WEATHEREXE
    WeatherData=~/.WEATHERDATA
    CWTDate=$(date +"%Y年%m月%d日%A")
    WTNow=$(date '+%Y-%m-%dT%H:%M:%S')
    WTSpace=6300 #默认设置为2小时更新
    # 私人信息设置
    if [ ! -e $WT_KEY_CFG ]; then
        touch $WT_KEY_CFG
        chmod +w $WT_KEY_CFG
        echo "个人信息配置：注意下面直接按示例填写配置信息，去掉第1行之外的所有中文!!" > $WT_KEY_CFG
        echo "高德地图密钥，用来获取天气预报，如79a3976b38e0b544d0d19dd643c4634e" >> $WT_KEY_CFG
        echo "配置文件已经生成在$WT_KEY_CFG, 请打开此文件按说明填写信息!"
        exit
    else
        WT_INFO=($(cat $WT_KEY_CFG))
        GAO_DE_KEY=${WT_INFO[1]}
    fi
    # 设置本机用户天气数据库，避免每次运行都向网络请求天气，可以提高效率
    if [ ! -e $WeatherData ]; then
        touch $WeatherData
        chmod +w $WeatherData
        WTOld="1983-03-09T16:46:48"  #此处设置为我的生日，用于开启信息刷新
    else
        WTDATA=$(<$WeatherData)
        WTOld=$(echo $WTDATA | awk '{print $1}')
        Adprovince=$(echo $WTDATA | awk '{print $2}')
        AdCity=$(echo $WTDATA | awk '{print $3}')
        AdIp=$(echo $WTDATA | awk '{print $4}')
        Adcode=$(echo $WTDATA | awk '{print $5}')
        AdWeather=$(echo $WTDATA | awk '{print $6}')
        AdTemp=$(echo $WTDATA | awk '{print $7}')
        AdTempFloat=$(echo $WTDATA | awk '{print $8}')
        AdWindDir=$(echo $WTDATA | awk '{print $9}')
        AdWindPow=$(echo $WTDATA | awk '{print $10}')
        AdHumidity=$(echo $WTDATA | awk '{print $11}')
        AdHumidityFloat=$(echo $WTDATA | awk '{print $12}')
        AdTepTime=$(echo $WTDATA | awk '{print $13}')
    fi
    XWTOld=`date -d "$WTOld" +%s`
    XWTNow=`date -d "$WTNow" +%s`
    let WTTime="$XWTNow - $XWTOld"
    #
    GetNetWeather(){
        # 淘汰方案, 2023-11-16 发现其访问不稳定， 同时diary.sh也因为其出现问题
        # Address=$(curl -s  cip.cc)
        # Adprovince=$(echo $Address | awk -F'|' '{print $2}' | awk -F':' '{print $2}'|sed 's/ //g')
        # AdCity=$(echo $Address | awk -F'|' '{print $1}'| awk -F':' '{print $5}'|sed 's/ //g')
        # AdIp=$(echo $Address | awk '{print $3}'|sed 's/ //g')
        # IP地址备选方案
        # AdIp=$(curl -s myip.ipip.net | awk '{print $2}'| awk -F'：' '{print $2}') 
        # IP地址首选方案
        AdIp=$(curl -s ip.threep.top |sed 's/ //g')
        # 通过高德地图api获取位置、IP、天气情况
        AdIpGD=$(curl -s "https://restapi.amap.com/v3/ip?ip=$AdIp&output=xml&key=$GAO_DE_KEY"|sed 's/ //g')
        Adcode=$(echo $AdIpGD | awk -F'<adcode>' '{print $2}'|sed 's/ //g')
        Adcode=$(echo $Adcode | awk -F'</adcode>' '{print $1}'|sed 's/ //g')
        Adprovince=$(echo $AdIpGD | awk -F'<province>' '{print $2}'|sed 's/ //g')
        Adprovince=$(echo $Adprovince | awk -F'</province>' '{print $1}'|sed 's/ //g')
        AdCity=$(echo $AdIpGD | awk -F'<city>' '{print $2}'|sed 's/ //g')
        AdCity=$(echo $AdCity | awk -F'</city>' '{print $1}'|sed 's/ //g')
        WeatherIfo=$(curl -s "https://restapi.amap.com/v3/weather/weatherInfo?city=$Adcode&key=$GAO_DE_KEY")
        AdWeather=$(echo $WeatherIfo | awk -F'weather' '{print $2}' | awk -F':' '{print $2}'| \
            awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
        AdTemp=$(echo $WeatherIfo | awk -F'temperature' '{print $2}' | awk -F':' '{print $2}'| \
            awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
        AdTempFloat=$(echo $WeatherIfo | awk -F'temperature_float' '{print $2}' | awk -F':' '{print $2}'| \
            awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
        AdWindDir=$(echo $WeatherIfo | awk -F'winddirection' '{print $2}' | awk -F':' '{print $2}'| \
            awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
        AdWindPow=$(echo $WeatherIfo | awk -F'windpower' '{print $2}' | awk -F':' '{print $2}'| \
            awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
        AdHumidity=$(echo $WeatherIfo | awk -F'humidity' '{print $2}' | awk -F':' '{print $2}'| \
            awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
        AdHumidityFloat=$(echo $WeatherIfo | awk -F'humidity_float' '{print $2}' | awk -F':' '{print $2}'| \
            awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
        AdTepTime=$(echo $WeatherIfo | awk -F'reporttime' '{print $2}' | awk -F':' '{print $2}'| \
            awk -F',' '{print $1}'| awk -F'"' '{print $2}'|sed 's/ //g')
        #
        # 将获得的数据写入本地数据库
        echo "$WTNow" > $WeatherData
        echo "$Adprovince" >> $WeatherData
        echo "$AdCity" >> $WeatherData
        echo "$AdIp" >> $WeatherData
        echo "$Adcode" >> $WeatherData
        echo "$AdWeather" >> $WeatherData
        echo "$AdTemp" >> $WeatherData
        echo "$AdTempFloat" >> $WeatherData
        echo "$AdWindDir" >> $WeatherData
        echo "$AdWindPow" >> $WeatherData
        echo "$AdHumidity" >> $WeatherData
        echo "$AdHumidityFloat" >> $WeatherData
        echo "$AdTepTime" >> $WeatherData
    }
if [ $WTTime -gt $WTSpace ]; then
    GetNetWeather
fi
SFW_LOADED="yes" 
fi
