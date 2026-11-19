# dotfiles

Personal Kali dotfiles, managed as a bare git repository so the files in
`$HOME` are the source of truth (no copy-back-to-repo step).

- **Bare repo:**     `~/.dotfiles`
- **Work tree:**     `$HOME`
- **Remote:**        `git@github.com:theo2612/dotfiles.git`
- **Bootstrap:**     Kali: [`theo2612/kali-rebuild`](https://github.com/theo2612/kali-rebuild) (`scripts/07-configs.sh`). Other machines: see below.

## Currently tracked

| File                                  | Purpose                                              |
| ------------------------------------- | ---------------------------------------------------- |
| `.zshrc`                              | Kali shell config, aliases, functions                |
| `.tmux.conf`                          | tmux config: ctrl-a prefix, splits, status bar, logging hooks |
| `.gitconfig`                          | git identity                                         |
| `.zprofile`                           | zsh login-shell init                                 |
| `.config/tmux-logging/log.zsh`        | zsh command hook -> cmd.log                          |
| `.config/tmux-logging/log.bash`       | bash command hook -> cmd.log (source last in .bashrc)|
| `.local/bin/tmux-log-start`           | starts piping a pane into out.log                    |
| `.local/bin/tmux-log-filter`          | strips ANSI/prompts/noise from pane output           |
| `.local/bin/tmux-log-toggle`          | on/off switch (`prefix C-l`)                         |
| `.local/bin/tmux-status-target`       | Target/VPN in status bar, only when present          |
| `README.md`                           | this file                                            |

## tmux-logging

Same files on Kali (zsh) and Ubuntu (bash). Off by default.

1. `tmux new -s <box-name>`
2. `C-a C-l` to turn logging on (status bar shows LOG ON)
3. Logs go to `~/LOGS/<box-name>/cmd.log` and `out.log`
4. `note <text>` or `n <text>` drops a note into cmd.log

Status bar shows `Target:` only when `~/.ip` exists (`export IP=10.10.11.45`)
and `VPN:` only when a `tun0` interface is up.

Intentionally **not** tracked:
- `~/.ip` — per-target HTB box IP (changes every box)
- Anything under `~/.ssh/`, `~/.gnupg/`, `~/.BurpSuite/`, etc. (secrets)
- Application data: `~/.msf4`, `~/.bbot`, `~/.cache`, etc.

## Day-to-day workflow

Once `.zshrc` is loaded, the `dotfiles` alias maps to
`git --git-dir=$HOME/.dotfiles --work-tree=$HOME`:

```bash
dotfiles status               # show modified tracked files
dotfiles diff [~/.zshrc]      # show pending changes
dotfiles add ~/.zshrc         # stage an edit
dotfiles add ~/.config/...    # start tracking a new file
dotfiles commit -m "tweak"    # commit
dotfiles push                 # sync to GitHub
dotfiles pull                 # pull from GitHub (changed on another machine)
dotfiles log --oneline        # history
dotfiles ls-files             # list everything tracked
dotfiles rm --cached <file>   # stop tracking (keeps the file in $HOME)
```

The same reference is available in any shell via `dotfiles-help`
(function defined in `.zshrc`).

## Fresh-install bootstrap

**Kali:** run kali-rebuild; `scripts/07-configs.sh` installs these dotfiles.

```bash
git clone https://github.com/theo2612/kali-rebuild.git ~/kali-rebuild
cd ~/kali-rebuild && sudo ./install.sh
```

**Any other machine** (e.g. Ubuntu), same steps by hand:

```bash
git clone --bare https://github.com/theo2612/dotfiles.git ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles config status.showUntrackedFiles no
dotfiles config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
dotfiles fetch origin
dotfiles branch --set-upstream-to=origin/main main
dotfiles checkout
```

If `checkout` refuses because files already exist (e.g. `~/.gitconfig`),
move the listed files into `~/.pre-dotfiles-backup/` and run it again.
After adding an SSH key to GitHub, switch to SSH so you can push:
`dotfiles remote set-url origin git@github.com:theo2612/dotfiles.git`

## Notes

- `status.showUntrackedFiles=no` is set on the bare repo so `dotfiles status`
  only lists modified tracked files instead of every untracked file in `$HOME`.
- New files only enter the repo when added explicitly with `dotfiles add`.
- `source ~/.ip` in `.zshrc` is guarded with `[ -f ~/.ip ] &&` so missing
  per-target state never breaks shell startup.
