FROM alpine:latest AS build-tree-sitter

# d: treesitter {
RUN apk add \
  build-base \
  tree-sitter-dev
# }

WORKDIR /root/.config/treesitter
COPY dot-treesitter .
RUN mkdir parser
RUN gcc -shared -o parser/c_sharp.so -fPIC tree-sitter-c-sharp/src/parser.c tree-sitter-c-sharp/src/scanner.c
RUN gcc -shared -o parser/c.so -fPIC tree-sitter-c/src/parser.c
RUN gcc -shared -o parser/lua.so -fPIC tree-sitter-lua/src/parser.c tree-sitter-lua/src/scanner.c

# =============================
FROM alpine:latest AS nvimd

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

WORKDIR /root/.config/nvim/parser
COPY --from=build-tree-sitter /root/.config/treesitter/parser/* ./
WORKDIR /root/.config/nvim
COPY plugins ./pack/common/start/
COPY dot-nvim ./

VOLUME /ws
WORKDIR /ws

ENTRYPOINT ["nvim"]
