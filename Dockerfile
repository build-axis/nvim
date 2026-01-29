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
    shadow \
    su-exec

RUN npm install -g pyright typescript-language-server

RUN mkdir -p /opt/nvim/config /opt/nvim/data /opt/nvim/state /opt/nvim/cache

RUN git clone https://github.com/LazyVim/starter /opt/nvim/config/nvim && \
    rm -rf /opt/nvim/config/nvim/.git

RUN echo 'vim.opt.clipboard = "unnamedplus"' >> /opt/nvim/config/nvim/lua/config/options.lua && \
    echo 'vim.g.clipboard = { name = "osc52", copy = { ["+"] = function(l) vim.fn.chansend(vim.v.stderr, "\27]52;c;" .. vim.base64.encode(table.concat(l, "\n")) .. "\7") end }, paste = { ["+"] = function() return {vim.fn.getreg("+"), vim.fn.getregtype("+")} end } }' >> /opt/nvim/config/nvim/lua/config/options.lua

ENV XDG_CONFIG_HOME=/opt/nvim/config
ENV XDG_DATA_HOME=/opt/nvim/data
ENV XDG_STATE_HOME=/opt/nvim/state
ENV XDG_CACHE_HOME=/opt/nvim/cache

RUN nvim --headless "+Lazy! sync" +qa || true
RUN nvim --headless -c "lua require('lazy').load({plugins = {'mason.nvim'}})" -c "MasonUpdate" -c "sleep 20" -c "qa"
RUN nvim --headless -c "lua require('lazy').sync({wait = true})" -c "TSUpdateSync" -c "sleep 20" -c "qa"

RUN printf '#!/bin/bash\n\
USER_ID=${LOCAL_UID:-1000}\n\
GROUP_ID=${LOCAL_GID:-1000}\n\
if ! getent group editor >/dev/null; then groupadd -g "$GROUP_ID" editor; fi\n\
if ! getent passwd editor >/dev/null; then useradd -u "$USER_ID" -g "$GROUP_ID" -m -s /bin/bash editor; fi\n\
export HOME=/home/editor\n\
mkdir -p "$HOME/.config" "$HOME/.local/share" "$HOME/.local/state" "$HOME/.cache"\n\
if [ ! -d "$HOME/.config/nvim" ]; then cp -r /opt/nvim/config/nvim "$HOME/.config/nvim"; fi\n\
if [ -z "$(ls -A $HOME/.local/share/nvim 2>/dev/null)" ]; then cp -r /opt/nvim/data/nvim "$HOME/.local/share/" 2>/dev/null || true; fi\n\
chown -R editor:editor "$HOME"\n\
exec su-exec editor nvim "$@"' > /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /src

ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
