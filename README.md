# script 仓库 #

![Static Badge](https://img.shields.io/badge/diary.sh-V14.0-purple)
![Static Badge](https://img.shields.io/badge/lugit.sh-V11.0-purple)
![Static Badge](https://img.shields.io/badge/syndns.sh-V3.5-purple)
![Static Badge](https://img.shields.io/badge/updatehost.sh-V1.4-purple)
![Static Badge](https://img.shields.io/badge/stirling.sh-V1.0-purple)
![Static Badge](https://img.shields.io/badge/xugit.sh-V8.0-purple)
![Static Badge](https://img.shields.io/badge/neogit.sh-V4.0-green)
![Static Badge](https://img.shields.io/badge/ugit.sh-V2.1-green)
![Static Badge](https://img.shields.io/badge/archsetup.sh-V1.4-green)
![Static Badge](https://img.shields.io/badge/ParuAxel.sh-V1.2-green)
![Static Badge](https://img.shields.io/badge/makepkg.sh-V1.1-green)
![Static Badge](https://img.shields.io/badge/zugit.sh-V10.6-green)


`xugit.sh`和`diary.sh`的`选择菜单`支持`vim`的快捷键，即`j`向下，`k`向上，同时`J`向下一页，`K`向上一页.

## stirling.sh ##

- 2024年12月04日, 在 `ArchLinux` 下使用`paru`配置`stirling-pdf-bin`. 原始作者并未正确配置启动器，本脚本作用即是自动配置正确可用的启动器。

## syndns.sh ##

- 2024年11月30日, 增加 `DNS`本地缓存脚本 `syndns.sh`, 版本号 `V1.2`
- 2024年12月01日, 修复探测依赖包的`bug`, 因为有的包名称与实际提供的程序不一致，升级版本号`V1.3`
- 2024年12月02日, 增加自动探测`IP`并追加到`dnsmasq`的功能，首先从`firefox`导出游览历史，然后执行命令
  ```sh
  syndns ~/bookmarks-2024-12-01.json
  ```
  然后程序就会使用`dig`自动探测`IP`，然后保存在`~/.host_dns_autoadd.txt`文件中，每次开机`syndns`程序就
  会将其调入内存。升级版本号`V1.4`
- 2024年12月02日, 修复依赖`jq`的自动检测`bug`, 默认从google public dns 解析本地历史`IP`, 同时修复自动命令名称错误。升级版本号`V1.5`
- 2024年12月02日, 修复几个`bug`, 同时过滤掉多余的空格，尽量减少字符，整体去除重复的行，使内存文件最小，提高查询速度。升级版本号`V1.7`
- 2024年12月05日, 将`github`添加到脚本中自动探测`IP`, 不再依赖`updatehost`. 升级版本号`V1.8`
- 2024年12月05日, 修复去除重复行过度的`Bug`, 升级版本号`V1.9`
- 2025年01月08日, 修复每次启动导致`sudo`无法接收密码的错误，停用每次启动都写入`hosts`文件的行为，改为手动选项`-r`操作。升级版本号`V3.5`

## lugit.sh ##

- 2024年12月14日, 接管`zugit.sh`, 取消仓库安装到`U盘`, 默认建立仓库到本地硬盘，同步到网络的仓库需单独使用`ugit --ad`添加到运程同步。升级版本号 `V11.0`

## zugit.sh 超强版 ##

- 2024年06月29日, 完成了对`xugit.sh`的大副改写，采用数组集合的概念重构了需要同步、克隆、删除的仓库部分，且增加了每个仓库的`id`号。使用`.uregister`取代`.ugitmap`, 数据结构更加合理。优化了网址探测程序`USB_DETECT_URL`, 精简了代码，更方便拓展。由于新结构的实现，可以大幅度增加可拓展性，因此今后不再维护`xugit.sh`, 新的`ugit`将以`zugit.sh`的形式继续发展。升级版本号`V9.0`.
- 2024年07月02日, 修复`ls -lid`列出表单时，使用`awk`取得路径错误。升级版本号`V9.1`
- 2024年07月05日, 修复组装电脑机`USB_COMMENT`为空的错误。升级版本号`V9.2`
- 2024年07月05日, 增加主题颜色选择程序。升级版本号`V9.3`
- 2024年07月05日, 修复远程连接非仓库`U盘`,但是本地不存在导致的列出本地仓库错误。升级版本号`V9.4`
- 2024年07月07日, 增加主题颜色样式，并升级选择方式。升级版本号`V9.5`
- 2024年07月08日, 优化分隔符和`USB_COMMENT`。升级版本号`V9.6`
- 2024年07月14日, 增加上下左右方向键,home, end,pgup,pgdn 导航功能，升级版本号`V9.7`
- 2024年07月15日, 修改end键默认选中最后一行，升级版本号`V9.8`
- 2024年07月15日, 优化菜单显示，升级版本号`V9.9`
- 2024年08月01日, 增加仓库搬家功能，将仓库同步转移到另一个U盘，以防止U盘损坏导致的数据损失，升级版本号`V10.0`
- 2024年08月10日, 传输符号使用`Unicode`取代，更加美观，升级版本号`V10.1`
- 2024年10月20日, 取消对`fastfetch`的依赖，`COMMENT` 修改为`Linux`唯一标识`机器码`, 升级版本号`V10.2`.
- 2024年11月05日, 修改网络检测机制，简化代码。升级版本号`V10.3`.
- 2024年11月30日, 修改`COMMENT`为用户名+`IP`。升级版本号`V10.4`.
- 2024年12月01日, 修复自动`COMMENT`的`BUG`。升级版本号`V10.5`.
- 2024年12月04日, 修复强制`PUSH`时`COMMENT`遗漏`BUG`. 升级版本号`V10.6`
- 2024年12月14日, 因U盘经常损坏，停止使用此版本，但是为了确保特殊情况下可用，仍然保留此脚本。建议改用`lugit.sh`

## diary.sh博客管理脚本 ##

- 2024年05月21日, `diary.sh`, 增加输出对齐， 升级版本号`V10.0`
- 2024年05月21日, 修复仅列出仓库时出现选项`[s] 选择`的问题，升级版本号`V6.5`
- 2024年05月21日, 修复`diary.sh`和`xugit.sh`中的列表`bug`, 二者采用完全相同的列表模块，分别升级版本号`V10.1`和`V6.6`
- 2024年05月21日, `diary.sh`升级路径，默认更改为`gitee`, 升级版本号`V10.2`
- 2024年05月21日, `diary.sh`和`xugit.sh`升级模块采用相多网址检测，分别升级版本号`V10.4`和`V6.7`
- 2024年05月21日, `diary.sh`去除安装脚本bug, 升级版本号`V10.5`
- 2024年05月22日, `diary.sh`去除推送和选项`-xl`提示bug, 优化了系统稳定性, 升级版本号`V10.6`
- 2024年05月24日, `diary.sh`和`xugit.sh`改进选择程序，分别升级版本号`V10.8`和`V6.9`
- 2024年05月26日, `diary.sh`和`xugit.sh`采用全新选择程序框架，可以按光标选择选项，分别升级版本号`V10.9`和`V7.0`
- 2024年05月26日, `diary.sh`修复`-xl`列出bug, 升级版本号`V11.0`.
- 2024年05月26日, `diary.sh`和`xugit.sh`升级选择菜单，避免闪烁，增加最低端显示光标行号，分别升级版本号`V11.1`和`V7.1`
- 2024年05月27日, `diary.sh`和`xugit.sh`增加高亮配色，默认高亮色设置为蓝色+白字. 增加序号对齐到最大位数, 以`printf`取代`echo`，但是原`echo`版本请参考文章[Shell脚本编写可选择菜单](https://fengzhenhua.gitlab.io/2024/05/26/Shell脚本编写可选择菜单/), 分别升级版本号`V11.2`和`V7.3`
- 2024年05月27日, `diary.sh`去除显示列表中的拓展名`.md`, 函数`NEO_LIST`与标准版稍有差异，升级版本号`V11.3`
- 2024年05月28日, `diary.sh`改进过滤程序，在执行`-xl`时方便的去除不想显示的内容，升级版本号`V11.5`
- 2024年06月21日, `diary.sh`升级`Push`命令为选择式选择，升级版本号`V11.7`
- 2024年06月22日, `diary.sh`优化`Push`命令选择式菜单，升级版本号`V11.8`
- 2024年07月05日, `diary.sh`增加新建博客选择`tags`功能，同时自动定位到书写博客位置。升级版本号`V11.9`
- 2024年07月05日, `diary.sh`增加主题颜色选择程序。升级版本号`V12.0`
- 2024年07月07日, `diary.sh`增加主题颜色样式，并升级选择方式。升级版本号`V12.1`
- 2024年07月08日, `diary.sh`优化分隔线符和删除提示符。升级版本号`V12.2`
- 2024年07月12日, `diary.sh`优化删除提示。升级版本号`V12.3`
- 2024年07月14日, `diary.sh`增加上下左右方向键,home,end,pgup, pgdn 导航功能，升级版本号`V12.4`
- 2024年07月15日, 修改end键默认选中最后一行，升级版本号`V12.5`
- 2024年07月15日, 优化菜单显示，升级版本号`V12.6`
- 2024年09月27日, 修改`Next`主题升级地址为`https://github.com`, `git clone`的工作由`~/.gitconfig`文件决定。升级版本号`V12.7`
- 2024年09月27日, 完全去除`gitlab-runner`的检测，安装脚本会自动配置好`gitlab-runner`的`root`权限运行。升级版本号`V12.8`
- 2024年10月06日, 加入默认编辑器检测程序，如果没有安装`nvim`和`vim`, 则脚本安装完`nvim`和`vim`后再重启脚本即可。升级版本号`V12.9`.
- 2024年10月20日, 取消对`fastfetch`的依赖，修改`COMMENT`为机器码，因为在`Linux`中机器码可以唯一标识机器。升级版本号`V13.0`.
- 2024年11月05日, 修改网络检测机制，简化代码。升级版本号`V13.1`.
- 2024年11月30日, 修改`COMMENT`为用户名+`IP`。升级版本号`V13.2`.
- 2024年12月01日, 更改判断依赖软件安装方式为通用`which`命令。升级版本号`V13.3`.
- 2024年12月29日, 由于GitLab强制迁移到付费的极狐GitLab, 所以决定修改diary.sh支持github, 不再维护gitlab版本。直接升级版本号`V14.0`

## xugit.sh增强版 ##

- 2024年05月09日, 完成了增强版`U盘`同步程序`xugit.sh`. 写这支程序的动机是为了解决文件夹误删除，同时如果被改名时能够智能找回或重建，此版采用[uuid](https://zhuanlan.zhihu.com/p/438580928)来唯一识别主机上的`HOME`挂载硬盘和相应的`U盘`, 它不依赖于`U盘`和仓库的名称来识别设备，所以可以自动校准电脑和U盘上的仓库，所以我称之为增强版。同时在实现逻辑上比之前的版本也进步了一大截，所以无特别需求的话，您应当下载使用增强版`xugit.sh`, 安装后其命令仍然为`ugit`, 使用`ugit -h`查看帮助信息。

- 此版，将同步网络的配置内容保存于`U盘`仓库，不受主机限制，所以配置一次即可走遍天下。同时，也取消了对本地`~/.ugitmap`的引用，专而将其建立在`U盘`端，这也可以避免受限于本地，所以更加合理。

- 增强版还优化了命令，强调易用性，对于同步的和操作实现自动化，仅保留几项常用的操作，所以它更加实用。

- 为了保留近二十多天的劳动成果，所以同时保存了三个版本的程序，也可以作为大家学习之用,但是未来本人将只维护`xugit.sh`，同时由于实现逻辑上的巨大差异，增强版`xugit.sh`直接升级至`V5.0`, 2024年05月09日版本号`V5.2`.

## 版本历史 ##

- 2024年04月16日, 获得使用`U盘`作为`Git`仓库的方法后，为了尽快投入工作，连夜编写了自动化脚本`ugit.sh`，直接使用`curl`命令安装可以保证始终使用的是最新版。
- 2024年04月19日, `ugit.sh`目前仅支持`Linux`系统，欢迎您移植到`Windows`平台。
- 2024年04月22日, `neougit.sh`发布，版本号`V3.1`, 支持多`U盘`。
- 2024年04月22日, 修复关联远程仓库bug, 升级版本号`V3.3`
- 2024年04月23日, 增加`-s`同步选项，升级版本号`V3.5`, 对于`U盘`中已经删除的仓库，但是另一台电脑上尚没有删除的，此选项将其移除到回收站
- 2024年05月09日, 实现增强版`xugit.sh`, 使用`uuid`唯一识别设备，几乎重构，将其直接升级版本号`V5.2`
- 2024年05月11日, 增加U盘容量检测，根据使用百分比超过阈值(默认`95%`)时，给出提示，升级版本号`V5.3`
- 2024年05月11日, 增加多U盘在建立仓库时输入选择编号时的数值判断，升级版本号`V5.4`
- 2024年05月14日, 优化检测U盘是否挂载判断，升级版本号`V5.5`
- 2024年05月14日, 去除新建仓库不列出已经存在仓库的Bug, 升级版本号`V5.6`
- 2024年05月15日, 修复探测U盘是否插入的Bug, 升级版本号`V5.7`
- 2024年05月15日, 修复探测本地缺失仓库时漏识别的Bug, 同时删除到回收站改用标准的`trash-put`命令，这样方便找回。之前的
```sh
mv  -t ~/.local/share/Trash/files --backup=t "${USB_LOCAL_MAP[$k]}"
```
会导致文件回收困难，所以不再使用。升级版本号`V5.9`
- 2024年05月16日, 完善升级程序和脚本依赖程序安装，增加直接从gitee升级，将gitlab设置为备用升级源。升级版本号`V6.0`
- 2024年05月16日, 解决升级错误Bug, 升级版本号`V6.1`
- 2024年05月20日, 优化网络检测，由于校园网默认百度可以访问，所以避免此网站，升级版本号`V6.2`
- 2024年05月21日, 增加输出对齐功能，规范输出格式，优化函数`DY_LIST`, 升级版本号`V6.4`
- 2024年05月26日, `xugit.sh`去除删除和新建`bug`, 升级版本号`V7.2`
- 2024年05月27日, `xugit.sh`引入UTF8符号，优化了箭头显示，升级版本号`V7.4`
- 2024年05月27日, `xugit.sh`将`-l`选项，加入编辑功能，升级版本号`V7.5`
- 2024年05月27日, `xugit.sh`将`-l`选项，编辑功能加入回归上一级选项，升级版本号`V7.6`
- 2024年05月28日, `xugit.sh`和`diary.sh`，修复列表误触时退出bug, 分别升级版本号`V7.7`和`V11.4`
- 2024年05月30日, `xugit.sh`增加编辑后push到仓库的功能，升级版本号`V7.8`
- 2024年06月10日, `xugit.sh`补全帮助菜单，升级版本号`V7.9`
- 2024年06月22日, `xugit.sh`优化`USB_GET_MAP`函数，将`while`循环替换为数组直接操作，提高效率。同时函数中以`USB_REMORT_MAP`最初获取加入`grep`过滤掉非仓库，提高效率。升级版本号`V8.0`

### 单U盘版和多U盘版说明 ###

最初只是想用U盘作为教程仓库，解决现存托管平台的若干问题。但是，随着近两天的考虑，逐步实现了本地`U盘`仓库及时同步+联网同步（可选择仓库，用来发布软件）的功能，这种做法的优点是：

- 所有仓库在本地`U盘`, 可以解决网络托管平台访问速度慢、容量有限、费用高、隐私保护等问题。
- 对于不能联网的电脑，可以使用`U盘`仓库随时随地编辑代码，离线同步。
- 对于开源代码，可以设置网络，一条命令实现本地+U盘+网络托管平台同步功能，及时发布最新软件。
- 配置文件： 网络托管平台`githab`、`gitlab`和`gitee`等已经配置了`ssh`或公开的仓库。
```she ~/.ugitrcf 
example:
gitee  https://github.com/project.git
gitee  git@gitee_fengzhenhua:fengzhenhua
gitlab  git@gitlab_fengzhenhua:fengzhenhua
```

配置文件设置后，脚本自动启用网络同步功能。`~/.ugitrcf`前2行格式范例，不起作用，<label style="color:red">且不能删除</label>，您的有效配置应当<label style="color:red">从第3行开始</label>。

## ugit 项目 ##

### 安装脚本 ###

- 安装<label style="color:red">单U盘</label>版本
```sh Install ugit.sh
sudo curl -o /usr/local/bin/ugit https://gitlab.com/fengzhenhua/script/-/raw/usbmain/ugit.sh\?inline\=false 
sudo chmod +x /usr/local/bin/ugit
```
注意：单U盘版是第一代试验性的方案，目前已经实现多U盘版，且功能更加实用，所以单U盘版不再维护。其存在的问题主要是根据U盘名称识别U盘仓库，如果用户修改了U盘名称或使用了同名的其他U盘，则会出现问题，所以不建议大家使用单U盘版。

- 安装<label style="color:red">多U盘</label>版本
```sh Install neougit.sh
sudo curl -o /usr/local/bin/ugit https://gitlab.com/fengzhenhua/script/-/raw/usbmain/neogit.sh\?inline\=false 
sudo chmod +x /usr/local/bin/ugit
```

- 安装<label style="color:red">增强U盘</label>版本
```sh Install neougit.sh
sudo curl -o /usr/local/bin/ugit https://gitlab.com/fengzhenhua/script/-/raw/usbmain/xugit.sh\?inline\=false 
sudo chmod +x /usr/local/bin/ugit
```

### 选项及功能 ###

各项操作前，先将`U盘`插入到Linux电脑的USB接口, 如果没有`U盘`连接电脑则会出现提示。

#### 增强U盘版 ####

|命令|功能|备注|
|:--|:--|:--|
|`ugit -ad` |关联远程网络仓库|2024年04月19日,需设置`U盘/.ugitrcf`|
|`ugit -h` |显示帮助|2024年04月19日|
|`ugit -l` |列出`U盘`仓库|2024年04月18日|
|`ugit -n` |新建`U盘`仓库并克隆到本地|2024年04月16日|
|`ugit --pull` |远程仓库==>本地仓库|2024年05月9日|
|`ugit --push` |远程仓库<==本地仓库|2024年05月9日|
|`ugit -r` |删除`U盘`中已经建立的仓库|2024年04月16日|
|`ugit -s`| 同步本地、U盘、网络|2024年04月23日|
|`ugit -u` |联网升级|2024年04月18日|
|`ugit -v` |显示版本|2024年04月19日|
|`ugit`    |同`ugit -s`|2024年04月17日|
|`ugit.sh -i`|安装脚本到`/usr/local/bin/ugit`|2024年04月16日|

#### 单U盘版和多U盘版 ####

|命令|功能|备注|
|:--|:--|:--|
|`ugit -a` |克隆全部`U盘`仓库到本地仓库|2024年04月17日|
|`ugit -ad` |关联远程网络仓库|2024年04月19日,需设置`~/.ugitrcf`|
|`ugit -b` |上传全部本地仓库到`U盘`仓库和网络仓库|2024年04月19日|
|`ugit -c` |克隆`U盘`中已经建立的仓库|2024年04月16日|
|`ugit -h` |显示帮助|2024年04月19日|
|`ugit -l` |列出`U盘`仓库|2024年04月18日|
|`ugit -ll` |列出本地仓库|仅适用多U盘版2024-04-22|
|`ugit -lr` |列出`U盘`仓库|仅适用多U盘版2024-04-22|
|`ugit -n` |新建`U盘`仓库并克隆到本地|2024年04月16日|
|`ugit -p` |上传全部本地仓库到网络仓库|2024年04月18日|
|`ugit -r` |删除`U盘`中已经建立的仓库|2024年04月16日|
|`ugit -s`| 同步本地、U盘、网络|2024年04月23日|
|`ugit -u` |联网升级|2024年04月18日|
|`ugit -v` |显示版本|2024年04月19日|
|`ugit`    |自动更新本机克隆自`U盘`的仓库|2024年04月17日|
|`ugit.sh -i`|安装脚本到`/usr/local/bin/ugit`|2024年04月16日|

## 技术细节 ##

1. 插入电脑`U盘`, 假设您的`U盘`名字为`159xxxxxxxx`, 您的`Linux`用户名为`wheel`, 则在`ArchLinux`下`U盘`的地址为
```sh 
/run/media/wheel/159xxxxxxxx
```

2. 在`U盘`创建空仓库`test`, 实际就是建立一个文件夹作为`git`的远程仓库
```sh
cd /run/media/wheel/159xxxxxxxx
mkdir test
cd test
git init --bare
``` 

注意：选项`--bare`必须有, 如果git仓库创建成功，则提示消息为
```sh
Initialized empty Git repository in /run/media/wheel/150xxxxxxxx/test/
```

2. <label style="color:red">切换到电脑中您的项目目录</label>，初始化本地仓库
```sh
cd ~/test-your
git init
```

3. 建立远程仓库连接,编辑本地`git`配置文件，写入如下内容，关联仓库及其分支
```sh ~/test-your/.git/config 
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true
[remote "usb"]
    url = /run/media/wheel/159xxxxxxxx/test/
    fetch = +refs/heads/*:refs/remotes/usb/*
[branch "master"]
    remote = usb
    merge = refs/heads/master
```

注意：文件`~/test-your/.git/config`, 中的`usb`是您对远程仓库的别名，可以任意取定。

4. 创建`README.md`文件，同第一次推送文件，注意<label style="color:red">此时仍然在您的项目目录</label>中。
```sh
git pull
touch README.md 
git add .
git commit -m "first push"
git push
``` 

5. 拉取文件, 注意<label style="color:red">此时仍然在您的项目目录</label>中。
```sh 
git pull
```

6. 在新电脑上克隆项目
```sh 
git clone /run/media/wheel/159xxxxxxxx/test
``` 

注意：对于`clone`下来的项目，`push`和`pull`和普通的`git`操作没有区别。如果不像上面这样编辑默认的默认的仓库及分支，则网络上的教程[在U盘上建立git仓库，移动的“私有云”](https://chuyao.github.io/2017/11/17/git-usb/)完成的配置的话应当使用命令`pull usb master`拉取，使用`push usb master`推送，其显然不如此处的配置便捷。

<details><summary>实现此脚本的最初说明</summary>
常用的代码托管平台有：github、gitlab和gitee.  github访问不是很稳定，同时只有付费版的才可以建立私有仓库，否则就是开放的。gitlab支持私有仓库的建立，但是注册gitlab需要google接收验证码，这在国内不容易做到，再者仓库容量5G, 有些不够用. gitee是国内的，优点是速度快，缺点容量也是5G，还有一些其他因素导致也不适合存放隐私文件。上述这些都是自己准备一个U盘建立自己的远程仓库的理由，优点无非是容量大，成本低，速度快，但也不是没有缺点，如果使用的U盘质量不过关那就面临资料损失的风险，所以<label style="color:red">需要使用一个稳定的大品牌U盘同时及时备份到第二块U盘</label>. 
</details>
