# Alpine Neovim (LazyVim Edition)

GitHub Repository: [https://github.com/build-axis/nvim](https://github.com/build-axis/nvim)

A professional, lightweight **LazyVim** environment packed into a Docker container. This image allows you to use a fully-featured IDE-like Neovim setup on any machine without installing local dependencies.

## Features
* **Alpine Linux**: Minimal footprint and high performance.
* **LazyVim Starter**: Pre-installed and ready to use.
* **Build Tools**: Includes `build-base`, `gcc`, and `lua` for compiling plugins.
* **Search Tools**: `ripgrep` and `fzf` integrated for ultra-fast navigation.
* **Utilities**: `git`, `curl`, and `unzip` for plugin management.

---

## Quick Start

### Basic Usage
To run the container and edit the current directory (ephemeral mode):

```bash
docker run -it --rm --name dvm -v $(pwd):/src serh/nvim .
```

### Persistence Setup
To keep your plugins and configuration changes persistent on your host machine, follow these steps:

1. **Extract the internal configuration:**
```bash
# Create a temporary container to copy files
docker run -d --name dnv serh/nvim
docker cp dnv:/root ~/.local/nvim-docker
docker rm -f dnv
```

2. **Terminal Alias:**
Add this alias to your `~/.bashrc` or `~/.zshrc`:
```bash
alias dnv='docker run -it --rm \
  -v $(pwd):/src \
  -v ~/.local/nvim-docker:/root \
  serh/nvim'
```

3. **Usage:**
Now you can start Neovim in any directory with:
```bash
dnv .
```

---

## Technical Details
* **Container Workdir**: `/src` (automatically mounted via alias)
* **Environment**: `TERM=xterm-256color`, `LANG=en_US.UTF-8`
* **Clipboard**: OSC52 support enabled. This allows seamless copy-paste from Neovim to your system clipboard even when running inside Docker or over SSH.

To verify your environment inside Neovim, you can run:
@@@vim
:checkhealth
@@@
