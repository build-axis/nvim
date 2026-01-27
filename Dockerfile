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
    npm

RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

RUN nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+TSUpdateSync" +qa

WORKDIR /src

ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8
ENV LAZY_CHECK_FOR_UPDATES=false

ENTRYPOINT ["nvim"]
