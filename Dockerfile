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
    python3 \
    py3-pip \
    tree-sitter-cli \
    gcompat \
    build-base \
    lua-language-server \
    lua5.1-dev \
    wget \
    ca-certificates
    

RUN npm install -g pyright typescript-language-server

RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

RUN echo 'vim.opt.clipboard = "unnamedplus"' >> /root/.config/nvim/lua/config/options.lua && \
    echo 'vim.g.clipboard = { name = "osc52", copy = { ["+"] = function(l) vim.fn.chansend(vim.v.stderr, "\27]52;c;" .. vim.base64.encode(table.concat(l, "\n")) .. "\7") end }, paste = { ["+"] = function() return {vim.fn.getreg("+"), vim.fn.getregtype("+")} end } }' >> /root/.config/nvim/lua/config/options.lua


RUN nvim --headless "+Lazy! sync" +qa || true
RUN nvim --headless -c "MasonUpdate" -c "quitall" || true
RUN nvim --headless -c "TSUpdateSync" -c "qa" || true


WORKDIR /src

ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8

ENTRYPOINT ["nvim"]
