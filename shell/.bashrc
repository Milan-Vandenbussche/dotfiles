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
export PATH=$PATH:/home/ciganycenter/.spicetify

# Initialize zoxide (smarter cd that remembers frecent directories)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash --cmd cd)"
fi

# Yazi file manager wrapper: cd to directory on exit
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

fastfetch
