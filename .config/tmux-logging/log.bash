# tmux-logging command hook for bash.
# Appends every command line you run to $TMUX_LOG_ROOT/<session>/cmd.log and
# drops a [CMD_START] marker into out.log so output lines up with commands.
#
# Only active inside tmux AND when logging is toggled on (prefix C-l).
# Source this as the LAST line of ~/.bashrc (it appends to PROMPT_COMMAND):
#   [ -f ~/.config/tmux-logging/log.bash ] && source ~/.config/tmux-logging/log.bash
#
# Notes that land in cmd.log without running anything:
#   note found creds in web.config
#   n    trying kerberoast next
#
# Commands typed with a leading space aren't saved to history, so they
# are not logged either.

# ignoredups would give a repeated command the same history number, and the
# hook would mistake it for a hidden one and skip it. Keep only ignorespace.
HISTCONTROL=ignorespace

_tmux_log_armed=

_tmux_log_cmd() {
    # The DEBUG trap fires for every simple command (each side of a pipe,
    # PROMPT_COMMAND itself). Only log the first one after each prompt.
    [ -n "$_tmux_log_armed" ] || return 0
    _tmux_log_armed=

    [ -e "$HOME/.tmux-logging" ] || return 0
    [ -n "${TMUX:-}" ] || return 0

    # The full line as typed, from history. $BASH_COMMAND only holds one
    # piece of a pipeline and loses `note` text after alias expansion.
    local num cmd
    read -r num cmd <<< "$(HISTTIMEFORMAT= builtin history 1)"
    [ -n "$num" ] || return 0
    [ "$num" != "${_tmux_log_last:-}" ] || return 0
    _tmux_log_last=$num

    local sess
    sess=$(tmux display-message -p '#S' 2>/dev/null) || return 0
    [ -n "$sess" ] || return 0
    sess=${sess//[ \/]/_}

    local dir="${TMUX_LOG_ROOT:-$HOME/LOGS}/$sess"
    [ -d "$dir" ] || mkdir -p "$dir"

    local ts pane="${TMUX_PANE:-no-tmux}"
    printf -v ts '%(%Y-%m-%d %H:%M:%S)T' -1

    if [[ $cmd == note\ * ]]; then
        cmd=": #note ${cmd#note }"
    elif [[ $cmd == n\ * ]]; then
        cmd=": #note ${cmd#n }"
    fi

    echo "[$ts] [pane=$pane] [CMD] $cmd" >> "$dir/cmd.log"
    echo "[$ts] [pane=$pane] [CMD_START] $cmd" >> "$dir/out.log"
}

trap '_tmux_log_cmd' DEBUG
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_tmux_log_armed=1"

alias note=': #note'
alias n=': #note'
