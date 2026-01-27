FROM alpine:latest

RUN apk add --no-cache \
    neovim \
    git \
    curl \
    build-base \
    ripgrep \
    fzf \
    bash \
    lua5.1-dev \
    unzip \
    ca-certificates

# Clone the LazyVim starter template
RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

# Install plugins and wait for Treesitter/Mason to finish
# We use a trick: run sync, then run a command that triggers 
# all essential installs in headless mode.
RUN nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+TSUpdateSync" +qa

WORKDIR /src

ENV TERM=xterm-256color

# This environment variable tells LazyVim not to check for updates on startup
ENV LAZY_CHECK_FOR_UPDATES=false

ENTRYPOINT ["nvim"]
