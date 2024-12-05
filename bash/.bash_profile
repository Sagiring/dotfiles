# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# export NAMESRV_ADDR=$(hostname -I | awk '{print $1}'):9876
# export MAVEN_HOME=/opt/homebrew/Cellar/maven/3.9.8/

export PATH="$PATH:/opt/nvim-macos/bin/"
export EDITOR=/opt/nvim-macos/bin/nvim/
export PATH="$PATH:/opt/homebrew/bin/"

export VISUAL=nvim
export EDITOR="$VISUAL"

export PATH="$PATH:~/script"

export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo'
# don't put duplicate lines or lines starting with space in the history.

if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

export BASH_SILENCE_DEPRECATION_WARNING=1
[[ `ps -ef | grep ssh-agent | grep -v "\-l" | wc -l`>1 ]] && ssh-agent; ssh-add
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export LANG="en_US.UTF-8"
