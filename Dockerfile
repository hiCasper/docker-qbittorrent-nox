FROM alpine:latest

ARG QBT_VERSION
ENV QBT_WEBUI_PORT=8080
ENV QBT_CONFIG_PATH="/config"
ENV QBT_DOWNLOADS_PATH="/qBittorrent/downloads"

RUN \
  apk --no-cache add bash curl doas tini tzdata jq && \
  QBT_URL=$(curl -fsSL https://api.github.com/repos/userdocs/qbittorrent-nox-static/releases?per_page=100 | \
    jq --arg QBTVER $QBT_VERSION '.[] | select(.prerelease == false and (.tag_name | contains($QBTVER)))' | \
    jq --arg ARCH "$(arch)-qbittorrent-nox" '.assets[] | select (.name == $ARCH)' | \
    jq -r '.browser_download_url' | head -1) && \
  curl -sSL -o /usr/bin/qbittorrent-nox $QBT_URL && \
  chmod +x /usr/bin/qbittorrent-nox && \
  apk del jq && \
  adduser -D -H -s /sbin/nologin -u 1000 qbtUser && \
  echo "permit nopass :root" >> "/etc/doas.d/doas.conf"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/sbin/tini", "-g", "--", "/entrypoint.sh"]
