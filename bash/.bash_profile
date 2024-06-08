# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export NAMESRV_ADDR=$(hostname -I | awk '{print $1}'):9876

export PATH="$PATH:/opt/nvim-linux64/bin"
export EDITOR=/opt/nvim-linux64/bin/nvim
export PATH="$PATH:/opt/idea/bin"

export ROCKETMQ_HOME=/opt/rocketmq-all-5.2.0-bin-release
export PATH="$PATH:$ROCKETMQ_HOME/bin"
# use vim as standard editor
export VISUAL=nvim
export EDITOR="$VISUAL"
if [ -d "/mnt/e/Software/Microsoft VS Code/bin" ]; then
	export PATH="$PATH:/mnt/e/Software/Microsoft VS Code/bin"
else
	export PATH="$PATH:/mnt/c/Program File/Microsoft VS Code/bin"
fi
export PATH="$PATH:~/script"

export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:jre/bin/java::"| sed "s:bin/java::")
# export JAVA_HOME=/usr/lib/jvm/jdk-17.0.11+9
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo'
# don't put duplicate lines or lines starting with space in the history.

if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi


if [ -d "$HOME/.cargo/env" ]; then
	. "$HOME/.cargo/env"
fi

export PATH="/home/sagiring/.local/share/solana/install/active_release/bin:$PATH"


export PATH=$(python -c 'import site; print(site.USER_BASE + "/bin")'):$PATH
