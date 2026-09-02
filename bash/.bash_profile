# ==============================================================================
# ~/.bash_profile - Login shell configuration
# ==============================================================================

# Locale & Environment
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export VISUAL=nvim
export EDITOR="$VISUAL"
export HOMEBREW_NO_AUTO_UPDATE=true
export BASH_SILENCE_DEPRECATION_WARNING=1
export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo'

# Added by AI Skills keyring.sh
export ALPHA_LOG_USER="zhangjingming8725"

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

if [ -x /opt/homebrew/bin/lesspipe.sh ]; then
    export LESSOPEN="|/opt/homebrew/bin/lesspipe.sh %s"
fi

# ------------------------------------------------------------------------------
# PATH Construction (Clean & Deduplicated)
# ------------------------------------------------------------------------------
PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

[ -d "/opt/homebrew/bin" ] && PATH="/opt/homebrew/bin:$PATH"
[ -d "/opt/homebrew/sbin" ] && PATH="/opt/homebrew/sbin:$PATH"
[ -d "/opt/homebrew/opt/mysql-client/bin" ] && PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
[ -d "/opt/nvim-macos/bin" ] && PATH="/opt/nvim-macos/bin:$PATH"
[ -d "$HOME/.jenv/bin" ] && PATH="$HOME/.jenv/bin:$PATH"
[ -d "$HOME/development/flutter/bin" ] && PATH="$HOME/development/flutter/bin:$PATH"
[ -d "$HOME/script" ] && PATH="$PATH:$HOME/script"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.opencode/bin" ] && PATH="$HOME/.opencode/bin:$PATH"
[ -d "$HOME/tools/tools-all-in-one/script/local" ] && PATH="$PATH:$HOME/tools/tools-all-in-one/script/local"

export PATH

# jenv setup
if command -v jenv >/dev/null 2>&1; then
    eval "$(jenv init -)"
fi

if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
fi
