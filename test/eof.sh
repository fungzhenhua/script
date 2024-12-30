#! /bin/sh
#
# eof.sh
# Copyright (C) 2024 feng <feng@archlinux>
#
# Distributed under terms of the MIT license.
#
cat << "EOF" > test.txt
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
# set for zsh-z-git
# source /usr/share/zsh/plugins/zsh-z/zsh-z.plugin.zsh
# set for z.lua 功能上不如zsh-z-git完善
# eval "$(lua /usr/share/z.lua/z.lua --init zsh enhanced once)"
# set for zoxide instead of z.lua
eval "$(zoxide init zsh)"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# 开启拼写检查，带颜色
autoload U colors && colors
setopt correct
export SPROMPT="Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color [Yes, No, Abort, Edit]"
# 补全大小写敏感
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}'
# 切换npm为淘宝的cnpm,加速下载
# alias npm=cnpm
# 配置Pel
export PERL_BASE="/usr/local/perl"
export PERL_MM_OPT="INSTALL_BASE=$PERL_BASE"
export PERL_MB_OPT="--install_base $PERL_BASE"
export PERL5LIB="$PERL_BASE/lib/perl5"
export PATH="$PERL_BASE/bin${PATH:+:$PATH}"
export MANPATH="$PERL_BASE/man${MANPATH:+:$MANPATH}"
# For a full list of active aliases, run `alias`.
# Example aliases
# alias paru="paru --needed --noconfirm"
UGIT_COMMIT="${USER}@$(fastfetch |grep Host| awk -F'(' '{print $2}'|awk -F')' '{print $1}')"
UGIT_COMMIT=$(echo $UGIT_COMMIT | sed 's/ /\-/g')
alias \
    zpull="git pull" \
    zpush="git add . && git commit -m "$UGIT_COMMIT" && git push" \
    del='trash-put' \
    nvimdiff="nvim -d" \
    ip="ip -color=auto" \
    e="exa --long --header --color=auto --icons -a" \
    ls="exa --color=auto --icons " \
    grep="grep --color=auto" \
    diff="diff --color=auto" \
    bat="bat --color=auto" \
    make="colormake" \
    ping="gping" \
EOF
