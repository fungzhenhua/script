#! /bin/sh
#
# Program  : syndns.sh
# Version  : v2.5
# Date     : 2025-01-01 12:13
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2022-2025 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
# 检测软件依懒, 若未检测到，则自动安装
SYNDNS_DEPEND(){
    for VAR in $1 ;do
        pacman -Qq $VAR &> /dev/null
        if [[ $? != 0 ]]; then
            sudo pacman -S $VAR
        fi
    done
}
# 变量
SYN_EXE="/usr/local/bin/${0%.sh}"
SYN_AUTO="$HOME/.config/autostart/${0%.sh}.desktop"
SYN_SUDO="/etc/sudoers.d/01_$USER"
SYN_HOS="/etc/hosts"
SYN_REC=$(grep "addn-hosts" /etc/dnsmasq.conf |grep "/dev/shm/")
SYN_REC=${SYN_REC#*=}
SYN_ADD="$HOME/.host_dns_autoadd.txt"
SYN_DNSIP=(1.0.0.1 1.0.0.2 1.0.0.3 \
    9.9.9.9 149.112.112.112 149.112.112.9 \
    77.88.8.8 77.88.8.1 77.88.8.2 77.88.8.88 77.88.8.3 77.88.8.3 \
    4.2.2.1 4.2.2.2 4.2.2.3 4.2.2.4 4.2.2.5 4.2.2.6 \
    80.80.80.80 80.80.81.81 \
    101.101.101.101 101.102.103.104)  # 默认DNS服务器, 前4个可以正确返回github.com
# Github 网站涉及的所有域名, 暂时保留，只是1.0.0.1可以正确解析
SYN_GITHUB=(github.githubassets.com central.github.com desktop.githubusercontent.com \
assets-cdn.github.com camo.githubusercontent.com github.map.fastly.net github.global.ssl.fastly.net \
gist.github.com github.io github.com api.github.com raw.githubusercontent.com user-images.githubusercontent.com \
favicons.githubusercontent.com avatars5.githubusercontent.com avatars4.githubusercontent.com \
avatars3.githubusercontent.com avatars2.githubusercontent.com avatars1.githubusercontent.com \
avatars0.githubusercontent.com avatars.githubusercontent.com codeload.github.com \
github-cloud.s3.amazonaws.com github-com.s3.amazonaws.com \
github-production-release-asset-2e65be.s3.amazonaws.com \
github-production-user-asset-6210df.s3.amazonaws.com \
github-production-repository-file-5c1aeb.s3.amazonaws.com githubstatus.com github.community \
media.githubusercontent.com objects.githubusercontent.com raw.github.com copilot-proxy.githubusercontent.com \
kkgithub.com css.kkgithub.com)
SYN_SCI=(journals.aps.org link.aps.org cdn.journals.aps.org cdn.aps.org cdn.segment.com api.segment.io cdn.mxpnl.com lf6-cdn-tos.bytecdntp.com lf9-cdn-tos.bytecdntp.com lf26-cdn-tos.bytecdntp.com lf6-unpkg.zstaticcdn.com \
www.google-analytics.com www.googletagmanager.com googleads.g.doubleclick.net www.google.com \
d1bxh8uas1mnw7.cloudfront.net d1uo4w7k31k5mn.cloudfront.net badge.dimensions.ai api.altmetric.com metrics-api.dimensions.ai \
doi.org iopscience.iop.org www.researchgate.net a.researchgate.net c5.rgstatic.net adk.privacy-center.org code.jquery.com \
arxiv.org static.arxiv.org www.sciencedirect.com opg.optica.org picx.zhiming.com cdnjs.cloudflare.com cdn.onmicrosoft.cn unpkg.com s4.zstatic.net)
#
# 参数1为域名数组，参数2 保存文件， 使用 SYN_DN2IP "${DOMAN[*]}" "outfile"
SYN_DN2IP(){
    for hubweb in $1; do
        unset SYN_IP
        for ((k = 0; k < ${#SYN_DNSIP[@]}; k++)); do
            SYN_IP="$(dig @${SYN_DNSIP[$k]} +short $hubweb)"
            if [[ ! "$SYN_IP" =~ "#" ]]; then
                k=${#SYN_DNSIP[@]}
            fi
        done
        if [[ ! "$SYN_IP" =~ "#" ]]; then
            for ipc in ${SYN_IP[*]}; do
                echo "$ipc $hubweb" >> $2
            done
        fi
    done
}
# 主程序
SYNDNS_PROCESS(){
    # 清空$SYN_REC, 若不存在则建立空文件
    echo "" > $SYN_REC
    # 清理/etc/hosts 中的github有关域名, 并调入
    sudo sed -i "/github/d" $SYN_HOS
    cat $SYN_HOS |grep -v '^$'|grep -v '^#'|sort |uniq |sed -r 's/ * / /g' >> $SYN_REC
    # 探测github.com 相关
    SYN_DN2IP "${SYN_GITHUB[*]}" "$SYN_REC"
    # 探测sci 期刊
    SYN_DN2IP "${SYN_SCI[*]}" "$SYN_REC"
    if [ -e $SYN_ADD ]; then
        sudo sed -i "/github/d" $SYN_ADD
        cat $SYN_ADD |grep '^[0-9]' |grep -v '^$'|grep -v '^#'|sort |uniq |sed -r 's/ * / /g' >> $SYN_REC
    fi
    cat $SYN_REC |grep '^[0-9]' |grep -v '^$'|grep -v '^#'|sort |uniq |sed -r 's/ * / /g'  > $SYN_REC
    echo "$(hostname -i) localhost:" >> $SYN_REC
    # 将整理好的 $SYN_REC 保存到 $SYN_HOS, 以供其他系统调用
    sudo sh -c "cat $SYN_REC > $SYN_HOS"
    # 重启dnsmasq服务
    systemctl is-active --quiet dnsmasq
    if [[ $? == 0 ]]; then
        sudo systemctl restart dnsmasq.service
    else
        sudo systemctl start dnsmasq.service
    fi
}
# 安装和更新
if [ $# -gt 0 ]; then
    if [ $1 == "-i" -o $1 == "-I" ]; then
        SYNDNS_DEPEND "dnsutils inetutils dnsmasq jq"
        sudo cp -f $0 $SYN_EXE
        sudo chmod +x $SYN_EXE
if [ ! -e $SYN_AUTO ]; then
   sudo touch $SYN_AUTO
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
sudo sh -c "cat > /etc/dnsmasq.conf" <<EOA
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
if [ ! -e $SYN_SUDO ]; then
   sudo touch $SYN_SUDO
sudo sh -c "cat > $SYN_SUDO" <<EOB
$USER ALL=(ALL) NOPASSWD: /bin/systemctl restart dnsmasq.service, /bin/systemctl start dnsmasq.service
EOB
fi
    elif [[ $1 =~ ".json" || $1 =~ ".dom" ]]; then
        if [[ $1 =~ ".json" ]]; then
            Address=($(cat $1|jq -r '.children[]' |grep "\"uri\":"))
            Address=(${Address[*]#*//})
            Address=(${Address[*]/\"uri\":})
            Address=(${Address[*]%%/*})
            Address=(${Address[*]%%\"*})
            Address=(${Address[*]%%*[0-9]})  # 去除非域名
            Address=(`echo ${Address[@]}|sed -e 's/ /\n/g'|sort |uniq`)
        elif [[ $1 =~ ".dom" ]]; then
            Address=($(cat $1))
        fi
        if [ ! -e $SYN_ADD ]; then
            touch $SYN_ADD
        fi
        SYN_DN2IP "${Address[*]}" "$SYN_ADD"
        cat $SYN_ADD |grep '^[0-9]' |grep -v '^$'|grep -v '^#'|sort |uniq -u |sed -r 's/ * / /g' > $SYN_ADD
        SYNDNS_PROCESS
    fi
fi
# 默认执行主程序
SYNDNS_PROCESS
