FROM alpine:latest

LABEL org.opencontainers.image.source=https://github.com/build-axis/nvim

RUN apk add --no-cache \
    neovim \
    git \
    curl \
    ripgrep \
    fzf \
    bash \
    unzip \
    nodejs \
    npm \
    tree-sitter-cli \
    gcompat \
    build-base

RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

RUN echo 'vim.opt.clipboard = "unnamedplus"' >> /root/.config/nvim/lua/config/options.lua && \
    echo 'vim.g.clipboard = { name = "osc52", copy = { ["+"] = function(l) vim.fn.chansend(vim.v.stderr, "\27]52;c;" .. vim.base64.encode(table.concat(l, "\n")) .. "\7") end }, paste = { ["+"] = function() return {vim.fn.getreg("+"), vim.fn.getregtype("+")} end } }' >> /root/.config/nvim/lua/config/options.lua

# Fix for nvim-treesitter to use system tree-sitter-cli during build
RUN mkdir -p /root/.config/nvim/queries && \
    echo 'require("nvim-treesitter.configs").setup({ ensure_installed = { "lua", "vim", "vimdoc", "bash", "json", "html" }, sync_install = true })' > /root/.config/nvim/init.lua

# Install plugins and then install/compile treesitter parsers
RUN nvim --headless "+Lazy! sync" +qa || true
RUN nvim --headless "+TSUpdateSync" +qa || true

# Restore original init.lua from LazyVim starter
RUN git checkout /root/.config/nvim/init.lua

WORKDIR /src

ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8

ENTRYPOINT ["nvim"]
