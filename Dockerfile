FROM alpine:latest

ENV XDG_DATA_HOME /root/.config/nvim

RUN apk add --update \
  neovim \
  neovim-doc \
# d: fzf-lua {
  git \
  fd \
  fzf \
  ripgrep
# }

WORKDIR /root/.config/nvim
COPY dot-nvim .

VOLUME /ws
WORKDIR /ws

ENTRYPOINT ["nvim"]
