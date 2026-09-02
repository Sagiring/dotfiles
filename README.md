# 🛠️ My Dotfiles

个人环境配置文件仓库（适用于 macOS / Linux WSL）。

## 📂 模块结构

- `bash/`: `.bash_profile`, `.bashrc`, `.bash_aliases`
- `vim/`: `.vimrc`
- `neovim/`: `.config/nvim/`
- `tmux/`: `.tmux.conf`
- `git/`: `.gitconfig`
- `script/`: 常用效率脚本（如 `o` 快速唤起应用、`moa-invoker` 等）
- `KEYMAPS.md`: 📖 [快捷键与使用技巧速查手册](./KEYMAPS.md)

---

## 🚀 快速安装 / 部署

本项目支持使用 **GNU Stow** 进行一键软链接管理：

```bash
# 1. 克隆或进入仓库
cd ~/dotfiles

# 2. 执行一键安装脚本（自动检测并调用 stow）
chmod +x install.sh
./install.sh
```

---

## ⌨️ 快捷键速查

完整的 Neovim/Vim、Tmux、Bash、Git 快捷键与使用技巧请参考：
👉 **[KEYMAPS.md](./KEYMAPS.md)**
