FROM alpine:latest

ENV XDG_DATA_HOME /root/.config/nvim
ENV TERM screen-256color

RUN apk add --update \
  neovim \
# d: fzf-lua {
  git \
  ripgrep \
  fd \
  fzf
# }

WORKDIR /root/.config/nvim
COPY dot-nvim .

VOLUME /ws
WORKDIR /ws

ENTRYPOINT ["nvim"]
