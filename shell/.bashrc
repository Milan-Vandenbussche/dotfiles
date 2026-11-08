#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Disable terminal / readline bell sound
bind 'set bell-style none' 2>/dev/null || true

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='\[\e[1;34m\][\u@\h \W]\$\[\e[0m\] '
export PATH="$HOME/.local/bin:$PATH"
fastfetch

export PATH=$PATH:/home/ciganycenter/.spicetify
