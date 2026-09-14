# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

`myconfig` is a personal dotfiles/bootstrap repo, not an application. It installs and links zsh (oh-my-zsh), vim (Vundle + amix/vimrc), and tmux configuration on a fresh **Linux** machine (Ubuntu/Debian via `apt-get` — macOS/`brew` support was removed). There is no build or lint tooling; correctness is checked by actually running `install.sh` (via `./test.sh`, see below) and confirming the resulting shell/vim/tmux behavior.

## Architecture

- **`install.sh`** — the single, self-contained bootstrap script for a fresh machine. It is fetched and run directly via `curl`/`wget` per the README. Flow:
  1. Prompts (via `prompt_toggle`) for five yes/no choices — `MYCONFIG_SUDOER`, `MYCONFIG_INSTALL_PACKAGES`, `MYCONFIG_INSTALL_ZSH`, `MYCONFIG_INSTALL_VIM`, `MYCONFIG_INSTALL_TMUX` — each skipped if the matching env var is already set. This is what makes the script both interactive-by-default and automatable (see Testing below): set the env vars up front and no prompts appear.
  2. If sudoer + packages requested, installs the base `apt-get` package list.
  3. Clones/updates this repo to `~/.myconfig` via `get_myconfig` (helper `git_get`: clones if missing, `git pull`s if present) — unless `MYCONFIG_SOURCE_PATH` is set, in which case it copies from that local path instead of pulling from GitHub. This is how `test.sh` validates uncommitted local changes rather than whatever is currently on `master`.
  4. If tmux requested: symlinks `tmux.conf` (or `tmux19.conf` for tmux < 2.0) to `~/.tmux.conf`, and installs TPM (`tmux-plugins/tpm`) for the modern-tmux path.
  5. If vim requested: clones `amix/vimrc` to `~/.vim_runtime`, symlinks `vim_runtimerc.vim` to `~/.vim_runtime/my_configs.vim`, clones `Vundle.vim`, symlinks `vundle.vim` to `~/.vundle.vim`, prepends `source ~/.vundle.vim` into `~/.vimrc`, then runs `vim +PluginInstall +qall`.
  6. If zsh requested: installs oh-my-zsh plus the `bullet-train` theme, `zsh-autosuggestions`, and `zsh-syntax-highlighting` plugins by patching the freshly-generated `~/.zshrc` with `sed`, appends `source $CLONE_PATH/zshrc` to it, then changes the login shell to zsh (`usermod` if sudoer, otherwise `chsh` after appending to `/etc/shells` via `sudo tee -a`), and finally `exec`s into `env zsh` — but only when attached to a terminal (`[ -t 1 ]`), so automated/non-interactive runs don't hang at the end.
  - The script is Linux-only now; there is no OS branching left.

### Config files and where they end up

| File in repo | Linked to | Purpose |
|---|---|---|
| `zshrc` | sourced from `~/.zshrc` (appended, not symlinked) | Aliases (common typo aliases like `clera`→`clear`), `PATH`, `TERM`/locale env vars |
| `vundle.vim` | `~/.vundle.vim`, sourced from the top of `~/.vimrc` | Vundle plugin list (delimitMate, vim-gitgutter) |
| `vim_runtimerc.vim` | `~/.vim_runtime/my_configs.vim` | Overrides on top of amix/vimrc, e.g. un-mapping snippet placeholder keys (`$1`-`$4`, `$q`, `$e`, `$t`) |
| `tmux.conf` | `~/.tmux.conf` (tmux >= 2.0) | Mouse support, TPM plugin list (sensible, resurrect, yank, continuum) |
| `tmux19.conf` | `~/.tmux.conf` (tmux < 2.0) | Minimal mouse-support-only config for old tmux, no plugin manager |

## Testing

`Dockerfile` + `test.sh` run `install.sh` end-to-end in a disposable `ubuntu:24.04` container, as a non-root user with passwordless `sudo` (so the same permission path a real laptop install takes is exercised, including package installation and the `usermod` shell-change branch — the non-sudoer/`chsh`+`/etc/shells` branch is intentionally not covered by this harness, since `install.sh` only installs packages when `MYCONFIG_SUDOER=1`, so the two branches can't both be exercised in one run). The `Dockerfile` bakes in `MYCONFIG_SOURCE_PATH=/home/tester/myconfig-src` so the container tests the local working tree, not `master` on GitHub. Run it after any `install.sh` change:

```shell
./test.sh
```

It asserts: login shell is zsh, `~/.tmux.conf` is symlinked to this repo's `tmux.conf`, `~/.vimrc` sources `~/.vundle.vim`, the Vundle plugin directories (`Vundle.vim`, `delimitMate`, `vim-gitgutter`) exist, and oh-my-zsh is installed with `~/.zshrc` sourcing this repo's `zshrc`.

## Making changes

- There are no unit tests, only the Docker smoke test above — after editing `install.sh`, run `./test.sh` rather than reasoning about it in the abstract.
- `install.sh` uses `set -e`, so any added command that can legitimately fail (e.g. because a tool is already installed) should be guarded (see the existing `|| true` on the oh-my-zsh install step).
- Keep `zshrc`, `vundle.vim`, `tmux.conf`/`tmux19.conf` as plain config snippets that get sourced/symlinked — they are not templated, so any machine-specific values must not be hardcoded into them.
- When adding a new toggleable component, follow the existing `prompt_toggle VAR "question" default` pattern so it stays both interactively promptable and settable via env var for `test.sh`/CI.
