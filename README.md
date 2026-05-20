# dotfiles

Personal Kali dotfiles, managed as a bare git repository so the files in
`$HOME` are the source of truth (no copy-back-to-repo step).

- **Bare repo:**     `~/.dotfiles`
- **Work tree:**     `$HOME`
- **Remote:**        `git@github.com:theo2612/dotfiles.git` (private, SSH)
- **Bootstrap:**     [`theo2612/kali-rebuild-personal`](https://github.com/theo2612/kali-rebuild-personal) (`scripts/07-configs.sh`)

## Currently tracked

| File           | Purpose                                                    |
| -------------- | ---------------------------------------------------------- |
| `.zshrc`       | Shell config, HTB command-logging hook, aliases, functions |
| `.tmux.conf`   | tmux config: ctrl-a prefix, pane splits, pipe-pane logging |
| `.p10k.zsh`    | powerlevel10k prompt config                                |
| `.gitconfig`   | git identity                                               |
| `.zprofile`    | zsh login-shell init                                       |
| `README.md`    | this file                                                  |

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

On a fresh Kali box, after adding an SSH key to GitHub:

```bash
git clone git@github.com:theo2612/kali-rebuild-personal.git ~/kali-rebuild-personal
cd ~/kali-rebuild-personal && sudo ./install.sh
```

`scripts/07-configs.sh` clones this repo to `~/.dotfiles`, sets
`status.showUntrackedFiles=no`, and checks files out into `$HOME`. Any
pre-existing conflicting files are moved to `~/.pre-dotfiles-backup/`.

## Notes

- `status.showUntrackedFiles=no` is set on the bare repo so `dotfiles status`
  only lists modified tracked files instead of every untracked file in `$HOME`.
- New files only enter the repo when added explicitly with `dotfiles add`.
- `source ~/.ip` in `.zshrc` is guarded with `[ -f ~/.ip ] &&` so missing
  per-target state never breaks shell startup.
