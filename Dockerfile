FROM php:8.4.1-cli-alpine AS php_source

FROM alpine:latest

LABEL org.opencontainers.image.source=https://github.com/build-axis/nvim

RUN apk add --no-cache \
    neovim git curl ripgrep fzf bash unzip nodejs npm \
    tree-sitter-cli gcompat build-base lua-language-server \
    lua5.1-dev wget ca-certificates libxml2 libzip oniguruma \
    icu-libs libstdc++ libgcc shadow su-exec

COPY --from=php_source /usr/local/bin/php /usr/local/bin/php
COPY --from=php_source /usr/local/lib/php /usr/local/lib/php
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN npm install -g pyright typescript-language-server

RUN git clone https://github.com/LazyVim/starter /opt/nvim-config && \
    rm -rf /opt/nvim-config/.git

RUN echo 'vim.opt.clipboard = "unnamedplus"' >> /opt/nvim-config/lua/config/options.lua && \
    echo 'vim.g.clipboard = { name = "osc52", copy = { ["+"] = function(l) vim.fn.chansend(vim.v.stderr, "\27]52;c;" .. vim.base64.encode(table.concat(l, "\n")) .. "\7") end }, paste = { ["+"] = function() return {vim.fn.getreg("+"), vim.fn.getregtype("+")} end } }' >> /opt/nvim-config/lua/config/options.lua

RUN mkdir -p /opt/nvim-config/lua/plugins && \
    echo 'return { \
      { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "php", "bash", "lua", "markdown" } } }, \
      { "williamboman/mason.nvim", opts = { ensure_installed = { "phpactor" } } }, \
      { "folke/lazy.nvim", opts = { checker = { enabled = false } } } \
    }' > /opt/nvim-config/lua/plugins/auto_install.lua

RUN XDG_CONFIG_HOME=/opt nvim --headless "+Lazy! sync" +qa && \
    XDG_CONFIG_HOME=/opt nvim --headless -c "Lazy load nvim-treesitter" -c "TSInstall! php bash lua markdown" -c "sleep 10" -c "qa" && \
    XDG_CONFIG_HOME=/opt nvim --headless -c "Lazy load mason.nvim" -c "MasonInstall phpactor" -c "sleep 10" -c "qa"

RUN printf '#!/bin/bash\n\
USER_ID=${LOCAL_UID:-1000}\n\
GROUP_ID=${LOCAL_GID:-1000}\n\
if ! getent group editor >/dev/null; then groupadd -g "$GROUP_ID" editor; fi\n\
if ! getent passwd editor >/dev/null; then useradd -u "$USER_ID" -g "$GROUP_ID" -m -s /bin/bash editor; fi\n\
export HOME=/home/editor\n\
mkdir -p "$HOME/.config" "$HOME/.local/share" "$HOME/.cache"\n\
if [ ! -d "$HOME/.config/nvim" ]; then cp -r /opt/nvim-config "$HOME/.config/nvim"; fi\n\
if [ ! -d "$HOME/.local/share/nvim" ] && [ -d "/opt/nvim/share" ]; then cp -r /opt/nvim/share "$HOME/.local/share/nvim"; fi\n\
chown -R editor:editor "$HOME"\n\
exec su-exec editor nvim "$@"' > /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /src
ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
