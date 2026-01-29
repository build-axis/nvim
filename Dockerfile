FROM php:8.4.8-cli-alpine AS php_source

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
    build-base \
    lua-language-server \
    lua5.1-dev \
    wget \
    ca-certificates \
    libxml2 \
    libzip \
    oniguruma \
    icu-libs

COPY --from=php_source /usr/local/bin/php /usr/local/bin/php
COPY --from=php_source /usr/local/lib/php /usr/local/lib/php
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN npm install -g pyright typescript-language-server

RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

RUN echo 'vim.opt.clipboard = "unnamedplus"' >> /root/.config/nvim/lua/config/options.lua && \
    echo 'vim.g.clipboard = { name = "osc52", copy = { ["+"] = function(l) vim.fn.chansend(vim.v.stderr, "\27]52;c;" .. vim.base64.encode(table.concat(l, "\n")) .. "\7") end }, paste = { ["+"] = function() return {vim.fn.getreg("+"), vim.fn.getregtype("+")} end } }' >> /root/.config/nvim/lua/config/options.lua

RUN mkdir -p /root/.config/nvim/lua/plugins && \
    echo 'return { \
      { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "php", "bash", "lua", "markdown" } } }, \
      { "williamboman/mason.nvim", opts = { ensure_installed = { "phpactor" } } } \
    }' > /root/.config/nvim/lua/plugins/auto_install.lua

RUN nvim --headless "+Lazy! sync" +qa || true

RUN nvim --headless -c "Lazy load nvim-treesitter" -c "TSInstall! php" -c "qa" || true
RUN nvim --headless -c "Lazy load mason.nvim" -c "MasonInstall phpactor" -c "qa" || true

WORKDIR /src

ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8

ENTRYPOINT ["nvim"]
