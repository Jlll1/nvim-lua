FROM alpine:latest AS build-tree-sitter

# d: treesitter {
RUN apk add \
  git \
  clang \
  clang-static \
  clang-dev \
  build-base \
  llvm-static \
  llvm-dev \
  tree-sitter-dev
# }

WORKDIR /root/.config/treesitter
COPY dot-treesitter .
RUN mkdir parser
RUN gcc -shared -o parser/c_sharp.so -fPIC tree-sitter-c-sharp/src/parser.c tree-sitter-c-sharp/src/scanner.c

# =============================
FROM alpine:latest AS nvimd

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

# d: copilot {
RUN apk add \
  nodejs
# }

WORKDIR /root/.config/nvim
COPY dot-nvim ./
WORKDIR /root/.config/nvim/nvim/site/parser
COPY --from=build-tree-sitter /root/.config/treesitter/parser/* .

VOLUME /ws
WORKDIR /ws

ENTRYPOINT ["nvim"]
