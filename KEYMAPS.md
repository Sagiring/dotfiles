# ⌨️ Dotfiles 快捷键与使用技巧速查手册 (Cheatsheet)

本手册整理了当前环境中 **Neovim / Vim**、**Tmux**、**Bash 别名与实用函数**、**Git 别名** 的全部常用快捷键与操作指南。

---

## 1. 🚀 Neovim / Vim 快捷键

> **注**：`<leader>` 键已映射为 **`Space`（空格键）**。

### 1.0 🧠 快捷键“模块化英文缩写”记忆法（3 分钟快速上手）
> **核心记忆口诀**：**找东西按 `<Space>f + 首字母`，跳代码按 `g + 首字母`，搞 Git 按 `<Space>g + 首字母`。**

- **`g` 系列（Go to 跳转）**：
  - `gd` = **G**o to **D**efinition ➡️ 跳到**定义/接口**
  - `gi` = **G**o to **I**mplementation ➡️ 跳到**实现类**
  - `gr` = **G**o to **R**eferences ➡️ 找**引用** (Find Usages)
  - `gD` = **G**o to **D**eclaration ➡️ 跳到**声明**
- **`<Space>f` 系列（Find 搜索与查找）**：
  - `<Space>ff` = **F**ind **F**iles ➡️ 找**文件**
  - `<Space>fg` = **F**ind by **G**rep ➡️ 找**代码内容**（全局全文检索，支持 `\b` 词边界）
  - `<Space>fw` = **F**ind **W**ord ➡️ **全词精确搜索**光标所在单词（自动 `-w`）
  - `<Space>fW` = **F**ind **W**ord (Input) ➡️ **手动输入关键词进行全词精确搜索**
  - `<Space>fb` = **F**ind **B**uffers ➡️ 找已打开的 **Buffer/Tab**
  - `<Space>fd` = **F**ind **D**iagnostics ➡️ 找当前文件**警告与错误** (Warning/Error)
  - `<Space>fD` = **F**ind **D**iagnostics (All) ➡️ 找**全工程所有警告与错误**
  - `<Space>fs` = **F**ind **S**ymbols ➡️ 找 **Class 类名与方法符号**
- **`<Space>g` 系列（Git 版本管理）**：
  - `<Space>gb` = **G**it **B**ranches ➡️ 查分支并**一键切分支**（回车秒切）
  - `<Space>gc` = **G**it **C**ommits ➡️ 查**提交历史**
  - `<Space>gs` = **G**it **S**tatus ➡️ 查**修改状态**
- **日常最高频操作（单词首字母）**：
  - `<Space>w` = **W**rite ➡️ **保存文件** (`:w`)
  - `<Space>c` = **C**lose ➡️ **关闭当前 Tab**
  - `<Space>q` = **Q**uit ➡️ **退出窗口** (`:q`)
  - `<Space>e` = **E**xplorer ➡️ 开关左侧目录树
  - `<Space>rn` = **R**e**N**ame ➡️ 智能重命名变量/方法
  - `<Space>o` / `Ctrl + o` = **O**ut / **O**ld ➡️ **返回上一个光标/跳转位置**（Back，跳进代码后一键返回）
  - `<Space>i` / `Ctrl + i` = **I**n ➡️ **前进到下一个光标/跳转位置**（Forward）
  - `<Space>[` / `<Space>]` = 切换上/下一个文件 Tab（也可按 `<Space>bp` / `<Space>bn`）
  - `H` = **行首**（大写 H 跳行首非空字符）
  - `L` = **行尾**（大写 L 跳行尾）
  - `K` = 查看方法入参和 Javadoc 注释（Vim 传统“查看手册”键）

---

### 1.1 基础编辑与窗口导航
| 模式 | 快捷键 | 功能说明 |
|---|---|---|
| **Insert** | `jj` | 极速退出插入模式（替代 Esc） |
| **Normal** | `H` | 快速跳至当前行首非空字符（等同于 `^`） |
| **Normal** | `L` | 快速跳至当前行尾（等同于 `$`） |
| **Normal** | `<leader>w` | 快速保存文件 (`:w`) |
| **Normal** | `<leader>q` | 快速关闭当前窗口 (`:q`) |
| **Normal** | `<leader>c` | 快速关闭当前文件标签页 (`:bdelete`，未保存时弹窗提示) |
| **Normal** | `<leader><space>` | 清除搜索高亮颜色 (`:nohlsearch`) |
| **Visual** | `<` / `>` | 连续左/右缩进代码块（**自动保持选区**，无需重复选中） |
| **Visual** | `J` / `K` | 将选中的整块代码**上下平移** |
| **Visual** | `<leader>p` | 粘贴并**保护剪贴板**（不会被替换掉的内容覆盖寄存器） |

### 1.2 目录树与标签页（Nvim-Tree & Bufferline）
| 快捷键 | 功能说明 | 推荐记忆 |
|---|---|---|
| `<leader>e` 或 `Ctrl + n` | 展开 / 折叠左侧文件树 (`NvimTreeToggle`) | Explorer |
| `<leader>h` | 光标焦点快速跳入左侧目录树 | 向左跳进树 |
| `<leader>l` | 光标焦点从目录树切回右侧代码编辑窗口 | 向右跳回编辑器 |
| `<leader>]` 或 `<leader>bn` | **切换到下一个文件标签页** (`BufferLineCycleNext`) | 推荐 Space 键位 |
| `<leader>[` 或 `<leader>bp` | **切换到上一个文件标签页** (`BufferLineCyclePrev`) | 推荐 Space 键位 |
| `Ctrl + Shift + L` (`<C-L>`) | 切换到下一个文件标签页 | 备用 Ctrl 键位 |
| `Ctrl + Shift + H` (`<C-H>`) | 切换到上一个文件标签页 | 备用 Ctrl 键位 |

### 1.3 模糊检索与当前文件搜索（Telescope & Vim）
| 快捷键 | 功能说明 | 对应 IDEA 场景 |
|---|---|---|
| `/` | **Vim 原生行内高亮搜索**（回车后 `n`/`N` 下一个/上一个） | `Cmd + F` |
| `*` / `#` | **极速向前/向后搜索光标所在单词** | Highlight Word |
| `<leader>fl` 或 `<leader>/` | **当前文件交互式模糊检索**（Telescope 实时过滤） | `Cmd + F` 悬浮增强版 |
| `<leader>ds` | **当前文件类结构大纲与方法列表** | File Structure (`Cmd + F12`) |
| `<leader>ff` | **全局文件名搜索**（支持模糊匹配） | `Shift + Shift` / `Cmd + O` |
| `<leader>fg` | **全局代码内容搜索**（Live Grep，支持 `\b` 词边界正则） | `Cmd + Shift + F` |
| `<leader>fw` | **全词精确搜索光标所在单词**（自动 `-w` 严格全词匹配） | Match Whole Word with selection |
| `<leader>fW` | **手动输入关键词进行全词精确搜索** | Match Whole Word by prompt |
| `<leader>fb` | 查看当前所有已打开的 Buffers | Recent Files |
| `<leader>fo` | 查看历史最近打开过的文件 (Oldfiles) | Recent Files |
| `<leader>gb` | **查看并切换 Git 分支**（模糊搜索，回车秒切分支） | Git Branches Popup |
| `<leader>gc` | 查看 Git 提交历史列表 | Git Log |
| `<leader>gs` | 查看当前 Git 变更与状态文件 | Git Changes |
| `<leader>fs` | **全局检索 Class 类名与符号** | Search Everywhere (Classes/Symbols) |
| `<leader>fd` | **当前文件所有 Warning / Error 列表**（回车秒跳） | Document Problems |
| `<leader>fD` | **全工程所有 Warning / Error 列表** | Workspace Problems |

### 1.4 代码智能导航与跳转（无缝秒开，零卡顿）
| 快捷键 | 功能说明 | 对应 IDEA 场景 |
|---|---|---|
| `gd` 或 `<leader>rd` | **跳转到定义 (Go to definition)**（✨ **自动进入 Jar 包并反编译源码**） | `Cmd + B` / `Cmd + Click` |
| `gi` 或 `<leader>ri` | **查找接口实现 (Go to implementation)**（✨ **自动进入 Jar 包并反编译源码**） | `Cmd + Alt + B` |
| `gr` | **查找全部引用 (Find references)**（交互式浮窗列出所有引用代码） | `Alt + F7` |
| `<leader>o` / `Ctrl + o` | **返回上一个跳转/光标位置**（Back，原路返回上一个文件或引用位置） | `Cmd + [` / `Navigate Back` |
| `<leader>i` / `Ctrl + i` | **前进到下一个跳转/光标位置**（Forward，按多了返回可以再前进） | `Cmd + ]` / `Navigate Forward` |
| `gD` | 跳转到声明 (Go to declaration) | Go to Type Declaration |
| `K` | 查看悬浮文档说明 (Hover Doc) | `F1` / Quick Documentation |
| `<leader>fs` | **全局搜索类与符号**（交互式快速检索） | Search Everywhere (Classes/Symbols) |
| `<leader>rn` | 智能重命名符号 (Rename Symbol) | `Shift + F6` |
| `<leader>ca` | 快速修复与代码重构 (Code Action) | `Alt + Enter` (Show Context Actions) |
| `<leader>fm` 或 `<leader>cf` | 智能格式化代码 (Format) | `Cmd + Alt + L` |
| `[d` / `]d` | 上一个 / 下一个语法警告或编译错误 | Previous / Next Highlighted Error |
| `<leader>d` | 浮窗展示当前行的详细错误信息 | Show Error Description |
| `<leader>dq` | 在底部列表列出当前文件的所有诊断问题 | Show Problems Tool Window |

---

## 2. 🪟 Tmux 终端复用快捷键

> **注**：Tmux 前缀键（Prefix）为 **`Ctrl + a`**。

| 操作 | 快捷键 | 说明 |
|---|---|---|
| **水平分屏** | `Ctrl + a` 然后按 `|` | 左右并排分屏（自动继承当前路径） |
| **垂直分屏** | `Ctrl + a` 然后按 `-` | 上下分屏（自动继承当前路径） |
| **切换分屏** | `Alt + 方向键`（`←` `→` `↑` `↓`） | **无需前缀键**，直接跨面板平滑切换 |
| **复制模式** | `Ctrl + a` 然后按 `[` | 进入 Vi 浏览与复制模式 |
| └─ **选区文本** | `v` | （在复制模式下）开始选中字符 |
| └─ **复制到剪贴板** | `y` | （在复制模式下）复制选区并同步系统剪贴板 (`pbcopy`) |
| └─ **退出模式** | `q` 或 `Esc` | 退出复制模式 |
| **重载配置** | `Ctrl + a` 然后按 `r` | 即时重新加载 `~/.tmux.conf` |
| **新建窗口** | `Ctrl + a` 然后按 `c` | 创建新 Tab 窗口 |
| **切换窗口** | `Ctrl + a` 然后按 `1` ~ `9` | 切换到指定数字编号的 Tab 窗口 |

---

## 3. 🐚 Bash 别名与实用命令

### 3.1 常用目录与文件操作
| 别名 / 命令 | 完整命令 | 说明 |
|---|---|---|
| `..` | `cd ..` | 返回上一级目录 |
| `...` | `cd ../../` | 返回上两级目录 |
| `....` | `cd ../../../` | 返回上三级目录 |
| `ll` | `ls -lh` | 详细列表展示文件（易读大小） |
| `la` | `ls -lha` | 包含隐藏文件的完整详细列表 |
| `serve` | `python -m http.server` | 在当前目录快速启动本地 HTTP 文件服务 |

### 3.2 效率提升小工具
| 工具 / 函数 | 用法示例 | 说明 |
|---|---|---|
| `alert` | `mvn clean install; alert` | 耗时任务完成后发送系统弹窗通知并报告退出码 |
| `port` | `port 8080` | 快速排查指定 TCP 端口的占用进程 (lsof) |
| `o` | `o idea .` 或 `o chrome` | 模糊匹配并打开 macOS 应用程序 |
| `week` | `week` | 快速输出当前是今年的第几周 |
| `aicode` | `aicode` | 快速启动 Cursor 编辑器 |
| `c` | `c .` | 快速用 VS Code 打开当前目录 |

### 3.3 业务与基础工具
| 补全 / 命令 | 说明 |
|---|---|
| `moa <service>` | Momo 内部 MOA 服务名自动补全调用 |
| `moa_arthas <service>` | 一键接入对应 MOA 服务的 Arthas 诊断 |
| `ssh <tab>` | 自动读取 `~/.ssh/config` 里的 Host 主机名进行补全 |

---

## 4. 🐙 Git 快捷别名

| Alias 缩写 | 完整 Git 命令 | 说明 |
|---|---|---|
| `git st` / `git s` | `git status -sb` | 紧凑模式查看工作区状态 |
| `git co <branch>` | `git checkout <branch>` | 切换分支或检出文件 |
| `git br` | `git branch` | 查看本地分支列表 |
| `git ci` | `git commit` | 提交暂存区变更 |
| `git ll` | `git log --graph --decorate --oneline` | 极简单行彩色分支树状图 |
| `git l` | `git log --graph --decorate` | 完整分支树状图 |
| `git unstage <file>` | `git reset HEAD -- <file>` | 将文件移出暂存区 |
| `git last` | `git log -1 HEAD --stat` | 查看最近一次提交的详细 Diff 统计 |
| `git base` | `git merge-base HEAD master` | 查找当前分支与主干分支的交汇分叉点 Commit |
