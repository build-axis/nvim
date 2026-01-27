FROM alpine:latest
LABEL org.opencontainers.image.source=https://github.com/build-axis/nvim
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
RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git
RUN nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+TSUpdateSync" +qa
WORKDIR /src
ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LAZY_CHECK_FOR_UPDATES=false
ENTRYPOINT ["nvim"]
