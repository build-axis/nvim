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
    unzip

# Clone the LazyVim starter template
RUN git clone https://github.com/LazyVim/starter /root/.config/nvim

# Remove .git and pre-install plugins
# We add "sleep 2" to ensure everything finishes correctly in some environments
RUN rm -rf /root/.config/nvim/.git && \
    nvim --headless "+Lazy! sync" +qa

WORKDIR /src

# Set default environment to avoid some Neovim warnings
ENV TERM=xterm-256color

ENTRYPOINT ["nvim"]
