#! /bin/sh
#
# Program: ParuAxel.sh
# Version: V1.4
# Author : Zhen-Hua Feng
# Email  : fengzhenhua@outlook.com
# Date   : 2024-11-06 14:08
# Copyright (C) 2023 feng <feng@arch>
#
# Distributed under terms of the MIT license.
#
GIT_DOMIN=`echo $2 | cut -f3 -d'/'`;
GIT_OTHER=`echo $2 | cut -f4- -d'/'`;
GIT_INIT="https://github.com/"
GCF=/home/$USER/.gitconfig
GIT_MIR=$(grep "url \"http" $GCF)
GIT_SIT=(${GIT_MIR[*]//" "/""})
GIT_SIT=(${GIT_SIT[*]//";"/""})
GIT_SIT=(${GIT_SIT[*]//"[url\""/""})
GIT_SIT=(${GIT_SIT[*]//"\"]"/""})
GIT_DETECT(){
    wget --spider -T 5 -q -t 2 $1
}
i=0 ; j=0
case "$GIT_DOMIN" in
    "github.com")
        if [ -e $GCF ]; then
            while [[ $i -lt "${#GIT_SIT[*]}" ]]; do
                GIT_DETECT ${GIT_SIT[$i]}
                if [[ $? = 0 ]]; then
                    GIT_URL=${GIT_SIT[$i]}$GIT_OTHER
                    i=${#GIT_SIT[*]} ; j=1
                else
                    let i+=1
                fi
            done
            if [[ $j -eq 0 ]]; then
                GIT_URL="$GIT_INIT$GIT_OTHER"
            fi
        else
            GIT_URL="$GIT_INIT$GIT_OTHER"
        fi
        echo "Download from mirror $GIT_URL";
        # Single-threaded, enabled by default
        # /usr/bin/curl -gqb "" -fLC - --retry 3 --retry-delay 3 -o $1 $GIT_URL;
        # Multi-threading, which may not be supported by some mirror websites
		/usr/bin/axel -n 15 -a -o $1 $GIT_URL;
        ;;
    *)
        GIT_URL=$2;
        /usr/bin/axel -n 15 -a -o $1 $GIT_URL;
        ;;
esac
