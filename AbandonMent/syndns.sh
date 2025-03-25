#! /bin/sh
#
# Program  : syndns.sh
# Version  : v4.6
# Date     : 2025-03-25 21:56
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2022-2025 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
# 变量
SYN_EXE="/usr/local/bin/${0%.sh}"
SYN_AUTO="$HOME/.config/autostart/${0%.sh}.desktop"
# 定义标识符
SYN_KEY="syndns_password"  # 密钥环中的唯一标识符
SYN_SUDO_NUM_MAX="3"       # 确保这个数值与您系统中sudo验证次数一致，以免进入死循环
# 检测依赖，确保secret-tool正确安装
if ! command -v secret-tool &>/dev/null; then
  echo "错误：需要安装 secret-tool（包名：libsecret-tools）" >&2
  exit 1
fi
# 探测系统sud解锁程序
SYN_RES_CMD=""
if command -v faillock &>/dev/null; then
    SYN_RES_CMD="faillock --user $USER --reset"
elif command -v pam_tally2 &>/dev/null; then
    SYN_RES_CMD="pam_tally2 --user $USER --reset"
else
    echo "错误：未找到可用SUDO解锁工具 !" >&2
    echo "请安装：Arch系安装pambase，RHEL系安装pam" >&2
    exit 1  # 正确终止脚本
fi
# 存储密码到 GNOME Keyring
# 测试密码过程中存在sudo次数限制，如果sudo被锁定了，那本脚本在首次没有完成密码保存的工作后将处于锁定状态
SYN_KEY_GET(){
    local SYN_AMT="$SYN_SUDO_NUM_MAX"
    while [[ "$SYN_AMT" -gt 0 ]]; do
        SYN_KEY_X=$(secret-tool lookup syndns_password_key "$SYN_KEY")
        if [[ -z "$SYN_KEY_X" ]]; then
            unset SYN_KEY_DATA
            # 使用专业密码输入工具
            if command -v systemd-ask-password &>/dev/null; then
                SYN_KEY_DATA=$(systemd-ask-password --timeout=30 "请求sudo密码:")
            else
                printf "$0 请求输入sudo密码(30秒超时):" >&2
                # 增加超时后的清理逻辑
                if ! read -rs -t 30 SYN_KEY_DATA; then
                    printf "\n输入超时，操作取消。\n" >&2
                    unset SYN_KEY_DATA
                    exit 1
                fi
            fi
            if [[ -z "$SYN_KEY_DATA" ]]; then
                printf "\n密码不能为空，请重新输入。\n" >&2
            else
                if printf "%s" "$SYN_KEY_DATA" | secret-tool store --label="Syndns Password" syndns_password_key "$SYN_KEY"; then
                    sudo -k
                    if printf "%s" "$SYN_KEY_DATA" | sudo -S -v 2>/dev/null; then
                        # 存储成功后立即清理
                        unset SYN_KEY_DATA
                        printf "\n密码已成功存储到 GNOME Keyring 中。\n" >&2
                        return 0
                    else
                        SYN_AMT=$((SYN_AMT - 1))
                        SYN_FAIL_RES "警告：当前系统可能需要手动重置失败计数!"
                    fi
                else
                    printf "\n无法存储密码，请检查 GNOME Keyring 是否可用。\n" >&2
                    exit 1
                fi
            fi
        else
            sudo -k
            if ! printf "%s" "$SYN_KEY_X" | sudo -S -v 2>/dev/null; then
                SYN_AMT=$((SYN_AMT - 1))
                secret-tool clear syndns_password_key "$SYN_KEY" # 清空密码，重新循环才能进入设置
                SYN_FAIL_RES "警告：当前系统可能需要手动重置失败计数!"
            else
                return 0
            fi
        fi
    done
    printf "尝试次数已达上限，操作终止。\n" >&2
    SYN_FAIL_RES "请切换至ROOT权限解除锁定: $SYN_RES_CMD"
    exit 1
}
SYN_FAIL_RES(){
    if grep -qi 'arch' /etc/os-release 2>/dev/null; then
        faillock --user $USER --reset
    else
        # 优先显示传入的定制化提示
        printf "$1 \n" >&2
        # 补充建议命令（带sudo前缀）
        [ -n "$SYN_RES_CMD" ] && echo "可尝试执行: sudo $SYN_RES_CMD" >&2
    fi
}
# 检测软件依懒, 若未检测到，则自动安装
GIT_DEPEND(){
    # 获取sudo 密钥
    SYN_KEY_GET
    # 安装依赖
    for VAR in $1 ;do
        pacman -Qq "$VAR" &> /dev/null
        if [[ $? != 0 ]]; then
            echo "$SYN_KEY_X" | sudo -S pacman -S --needed --noconfirm "$VAR"
        fi
    done
}
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
   SYN_KEY_GET
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
    SYN_KEY_GET
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
    SYN_KEY_GET
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
        SYN_KEY_GET
        GIT_DEPEND "dnsutils inetutils dnsmasq jq"
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
