# Alpine Neovim (LazyVim Edition)

GitHub Repository: [https://github.com/build-axis/nvim](https://github.com/build-axis/nvim)

Professional, lightweight **LazyVim** environment in a Docker container. Work with a full IDE setup on any machine while maintaining host file permissions.

## Features
* **Alpine Linux**: Minimal footprint and high performance.
* **LazyVim Starter**: Pre-configured and ready to use.
* **UID/GID Sync**: Automatically matches your host user ID to prevent permission issues with edited files.
* **Built-in Tools**: `ripgrep`, `fzf`, `gcc`, `gcompat`, and `nodejs` for LSP and Tree-sitter.
* **OSC52 Clipboard**: Seamless copy-paste support, even over SSH.

---

## Quick Start

### Basic Usage
Run the container to edit the current directory (files created will be owned by your current user):

```bash
docker run -it --rm \
  -e LOCAL_UID=$(id -u) \
  -e LOCAL_GID=$(id -g) \
  -v $(pwd):/src \
  serh/nvim .
```

### Persistence Setup (Recommended)
To persist your Neovim configuration, plugins, and cache on your host machine:

1. **Create an alias** in your `~/.bashrc` or `~/.zshrc`:

```bash
alias dnv='docker run -it --rm \
  -e LOCAL_UID=$(id -u) \
  -e LOCAL_GID=$(id -g) \
  -v $(pwd):/src \
  -v ~/.local/share/nvim-docker:/home/editor \
  serh/nvim'
```

2. **Usage**:
Simply type `dnv` in any project folder:
```bash
dnv .
```
*Note: On the first run with a new volume, the container will automatically initialize LazyVim config in your host folder.*

---

## Technical Details
* **User Management**: The container uses `su-exec` to switch from `root` to a user named `editor` with your specific `UID/GID` at runtime.
* **Workdir**: `/src` (mapped to your project).
* **Home Directory**: `/home/editor` (where config and plugins reside).
* **Clipboard**: OSC52 enabled by default. Works out of the box with modern terminals (Alacritty, Kitty, iTerm2).

To verify the setup inside Neovim:
```vim
:checkhealth
```
