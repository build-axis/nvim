FROM alpine:3.21

LABEL org.opencontainers.image.source=https://github.com/build-axis/nvim

ENV XDG_DATA_HOME=/root/.local/share \
    XDG_CONFIG_HOME=/root/.config \
    TERM=xterm-256color

RUN apk add --no-cache \
    neovim git curl ripgrep fzf bash unzip gcompat build-base

RUN git clone --depth 1 https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

RUN echo 'vim.opt.clipboard = "unnamedplus"' >> /root/.config/nvim/lua/config/options.lua && \
    echo 'vim.g.clipboard = { name = "osc52", copy = { ["+"] = function(l) vim.fn.chansend(vim.v.stderr, "\27]52;c;" .. vim.base64.encode(table.concat(l, "\n")) .. "\7") end }, paste = { ["+"] = function() return {vim.fn.getreg("+"), vim.fn.getregtype("+")} end } }' >> /root/.config/nvim/lua/config/options.lua

RUN nvim --headless "+Lazy! sync" +qa

WORKDIR /src
ENTRYPOINT ["nvim"]
