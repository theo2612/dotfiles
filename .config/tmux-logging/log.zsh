# tmux-logging command hook for zsh.
# Appends every command you run to $TMUX_LOG_ROOT/<session>/cmd.log and
# drops a [CMD_START] marker into out.log so output lines up with commands.
#
# Only active inside tmux AND when logging is toggled on (prefix C-l).
# Source from ~/.zshrc:
#   [ -f ~/.config/tmux-logging/log.zsh ] && source ~/.config/tmux-logging/log.zsh
#
# Notes that land in cmd.log without running anything:
#   note found creds in web.config
#   n    trying kerberoast next

zmodload zsh/datetime
autoload -Uz add-zsh-hook

_tmux_log_cmd() {
    [[ -e $HOME/.tmux-logging ]] || return 0
    [[ -n $TMUX ]] || return 0

    local sess
    sess=$(tmux display-message -p '#S' 2>/dev/null) || return 0
    [[ -n $sess ]] || return 0
    sess=${sess//[ \/]/_}

    local dir="${TMUX_LOG_ROOT:-$HOME/LOGS}/$sess"
    [[ -d $dir ]] || mkdir -p "$dir"

    local ts cmd="$1" pane="${TMUX_PANE:-no-tmux}"
    strftime -s ts '%Y-%m-%d %H:%M:%S' $EPOCHSECONDS

    if [[ $cmd == note\ * ]]; then
        cmd=": #note ${cmd#note }"
    elif [[ $cmd == n\ * ]]; then
        cmd=": #note ${cmd#n }"
    fi

    print -r -- "[$ts] [pane=$pane] [CMD] $cmd" >> "$dir/cmd.log"
    print -r -- "[$ts] [pane=$pane] [CMD_START] $cmd" >> "$dir/out.log"
}
add-zsh-hook preexec _tmux_log_cmd

alias note=': #note'
alias n=': #note'
