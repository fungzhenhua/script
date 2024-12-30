#! /bin/sh
#
# menu.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#


cat << EOF
用法：$DY_NAME [选项] 文章标                
版本：$DY_VERSION                           
选项参数：                                  
    -c --config            修改主站配置文件
    -c-next --config--next 修改主题配置文件
    -d                     上载博客文章
    -h --help              帮助
    -i --install           重新安装
    -l --list              列出所有文章
    -o                     清理Commit  
    -r                     删除博客文章
    -s                     预览博客
    --theme                选择主题
    --Setsym *             设置分隔符为: * 
    -tu --ThemeUpdate      升级Next主题    
    -u  --update           更新软件
    -xl                    修改目录后再列出
EOF
