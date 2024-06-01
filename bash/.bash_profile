# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


export PATH="$PATH:/opt/nvim-linux64/bin"
export EDITOR=/opt/nvim-linux64/bin/nvim
export PATH="$PATH:/opt/idea/bin"
# use vim as standard editor
export VISUAL=nvim
export EDITOR="$VISUAL"
export PATH="$PATH:/mnt/e/Software/Microsoft VS Code/bin"
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


. "$HOME/.cargo/env"

export PATH="/home/sagiring/.local/share/solana/install/active_release/bin:$PATH"


