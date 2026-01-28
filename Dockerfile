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

RUN mkdir -p /root/.config/nvim/lua/plugins && \
    echo 'return { { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "luadoc", "luap", "printf", "json", "toml", "query", "vimdoc", "diff", "regex", "jsdoc", "lua", "html", "bash", "c", "vim", "javascript", "python", "dtd", "tsx", "typescript", "xml", "markdown_inline", "markdown", "yaml" }, sync_install = true } } }' > /root/.config/nvim/lua/plugins/treesitter_setup.lua

RUN nvim --headless "+Lazy! sync" +qa || true
RUN nvim --headless "+TSUpdateSync" +qa || true

RUN rm /root/.config/nvim/lua/plugins/treesitter_setup.lua

WORKDIR /src

ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8

ENTRYPOINT ["nvim"]
