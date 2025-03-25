#! /bin/sh
#
# Program  : arcsetup.sh
# Author   : fengzhenhua
# Email    : fengzhenhua@outlook.com
# CopyRight: Copyright (C) 2022-2025 FengZhenhua(冯振华)
# License  : Distributed under terms of the MIT license.
#
# 此版本始于2024年03月11日, 考虑到系统配置的可靠特性，逐步实现
# 2024-03-11 创建脚本
# 2024-03-12 增加wayland判断，以设置Fcitx5
# 2024-04-22 增加python-matplotlib包
#
echo  "*********************************************"
echo  "*                                           *"
echo  "* Script : arcsetup.sh                      *"
echo  "* Version: V1.5                             *"
echo  "* Note   : Update For ArchInstall.sh        *"
echo  "* Author : Zhen-Hua Feng(冯振华)            *"
echo  "* Email  : fengzhenhua@outlook.com          *"
echo  "* Website: https://fengzhenhua.gitlab.io    *"
echo  "* Copyright (C) 2022 feng <feng@archlinux>  *"
echo  "*                                           *"
echo  "*********************************************"
#
# 配置国内最快的12个ArchLinux源
sudo pacman -S --needed --noconfirm reflector
sudo reflector --verbose -c China --latest 12 --sort rate --threads 100 --save /etc/pacman.d/mirrorlist
sudo pacman -Syu
# 配置ArchLinuxCN源
ArcConf="/etc/pacman.conf"
ArcMirror="/etc/pacman.d/archlinuxcn-mirrorlist"
ArcCN="\[archlinuxcn\]"
ArcCNUrl="Server=https://repo.archlinuxcn.org/\$arch"
ArcCNList="Include=/etc/pacman.d/archlinuxcn-mirrorlist"
if [ `grep -c $ArcCN $ArcConf` -eq '0' ]; then
    echo "[archlinuxcn]" >> $ArcConf 
fi
if [ `grep -c $ArcCNList $ArcConf` -eq '0' ]; then
    if [ `grep -c $ArcCNUrl $ArcConf` -eq '0' ]; then
        echo $ArcCNUrl >> $ArcConf
    fi
fi
sudo pacman -Syu
sudo pacman-key --lsign-key "farseerfc@archlinux.org"
sudo pacman -S archlinuxcn-keyring
sudo pacman -S archlinuxcn-mirrorlist-git
sudo sed -i "s#$ArcCNUrl#$ArcCNList#g" $ArcConf
sudo cat <<- EOF > $ArcMirror
Server = https://mirrors.pku.edu.cn/archlinuxcn/\$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch
Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch
Server = https://mirrors.bupt.edu.cn/archlinuxcn/\$arch
Server = https://mirrors.cernet.edu.cn/archlinuxcn/\$arch
Server = https://repo.archlinuxcn.org/\$arch
EOF
# 添加arc4edu源
ArcEdu="\[arch4edu\]"
ArcEduUrl="Server = https://mirrors.cernet.edu.cn/arch4edu/\$arch"
sudo pacman-key --recv-keys 7931B6D628C8D3BA
sudo pacman-key --finger 7931B6D628C8D3BA
sudo pacman-key --lsign-key 7931B6D628C8D3BA
if [ `grep -c $ArcEdu $ArcConf` -eq '0' ]; then
    echo "[arch4edu]" >> $ArcConf 
fi
if [ `grep -c $ArcEduUrl $ArcConf` -eq '0' ]; then
    echo $ArcEduUrl >> $ArcConf
fi
sudo pacman -S pkgstats
# 配置paru
sudo pacman -S --needed --noconfirm git curl paru \
    ark p7zip-natspec unarchiver lzop lrzip arj zip unzip

sudo curl -o ParuAxel.7z https://gitlab.com/fengzhenhua/zipconf/-/raw/main/ParuAxel.7z\?inline\=false
unar ParuAxel.7z
cd ./ParuAxel
chmod +x install.sh
./install.sh
cd ..
rm -rf ParuAxel.7z ParuAxel
# 更新/etc/hosts, 确保github可以直连成功
sudo curl -o /etc/hosts https://gitlab.com/ineo6/hosts/-/raw/master/next-hosts\?inline\=false
sudo systemctl restart NetworkManager
# 配置全局github镜像, 镜像网址随时可能变化，应当注意保持更新
ArcGitHub="~/.gitconfig"
cat << EOF > $ArcGitHub
[user]
	email = fengzhenhua@outlook.com
	name = fengzhenhua
; [url "https://521github.com/"]
; [url "https://github.hscsec.cn/"]
[url "https://githubfast.com/"]
; [url "https://kkgithub.com/"]
; [url "https://gitclone.com/github.com/"]
	insteadOf = https://github.com/
EOF
# 关闭KDE Plasma 索引
balooctl disable
balooctl suspend
balooctl status
# 配置中文输入法Fcitx5
sudo pacman -S --needed --noconfirm fcitx5-git fcitx5-gtk-git fcitx5-qt5-git \
    fcitx5-qt4-git fcitx5-qt5-git fcitx5-qt6-git fcitx5-configtool-git \
    fcitx5-chinese-addons-git fcitx5-material-color fcitx5-nord
# 配置Fcitx5依赖的pam_env, 针对2024年03月11日升级Plasma6
FcitVar="/etc/environment"
sudo cat <<- EOF > $FcitVar
#
# This file is parsed by pam_env module
#
# Syntax: simple "KEY=VAL" pairs on separate lines
#
XMODIFIERS=@im=fcitx
EOF
if [ $XDG_SESSION_TYPE != "wayland" ]; then 
    echo "GTK_IM_MODULE=fcitx" >> $FcitVar
    echo "QT_IM_MODULE=fcitx" >> $FcitVar
fi
# 安装vim和neovim
sudo pacman -S --needed --noconfirm vim neovim npm wl-clipboard xclip perl \
    wget cargo composer php luarocks ruby julia ripgrep fd jdk-openjdk go  \
    python python-pynvim python-matplotlib guake thunderbird  thunderbird-i18n-zh-cn \
    libreoffice-still libreoffice-still-zh-cn calibre zotero goldendict-ng-git \
    python-requests mplayer speech-dispatcher texlive ntfs-3g zsh nerd-fonts \
    zsh-autosuggestions zsh-completions zsh-theme-powerlevel10k zsh-syntax-highlighting-git \
    zoxide exa
sudo npm install -g neovim
rm -rf ~/.local/lib/python*
# 安装常用软件：下载工具、腾讯会议、腾讯 QQ、音乐播放器、小白羊阿云盘
paru --skipreview --noconfirm -S xdman-beta-bin wemeet-bin linuxqq \
    listen1-desktop-appimage  aliyunpan-gaozhangmin-bin
## 配置~/.zshrc 2024-06-11
cat << "EOF" > ~/.zshrc
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
#
# 配置vim 2024-06-12 00:04
cat << "EOF" > ~/.vimrc
" ====vimrc====
" Version : v2.1
" Author  : Feng Zhenhua
" Email   : fengzhenhua@outlook.com
" Note    : 配置与Neovim相同的效果，貌似vim配置更加方便
"
" History :
" 2021年 12月 12日 星期日 20:58:28 CST 由于git速度比较慢，将github上的源同步到我的gitee
" 2022年 03月 05日 星期六 21:30:45 CST 增加对ibus的输入法自动切换支持，目前工作良好。同时也保留了对Fcitx5的支持
" 2022年 10月 13日 星期四 20:54:02 CST 默认关闭vim-markdown插件，因为其会折叠md文件代码，造成编辑麻烦。
" 2022年 10月 26日 星期三 11:44:53 CST 开启真彩，使用默认配色方案
" 2023年 05月 11日 星期四 多云北京市北京师范大学, 增加编写程序时F5执行脚本 
" 2023年 07月 17日 星期一 01:01:28 CST 用vim-plug 取代Vundle
" 2023年 07月 17日 星期一 12:17:53 CST 配置好vim-airline
" 2023年 07月 18日 星期二 21:28:46 CST 增加图标支持
" 2023年 07月 18日 星期二 22:00:31 CST 加入相对行号显示，即当前行为绝对行号，向上向下为相对行号
" 2023年 08月 01日 星期二 15:31:46 CST 关闭乌干达儿童提示
" 基础设置
set nocompatible              " be iMproved, required
filetype off                  " required
filetype plugin on
set grepprg=grep\ -nH\ $*
filetype indent on
syntax enable
set bg=dark
set number         "设置显示行号" 或 set nu
set relativenumber "设置显示相对行号" 或 set rnu
"设置配色方案
set termguicolors  "开启真彩
"colorscheme murphy
"colorscheme pablo
"--------------------设置第三方配色主题--------------------
"colorscheme molokai 
"let g:molokai_original = 1
"let g:rehash256 = 1
"设置列高亮
set cursorcolumn
"设置行线
set cursorline
"显示未执行的命令
set showcmd
"设置自动备份
"set backup
"set backupext=.bak
"保存一个原始文件
"set patchmode=.orig
"设置用命令行版stardict(sdcv)查询单词
"set keywordprg=sdcv
"设定字符编码20180320加入
set encoding=utf-8
set fileencodings=utf-8,gbk,cp936,gb18030,big5,euc-jp,euc-kr,latin1,ucs-bom,ucs
set termencoding=utf-8
"设置缩进
set autoindent shiftwidth=3
"设定软tab键,用来产生四个空格20180323
set softtabstop=4
"取消vim编辑时滴滴声
set noeb vb t_vb= 
"拼写检查
" ]s 将光标移到下一个拼写错误处 ， [s 将光标移到上一下拼写错误
" zg 将单词加入词典 zug 撤销将单词加入词典
" z= 拼写建议
set nospell
"set spell
"
"##### vim-plug ###########
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'
" Make sure you use single quotes
" 定义下载网址变量
" call plug#begin()
call plug#begin('~/.vim/plugged')
Plug 'vim-latex/vim-latex'
" Plug 'lervag/vimtex'
Plug 'aperezdc/vim-template'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
" Plug 'bluz71/vim-nightfly-colors'
Plug 'ghifarit53/tokyonight-vim'
" Plug 'sheerun/vim-polyglot'
" Plug 'tinted-theming/base16-vim'
Plug 'vim-airline/vim-airline'  "状态栏主题，丰富形式
Plug 'vim-airline/vim-airline-themes'
" Plug 'itchyny/lightline.vim'  "状态栏主题，简约形式
" Plug 'joshdick/onedark.vim'
Plug 'tpope/vim-commentary'
Plug 'preservim/nerdtree'
Plug 'junegunn/vim-plug'
Plug 'neoclide/coc.nvim', {'branch': 'release'} " 代码补全 需要vim >=8 或neovim
Plug 'vim-syntastic/syntastic' " 错误语法提示
Plug 'jiangmiao/auto-pairs' " 符号补全
Plug 'ryanoasis/vim-devicons' " 安装图标
Plug 'frazrepo/vim-rainbow' " 多重彩色括号
Plug 'Yggdroot/indentLine' " 多重彩色括号
Plug 'liuchengxu/vista.vim' " 展示文章结构
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' } "模糊查找
"Plug 'plasticboy/vim-markdown'
"Plug 'iamcco/mathjax-support-for-mkdp'
"Plug 'iamcco/markdown-preview.vim'
"Plug 'skywind3000/vim-auto-popmenu'
"Plug 'skywind3000/vim-dict'
call plug#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"
" 简明帮助
" :PlugList       - 列出配置过的插件
" :PlugInstall    - 安装插件; 附加`!` 更新插件，或只用:PlugUpdate
" :PlugUpdate     - 更新插件
" :PlugUpgrade    - 更新vim-plug自己
" :PlugStatus     - 检查插件状态
" :PlugSearch foo - 查找 foo; 附加`!` 刷新本地缓存
" :PlugClean      - 确认删除无用的插件; 附加`!`强制删除
"
"##### vim-plug end  ###########
"
"##### vim-latex/latex-suite  ###########
"打开dtx文件自定义命令
" autocmd BufNewFile,BufRead *.dtx source ~/.vim/bundle/vim-latex/ftplugin/dtx.vim
let g:tex_flavor='latex'      "解决打开空白tex文档时，latex-suite不能启动的问题
" let g:Tex_Flavor='latex'
" 控制编译过程中的警告信息
let g:Tex_IgnoredWarnings = 
	\'Underfull'."\n".
	\'Overfull'."\n".
	\'specifier changed to'."\n".
	\'You have requested'."\n".
	\'Missing number, treated as zero.'."\n".
	\'There were undefined references'."\n".
	\'Citation %.%# undefined'."\n".
	\"LaTeX hooks Warning"
let g:Tex_IgnoreLevel = 8
let g:Tex_GotoError = 0
" 控制编译方式和PDF浏览软件manjaro linux
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_CompileRule_pdf = 'xelatex -synctex=1 -interaction=nonstopmode -file-line-error-style $*'
" if $DESKTOP_SESSION == "plasma"
"     let g:Tex_ViewRule_pdf='okular'
" else
"     let g:Tex_ViewRule_pdf='evince'
" endif
let g:Tex_ViewRule_pdf='mupdf'
"##### vim-latex/latex-suite end  ###########
"
"##### vim-templates ###########
" 自定义模板所在文件夹
let g:templates_directory = '~/.vim/templates'
let g:templates_user_variables = [['EMAIL', 'GetEmail'],['AUTHOR', 'GetAuthor']]
function GetEmail()
   return 'fengzhenhua@outlook.com'
endfunction
function GetAuthor()
   return '冯振华'
endfunction
"##### vim-templates  end ###########
"
"##### auto fcitx5  ###########
let g:input_toggle = 0
function! Fcitx2en()
   let s:input_status = system("fcitx5-remote")
   if s:input_status == 2
      let g:input_toggle = 1
      let l:a = system("fcitx5-remote -c")
   endif
endfunction

function! Fcitx2zh()
   let s:input_status = system("fcitx5-remote")
   if s:input_status != 2 && g:input_toggle == 1
      let l:a = system("fcitx5-remote -o")
      let g:input_toggle = 0
   endif
endfunction

set ttimeoutlen=150
"退出插入模式
autocmd InsertLeave * call Fcitx2en()  "如果需要使用Fcitx5请取消前面的注释
"进入插入模式
autocmd InsertEnter * call Fcitx2zh() "如果需要使用Fcitx5请取消前面的注释
"##### auto fcitx end ######
" 设置ibus 自动切换输入法
" let g:ibus#layout = 'xkb:us::eng'
" let g:ibus#engine = 'table:wubi-jidian86'
"
" 键位绑定F2，迅速打开vimtree
map  <F2> :NERDTreeToggle<CR> " 普通模式
" 键位绑定F3，迅速打开Tagbar,展示文件结构
nmap  <F3> :Vista!!<CR>   " 普通模式
" 键位绑定，方便使用vim编辑md文件时快速预览
"##### markdown-preview.vim ######
autocmd FileType markdown nmap <silent> <F8> <Plug>MarkdownPreview        " 普通模式
autocmd FileType markdown imap <silent> <F8> <Plug>MarkdownPreview        " 插入模式
autocmd FileType markdown nmap <silent> <F9> <Plug>StopMarkdownPreview    " 普通模式
autocmd FileType markdown imap <silent> <F9> <Plug>StopMarkdownPreview    " 插入模式
"##### markdown-preview.vim end  ######
"##### vim-latex begin ######
autocmd FileType tex  nnoremap  <F6> <cmd>!pdflatex % <CR>              " pdflatex 编译
autocmd FileType tex  nnoremap  <F8> <cmd>!bibtex %:t:r.aux <CR>        " bibtex 编译辅助文件，生成文献引用
"##### vim-latex end ######
"Set  F5 to run and compile all language program
map <F5> :call  CompileRunGcc()<CR>
func! CompileRunGcc()
   exec "w"
   if &filetype == 'sh'
      :!time bash %
   elseif &filetype == 'python'
      exec "!time python3 %"
   elseif &filetype == 'c'
      exec "!g++ % -o %<"
      exec "!time ./%<"
   elseif &filetype == 'cpp'
      exec "!g++ % -o %<"
      exec "!time ./%<"
   elseif &filetype == 'java'
      exec "!javac %"
      exec "!time java %<"
   elseif &filetype == 'html'
      exec "!firefox % &"
   elseif &filetype == 'go'
      exec "!go build %<"
      exec "!time go run %"
   elseif &filetype == 'mkd'
      exec "!~/.vim/markdown.pl % > %.html &"
      exec "!firefox %.html &"
   endif
endfunc
" set for vim-auto-popmenu
" enable this plugin for filetypes, '*' for all files.
"let g:apc_enable_ft = {'text':1, 'markdown':1, 'php':1}
let g:apc_enable_ft = {'*':1}

" source for dictionary, current or other loaded buffers, see ':help cpt'
set cpt=.,k,w,b

" don't select the first item.
set completeopt=menu,menuone,noselect

" suppress annoy messages.
set shortmess+=c
" 取消欢迎界面
set shortmess+=I
" 启用主题
" set background=dark
" colorscheme base16-tokyo-night-storm
"---------- tokyonight set ----------
set termguicolors
let g:tokyonight_style = 'night' " available: night, storm
let g:tokyonight_enable_italic = 1
" let g:tokyonight_transparent_background = 1
colorscheme tokyonight
"---------- tokyonight end----------
"
"----------airline 状态栏主题------------
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
" let g:airline_powerline_fonts = 1
" let g:airline#extensions#tabline#enabled = 1 "关闭上面的提示栏
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#buffer_nr_show = 1        "显示buffer编号
let g:airline#extensions#tabline#buffer_nr_format = '%s:'
let g:airline#extensions#battery#enabled = 1
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰ '
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.dirty='⚡'
let g:airline_theme = "tokyonight"
" let g:airline_theme='onedark'          " 需要安装joshdick/onedark.vim主题插件
" let g:airline_theme='tomorrow'           " 需要安装joshdick/onedark.vim主题插件
" let g:airline_theme='molokai'          " 需要安装joshdick/onedark.vim主题插件
" let g:airline_theme='light'          
" ---------- airlne end ----------
"
"---------- lightline 状态栏----------
" set laststatus=2
" if !has('gui_running')
" 	set t_Co=256
" endif
" set noshowmode
" let g:lightline = {'colorscheme' : 'tokyonight'}
"---------- end lightline 状态栏----------
"
"--------------Coc.nvim----------------
let g:copilot_no_tab_map = v:true
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ exists('b:_copilot.suggestions') ? copilot#Accept("\<CR>") :
      \ CheckBackSpace() ? "\<Tab>" :
      \ coc#refresh()
" copilot 设置单独的按键
let g:copilot_no_tab_map = v:true
imap <silent><script><expr> <C-y> copilot#Accept("\<CR>")
" for rainbow
au FileType vim,tex,c,cpp,objc,objcpp call rainbow#load()
let g:rainbow_active = 1
" let g:rainbow_load_separately = [
"     \ [ '*' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
"     \ [ '*.tex' , [['(', ')'], ['\[', '\]']] ],
"     \ [ '*.cpp' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
"     \ [ '*.{html,htm}' , [['(', ')'], ['\[', '\]'], ['{', '}'], ['<\a[^>]*>', '</[^>]*>']] ],
"     \ ]

let g:rainbow_guifgs = ['RoyalBlue3', 'DarkOrange3', 'DarkOrchid3', 'FireBrick']
let g:rainbow_ctermfgs = ['lightblue', 'lightgreen', 'yellow', 'red', 'magenta']
"------------vista------------
"" How each level is indented and what to prepend.
" This could make the display more compact or more spacious.
" e.g., more compact: ["▸ ", ""]
" Note: this option only works for the kind renderer, not the tree renderer.
let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]

" Executive used when opening vista sidebar without specifying it.
" See all the avaliable executives via `:echo g:vista#executives`.
let g:vista_default_executive = 'ctags'

" Set the executive for some filetypes explicitly. Use the explicit executive
" instead of the default one for these filetypes when using `:Vista` without
" specifying the executive.
let g:vista_executive_for = {
  \ 'cpp': 'vim_lsp',
  \ 'php': 'vim_lsp',
  \ }

" Declare the command including the executable and options used to generate ctags output
" for some certain filetypes.The file path will be appened to your custom command.
" For example:
let g:vista_ctags_cmd = {
      \ 'haskell': 'hasktags -x -o - -c',
      \ }

" To enable fzf's preview window set g:vista_fzf_preview.
" The elements of g:vista_fzf_preview will be passed as arguments to fzf#vim#with_preview()
" For example:
let g:vista_fzf_preview = ['right:50%']
" Ensure you have installed some decent font to show these pretty symbols, then you can enable icon for the kind.
let g:vista#renderer#enable_icon = 1

" The default icons can't be suitable for all the filetypes, you can extend it as you wish.
let g:vista#renderer#icons = {
\   "function": "\uf794",
\   "variable": "\uf71b",
\  }
" 模糊查找leaderF 配置
" don't show the help in normal mode
let g:Lf_HideHelp = 1
let g:Lf_UseCache = 0
let g:Lf_UseVersionControlTool = 0
let g:Lf_IgnoreCurrentBufferName = 1
" popup mode
let g:Lf_WindowPosition = 'popup'
let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2", 'font': "DejaVu Sans Mono for Powerline" }
let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0 }

let g:Lf_ShortcutF = "<leader>ff"
noremap <leader>fb :<C-U><C-R>=printf("Leaderf buffer %s", "")<CR><CR>
noremap <leader>fm :<C-U><C-R>=printf("Leaderf mru %s", "")<CR><CR>
noremap <leader>ft :<C-U><C-R>=printf("Leaderf bufTag %s", "")<CR><CR>
noremap <leader>fl :<C-U><C-R>=printf("Leaderf line %s", "")<CR><CR>

noremap <C-B> :<C-U><C-R>=printf("Leaderf! rg --current-buffer -e %s ", expand("<cword>"))<CR>
noremap <C-F> :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>
" search visually selected text literally
xnoremap gf :<C-U><C-R>=printf("Leaderf! rg -F -e %s ", leaderf#Rg#visual())<CR>
noremap go :<C-U>Leaderf! rg --recall<CR>

" should use `Leaderf gtags --update` first
let g:Lf_GtagsAutoGenerate = 0
let g:Lf_Gtagslabel = 'native-pygments'
noremap <leader>fr :<C-U><C-R>=printf("Leaderf! gtags -r %s --auto-jump", expand("<cword>"))<CR><CR>
noremap <leader>fd :<C-U><C-R>=printf("Leaderf! gtags -d %s --auto-jump", expand("<cword>"))<CR><CR>
noremap <leader>fo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>
noremap <leader>fn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>
noremap <leader>fp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>
EOF
