export PATH=/Users/sagiring/development/flutter/bin:/opt/homebrew/opt/mysql-client/bin:/Users/sagiring/.jenv/shims:/Users/sagiring/.jenv/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/usr/local/corplink/mdm/opt/corplink-mdm/bin:/Applications/iTerm.app/Contents/Resources/utilities:/opt/nvim-macos/bin/:/opt/homebrew/bin/:~/script

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# export NAMESRV_ADDR=$(hostname -I | awk '{print $1}'):9876
# export MAVEN_HOME=/opt/homebrew/Cellar/maven/3.9.8/

export PATH="$PATH:/opt/nvim-macos/bin/"
export EDITOR=/opt/nvim-macos/bin/nvim/
export PATH="$PATH:/opt/homebrew/bin/"
export LESSOPEN="|/opt/homebrew/bin/lesspipe.sh %s"
export VISUAL=nvim
export EDITOR="$VISUAL"

export PATH="$PATH:~/script"

export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo'
# don't put duplicate lines or lines starting with space in the history.


export BASH_SILENCE_DEPRECATION_WARNING=1
[[ `ps -ef | grep ssh-agent | grep -v "\-l" | wc -l`>1 ]] && ssh-agent; ssh-add
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export LANG="en_US.UTF-8"
export HOMEBREW_NO_AUTO_UPDATE=true
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"


if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

export PATH="$HOME/.local/bin:$PATH"

# Added by AI Skills keyring.sh
export ALPHA_LOG_USER="zhangjingming8725"
