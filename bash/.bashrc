# don't put duplicate lines or lines starting with space in the history.
#
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=50000
HISTFILESIZE=100000
HISTTIMEFORMAT="%F %T "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
# shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
# lesspipe will activate by ".bash_profile"
lessc() { 
    local less_script
    less_script=$(ls -d /usr/share/vim/vim*/macros/less.sh 2>/dev/null | tail -n 1)
    if [ -n "$less_script" ] && [ -x "$less_script" ]; then
        "$less_script" "$@"
    else
        less "$@"
    fi
}

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
	xterm-color|*-256color) color_prompt=yes;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi


if [ "$color_prompt" = yes ]; then
	# \d: Date, \u: User, \W: Current directory basename, \$: Prompt symbol
	PS1='\[\033[1;33m\]\d\[\033[00m\] \[\033[0;32m\]\u\[\033[00m\] \[\033[01;34m\]\W\[\033[00m\]\n\[\033[0;31m\]\$\[\033[00m\] ' 
	# PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt


# If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm*|rxvt*)
#     PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#     ;;
# *)
	#     ;;
	# esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

if [ -x /opt/homebrew/bin/gdircolors ]; then
        alias ls="gls --color=auto"
        alias dir="gdir --color=auto"
        alias vdir="gvdir --color=auto"
	    alias grep='grep --color=auto'
	    alias fgrep='fgrep --color=auto'
	    alias egrep='egrep --color=auto'

fi

# use nvim if available
if [ -x "$(command -v nvim)" ]; then
	alias vim='nvim'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
# alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alert() {
    local exit_status=$?
    if command -v terminal-notifier >/dev/null 2>&1; then
        terminal-notifier -title "Terminal" -message "Done with task! Exit status: $exit_status"
    elif [ "$exit_status" -eq 0 ]; then
        echo -e "\033[0;32m[Alert] Task completed successfully.\033[0m"
    else
        echo -e "\033[0;31m[Alert] Task failed with exit status: $exit_status\033[0m"
    fi
    return $exit_status
}

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
		. /opt/homebrew/etc/profile.d/bash_completion.sh
	elif [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

 [ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh



# Find out what's running on a given port
port() {
	lsof -i tcp:$1
}
# Set colors for man pages
man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
		man "$@"
	}


socket=$(ls -1t /run/user/$UID/vscode-ipc-*.sock 2> /dev/null | head -1)
export VSCODE_IPC_HOOK_CLI=${socket}

# SSH host completion from ~/.ssh/config
if [ -f "$HOME/.ssh/config" ]; then
    complete -W "$(awk '$1=="Host" {for(i=2;i<=NF;i++) if($i !~ /[*?]/) print $i}' ~/.ssh/config 2>/dev/null | sort -u)" ssh
fi


# added by tools-all-in-one setup
export PATH="$PATH:/Users/sagiring/tools/tools-all-in-one/script/local/"
# moa 自动完成函数
# moa completion added by tools-all-in-one setup
_moa_completions()
{
    local cur opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    opts="vchat-service vchat-game-service vchat-gift-moa vchat-gift-business vchat-support-service vchat-task-service vchat-callback-service-v2 biz-spacey-back"
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    fi
    return 0
}

complete -F _moa_completions moa

complete -F _moa_completions moa_arthas

# opencode
export PATH=/Users/sagiring/.opencode/bin:$PATH

# Added by AI Skills keyring.sh
export ALPHA_LOG_USER="zhangjingming8725"
