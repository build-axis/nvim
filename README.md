GitHub Repository: [https://github.com/build-axis/nvim](https://github.com/build-axis/nvim)

# Alpine Neovim (LazyVim Edition)

A professional, lightweight **LazyVim** environment packed into a Docker container. This image allows you to use a fully-featured IDE-like Neovim setup on any machine without installing local dependencies.

## Features
* **Alpine Linux**: Minimal footprint and high performance.
* **LazyVim Starter**: Pre-installed and ready to use.
* **Build Tools**: Includes `build-base`, `gcc`, and `lua` for compiling plugins.
* **Search Tools**: `ripgrep` and `fzf` integrated for ultra-fast navigation.
* **Utilities**: `git`, `curl`, and `unzip` for plugin management.

---

## Quick Start

### Edit Current Directory
The most common way to use this image is to mount your current folder into the container's `/src` directory:

```bash
docker run -it --rm -v $(pwd):/src serh/nvim .
```


### Terminal Alias
To use this container like a native application, add this alias to your ~/.bashrc or ~/.zshrc:

```bash
alias dnv='docker run -it --rm \
  -v $(pwd):/src \
  -v ~/.local/share/nvim-docker:/root/.local/share/nvim \
  -v ~/.local/state/nvim-docker:/root/.local/state/nvim \
  -v ~/.cache/nvim-docker:/root/.cache/nvim \
  serh/nvim'
```
