FROM alpine:latest

RUN apk add --no-cache \
    neovim \
    git \
    curl \
    build-base \
    ripgrep \
    fzf \
    bash

WORKDIR /src

ENTRYPOINT ["nvim"]
