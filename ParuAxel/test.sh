#! /bin/sh
#
# test.sh
# Copyright (C) 2024 Zhen-hua Feng <fengzhenhua@outlook.com>
#
# Distributed under terms of the MIT license.
#


GCF=/home/$USER/.gitconfig
GIT_MIR=$(grep "url \"http" $GCF)
GIT_SIT=(${GIT_MIR[*]//" "/""})
GIT_SIT=(${GIT_SIT[*]//";"/""})
GIT_SIT=(${GIT_SIT[*]//"[url\""/""})
GIT_SIT=(${GIT_SIT[*]//"\"]"/""})

echo ${GIT_SIT[*]}
