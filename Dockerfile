# Stage 1: Get PHP 8.4.8 binaries from the official image
FROM php:8.4.8-cli-alpine AS php_source

# Stage 2: Main image assembly
FROM alpine:latest

LABEL org.opencontainers.image.source=https://github.com/build-axis/nvim

# Install core dependencies
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
    build-base \
    lua-language-server \
    lua5.1-dev \
    wget \
    ca-certificates \
    # Standard libraries for PHP runtime
    libxml2 \
    libzip \
    oniguruma \
    icu-libs

# Copy PHP binaries and configuration from Stage 1
COPY --from=php_source /usr/local/bin/php /usr/local/bin/php
COPY --from=php_source /usr/local/lib/php /usr/local/lib/php

# Copy Composer from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install LSPs
RUN npm install -g pyright typescript-language-server

# Setup LazyVim
RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

# Clipboard configuration (OSC52)
RUN echo 'vim.opt.clipboard = "unnamedplus"' >> /root/.config/nvim/lua/config/options.lua && \
    echo 'vim.g.clipboard = { name = "osc52", copy = { ["+"] = function(l) vim.fn.chansend(vim.v.stderr, "\27]52;c;" .. vim.base64.encode(table.concat(l, "\n")) .. "\7") end }, paste = { ["+"] = function() return {vim.fn.getreg("+"), vim.fn.getregtype("+")} end } }' >> /root/.config/nvim/lua/config/options.lua

# Headless setup for plugins, PHP LSP (phpactor), and Treesitter
RUN nvim --headless "+Lazy! sync" +qa || true
RUN nvim --headless -c "MasonInstall phpactor" -c "qa" || true
RUN nvim --headless -c "TSUpdateSync php" -c "qa" || true

WORKDIR /src

ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8

ENTRYPOINT ["nvim"]
