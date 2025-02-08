#! /bin/sh
#
# Program  : syndns.sh
# Version  : v4.5
# Date     : 2025-02-08 22:39
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2022-2025 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
# 变量
SYN_EXE="/usr/local/bin/${0%.sh}"
SYN_AUTO="$HOME/.config/autostart/${0%.sh}.desktop"
SYN_KEY="$HOME/.syndns_conf"
SYN_KEY_SET(){
    if [[ ! -e $SYN_KEY ]]; then
        touch $SYN_KEY
        read -p "请输入sudo密码：" SYN_KEY_DATA
        echo "$SYN_KEY_DATA"|base64 -i | tee $SYN_KEY
    fi
    SYN_KEY_X=$(echo $(cat $SYN_KEY)| base64 -d)
    sudo -k
    echo $SYN_KEY_X | sudo -lS &> /dev/null
    if [[ $? != 0 ]]; then
        SYN_KEY_SET
    fi
}
SYN_KEY_SET
SYN_SUDO="/etc/sudoers.d/01_$USER"
SYN_HOS="/etc/hosts"
SYN_RES="/etc/resolv.conf"
SYN_REC=$(grep "addn-hosts" /etc/dnsmasq.conf |grep "/dev/shm/")
SYN_REC=${SYN_REC#*=}
SYN_ADD="$HOME/.host_dns_autoadd.txt"
SYN_HOS_USE="$HOME/.host_dns_clean"
SYN_DNS_EN=(4.2.2.1 4.2.2.2 4.2.2.3 4.2.2.4 4.2.2.5 4.2.2.6 \
    1.0.0.1 1.0.0.2 1.0.0.3 \
    9.9.9.9 149.112.112.112 149.112.112.9 \
    # 77.88.8.8 77.88.8.1 77.88.8.2 77.88.8.88 77.88.8.3 77.88.8.3 \
    # 80.80.80.80 80.80.81.81 \
    # 101.101.101.101 101.102.103.104 \
    )  # 默认DNS服务器, 前4个可以正确返回github.com
SYN_DNS_CN=(119.29.29.29 180.76.76.76 1.2.4.8)
# Github 网站涉及的所有域名, 暂时保留，只是1.0.0.1可以正确解析
SYN_GITHUB=(github.com github.githubassets.com central.github.com desktop.githubusercontent.com \
assets-cdn.github.com camo.githubusercontent.com github.map.fastly.net github.global.ssl.fastly.net \
gist.github.com github.io api.github.com raw.githubusercontent.com user-images.githubusercontent.com \
favicons.githubusercontent.com avatars5.githubusercontent.com avatars4.githubusercontent.com \
avatars3.githubusercontent.com avatars2.githubusercontent.com avatars1.githubusercontent.com \
avatars0.githubusercontent.com avatars.githubusercontent.com codeload.github.com \
github-cloud.s3.amazonaws.com github-com.s3.amazonaws.com \
github-production-release-asset-2e65be.s3.amazonaws.com \
github-production-user-asset-6210df.s3.amazonaws.com \
github-production-repository-file-5c1aeb.s3.amazonaws.com githubstatus.com github.community \
media.githubusercontent.com objects.githubusercontent.com raw.github.com copilot-proxy.githubusercontent.com \
)
SYN_SCI=(fonts.gstatic.com journals.aps.org link.aps.org cdn.journals.aps.org cdn.aps.org cdn.segment.com api.segment.io cdn.mxpnl.com \
www.google-analytics.com www.googletagmanager.com googleads.g.doubleclick.net www.google.com \
d1bxh8uas1mnw7.cloudfront.net d1uo4w7k31k5mn.cloudfront.net badge.dimensions.ai api.altmetric.com metrics-api.dimensions.ai \
doi.org iopscience.iop.org www.researchgate.net a.researchgate.net c5.rgstatic.net adk.privacy-center.org code.jquery.com \
arxiv.org static.arxiv.org www.sciencedirect.com opg.optica.org picx.zhiming.com \
mirrors.sustech.edu.cn cdnjs.cloudflare.com cdn.onmicrosoft.cn unpkg.com s4.zstatic.net \
lf2-cdn-tos.bytecdntp.com lf9-cdn-tos.bytecdntp.com lf26-cdn-tos.bytecdntp.com lf6-unpkg.zstaticcdn.com \
scipost.org)
SYN_CLEAN_DOM=( $(echo ${SYN_GITHUB[*]} ${SYN_SCI[*]} |sed 's/ /\n/g'|sort|uniq) )
SYN_HOS_ARR=( $(cat $SYN_HOS |awk '{print $2}'|grep -v '^$'|grep -v '^#'|sort |uniq |sed -r 's/ * / /g') )
SYN_HOSX=( $(echo ${SYN_HOS_ARR[*]} ${SYN_CLEAN_DOM[*]} |sed 's/ /\n/g'|sort|uniq -c|awk '$1==1{print $2}' ) )
if [ -e $SYN_ADD ]; then
    SYN_ADD_ARR=( $(cat $SYN_ADD |awk '{print $2}'|grep -v '^$'|grep -v '^#'|sort |uniq |sed -r 's/ * / /g') )
    SYN_ADDX=($(echo ${SYN_ADD_ARR[*]} ${SYN_CLEAN_DOM[*]} |sed 's/ /\n/g'|sort|uniq -c|awk '$1==1{print $2}') )
fi
# 检测软件依懒, 若未检测到，则自动安装
SYNDNS_DEPEND(){
    for VAR in $1 ;do
        pacman -Qq $VAR &> /dev/null
        if [[ $? != 0 ]]; then
           echo $SYN_KEY_X | sudo -S pacman -S $VAR
        fi
    done
}
# 参数1 DNS服务器 参数2为域名数组，参数3 保存文件， 使用 SYN_DN2IP "${SYN_DNS_CN[*]}" "${DOMAN[*]}" "outfile"
SYN_DN2IP(){
    unset SYN_DNSIP ; unset SYN_DNS_DOM
    SYN_DNSIP=($1) ; SYN_DNS_DOM=($2)
    for hubweb in ${SYN_DNS_DOM[*]}; do
        unset SYN_IP
        for ((k = 0; k < ${#SYN_DNSIP[@]}; k++)); do
            ping -c 1 -W 1 ${SYN_DNSIP[$k]} &> /dev/null
            if [[ $? == 0 ]]; then
                SYN_IP="$(dig @${SYN_DNSIP[$k]} +short $hubweb)"
                if [[ ! "${SYN_IP[*]}" =~ "#" ]]; then
                    for ipc in ${SYN_IP[*]}; do
                        echo "$ipc $hubweb" >> $3
                    done
                    break
                else
                    unset SYN_IP
                    continue
                fi
            fi
        done
    done
}
SYN_SET_COF(){
if [ ! -e $SYN_AUTO ]; then
   echo $SYN_KEY_X |sudo -S touch $SYN_AUTO
cat > $SYN_AUTO <<EOF
[Desktop Entry]
Name=SynDns
TryExec=syndns
Exec=$SYN_EXE
Type=Application
Categories=GNOME;GTK;System;Utility;TerminalEmulator;
StartupNotify=true
X-Desktop-File-Install-Version=0.22
X-GNOME-Autostart-enabled=true
Hidden=false
NoDisplay=false
EOF
echo $SYN_KEY_X |sudo -S sh -c "cat > /etc/dnsmasq.conf" <<EOA
domain-needed
bogus-priv
resolv-file=/etc/resolv.conf
no-poll
interface=lo
listen-address=127.0.0.1
bind-interfaces
no-hosts
addn-hosts=/dev/shm/dnsrecord.txt
cache-size=9999
port=53
EOA
fi
}
SYN_SET_RES(){
    SYN_TES_FIRST=$(cat $SYN_RES |grep "nameserver" | head -1)
    if [[ $SYN_TES_FIRST != "nameserver 127.0.0.1" ]]; then
        echo $SYN_KEY_X | sudo -S systemctl stop dnsmasq.service
        echo $SYN_KEY_X |sudo -S chattr -i $SYN_RES
echo $SYN_KEY_X |sudo -S sh -c "cat > $SYN_RES  &> /dev/null" <<EOC
"# Generated by syndns"
"nameserver 127.0.0.1"
"nameserver 119.29.29.29"
"nameserver 180.76.76.76"
"nameserver 1.2.4.8"
EOC
        echo $SYN_KEY_X |sudo -S chattr +i $SYN_RES
    fi
    systemctl is-active --quiet dnsmasq
    if [[ $? == 0 ]]; then
        echo $SYN_KEY_X | sudo -S systemctl restart dnsmasq.service
    else
        echo $SYN_KEY_X | sudo -S systemctl start dnsmasq.service
    fi
    echo $SYN_KEY_X |sudo -S systemctl restart NetworkManager
}
# 主程序
SYNDNS_PROCESS(){
    # 清空$SYN_REC, 若不存在则建立空文件
    if [[ -e $SYN_REC ]]; then
       rm -rf $SYN_REC
    fi
    touch $SYN_REC
    if [[ ! -e $SYN_HOS_USE ]] || [[ $1 == "-rebuild" ]] ; then
        SYN_DN2IP "${SYN_DNS_CN[*]}" "${SYN_HOSX[*]}" "$SYN_REC"
        cat $SYN_REC > $SYN_HOS_USE
    else
        cat $SYN_HOS_USE >> $SYN_REC
    fi
    if [[ $1 == "-rebuild" ]] && [[ -e $SYN_ADD ]]; then
        echo "" > $SYN_ADD
        SYN_DN2IP "${SYN_DNS_CN[*]}" "${SYN_ADDX[*]}" "$SYN_ADD"
        cat $SYN_ADD >> $SYN_REC
    fi
    # 探测github.com 相关
    SYN_DN2IP "${SYN_DNS_EN[*]}" "${SYN_GITHUB[*]}" "$SYN_REC"
    # 探测sci 期刊
    SYN_DN2IP "${SYN_DNS_EN[*]}" "${SYN_SCI[*]}" "$SYN_REC"
    # 将整理好的 $SYN_REC 保存到 $SYN_HOS
    echo $SYN_KEY_X |sudo -S sh -c "cat $SYN_REC > $SYN_HOS" &> /dev/null
    echo "$(hostname -i) localhost:" >> $SYN_REC
    # 重启dnsmasq服务
    SYN_SET_RES
}
# 安装和更新
if [ $# -gt 0 ]; then
    if [ $1 == "-i" -o $1 == "-I" ]; then
        SYNDNS_DEPEND "dnsutils inetutils dnsmasq jq"
        echo $SYN_KEY_X |sudo -S cp -f $0 $SYN_EXE
        echo $SYN_KEY_X |sudo -S chmod +x $SYN_EXE
        SYN_SET_COF
        exit
    elif [[ $1 =~ ".json" ]] || [[ $1 =~ ".dom" ]]; then
        if [[ $1 =~ ".json" ]]; then
            SYN_ADDRESS=($(cat $1|jq -r '.children[]' |grep "\"uri\":"))
            SYN_ADDRESS=(${SYN_ADDRESS[*]#*//})
            SYN_ADDRESS=(${SYN_ADDRESS[*]/\"uri\":})
            SYN_ADDRESS=(${SYN_ADDRESS[*]%%/*})
            SYN_ADDRESS=(${SYN_ADDRESS[*]%%\"*})
            SYN_ADDRESS=(${SYN_ADDRESS[*]%%*[0-9]})  # 去除非域名
            SYN_ADDRESS=(`echo ${SYN_ADDRESS[@]}|sed -e 's/ /\n/g'|sort |uniq`)
        elif [[ $1 =~ ".dom" ]]; then
            SYN_ADDRESS=($(cat $1))
        fi
        if [ ! -e $SYN_ADD ]; then
            touch $SYN_ADD
        fi
        SYN_DN2IP "${SYN_DNS_CN[*]}" "${SYN_ADDRESS[*]}" "$SYN_ADD"
        cat $SYN_ADD |grep '^[0-9]' |grep -v '^$'|grep -v '^#'|sort |uniq -u |sed -r 's/ * / /g' > $SYN_ADD
    elif [[ $1 = "-r" ]] || [[ $1 = "-rebuild" ]]; then
        SYNDNS_PROCESS "-rebuild"
    fi
else
    SYNDNS_PROCESS "-unbuild"
fi
