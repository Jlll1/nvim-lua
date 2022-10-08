FROM alpine:latest

ENV XDG_DATA_HOME /root/.config/nvim

RUN apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community --update \
  neovim \
  neovim-doc

# d: nvim-fzf {
RUN apk add \
  bat \
  fd \
  fzf \
  ripgrep
# }

# d: treesitter {
RUN apk add \
  git \
  clang \
  clang-static \
  clang-dev \
  build-base \
  llvm-static \
  llvm-dev
# }

WORKDIR /root/.config/nvim
COPY dot-nvim .

RUN nvim --headless +TSUpdate +qa!

VOLUME /ws
WORKDIR /ws

ENTRYPOINT ["nvim"]
