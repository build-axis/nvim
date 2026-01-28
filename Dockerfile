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

# Устанавливаем переменные окружения сразу, чтобы nvim всегда видел одни и те же пути
ENV XDG_CONFIG_HOME=/root/.config
ENV XDG_DATA_HOME=/root/.local/share
ENV XDG_STATE_HOME=/root/.local/state

RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

RUN echo 'vim.opt.clipboard = "unnamedplus"' >> /root/.config/nvim/lua/config/options.lua && \
    echo 'vim.g.clipboard = { name = "osc52", copy = { ["+"] = function(l) vim.fn.chansend(vim.v.stderr, "\27]52;c;" .. vim.base64.encode(table.concat(l, "\n")) .. "\7") end }, paste = { ["+"] = function() return {vim.fn.getreg("+"), vim.fn.getregtype("+")} end } }' >> /root/.config/nvim/lua/config/options.lua

# Настройка Treesitter: отключаем автоустановку и фиксируем список
RUN mkdir -p /root/.config/nvim/lua/plugins && \
    echo 'return { { "nvim-treesitter/nvim-treesitter", opts = { auto_install = false, ensure_installed = { "luadoc", "luap", "printf", "json", "toml", "query", "vimdoc", "diff", "regex", "jsdoc", "lua", "html", "bash", "c", "vim", "javascript", "python", "dtd", "tsx", "typescript", "xml", "markdown_inline", "markdown", "yaml" }, sync_install = true } } }' > /root/.config/nvim/lua/plugins/treesitter.lua

# Принудительная установка плагинов, компиляция Treesitter и подготовка blink.cmp
# Используем один запуск для минимизации слоев и корректного завершения всех процессов
RUN nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+TSUpdateSync" +qa && \
    nvim --headless "+lua if require('lazy.core.config').plugins['blink.cmp'] then require('blink.cmp.installer').install() end" +qa

WORKDIR /src

ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8

ENTRYPOINT ["nvim"]
