#! /bin/sh
#
# anaopt.sh
# Copyright (C) 2025 Zhen-hua Feng <fengzhenhua@outlook.com>
#
# Distributed under terms of the MIT license.
#
# 调入私有函数库
source ~/.Share_Fun/Share_Fun_KeySudo.sh
if [[ $SFS_LOADED =="" ]]; then
    # 安装依赖
    GIT_DEPEND coreutils grep
    # 函数：求交集
    function ana_intersection() {
        local set1=($1)
        local set2=($2)

        # 使用 grep 找到两个集合的共同元素
        echo "${set1[@]}" | tr ' ' '\n' | grep -Fx -f <(echo "${set2[@]}" | tr ' ' '\n') | sort -u
    }
# 函数：求并集
function ana_union() {
    local set1=($1)
    local set2=($2)
    echo "${set1[@]} ${set2[@]}" | tr ' ' '\n' | sort -u
}
# 函数：求差集 (set1 - set2)
function ana_difference() {
    local set1=($1)
    local set2=($2)
    # 找出 set1 中不在 set2 中的元素
    echo "${set1[@]}" | tr ' ' '\n' | grep -Fxv -f <(echo "${set2[@]}" | tr ' ' '\n')
}
# 函数：求对称差集 (set1 ⊕ set2)= (set1 - set2) ∪ (set2 - set1)
function ana_symmetric_difference() {
    local set1=($1)
    local set2=($2)
    local diff1=$(difference "$1" "$2")
    local diff2=$(difference "$2" "$1")
    echo "$diff1 $diff2" | tr ' ' '\n' | sort -u
}
SFS_LOADED="yes"
fi
# 示例使用
# set1="a b c d"
# set2="b c e f"
#
# echo "集合1: $set1"
# echo "集合2: $set2"

# 求交集
# echo -e "\n交集: $(ana_intersection "$set1" "$set2")"
