FROM debian:stable-slim
LABEL MAINTAINER="Brian Hartford bhartford419@gmail.com"
RUN apt-get update && \
    apt-get install -y wireguard \
    sudo \
    ufw \
    systemctl \
    iptables 

ARG UID=1000
ARG GID=1000
ARG USERNAME=wireguard
ARG GROUPNAME=wireguard
RUN groupadd -g $GID -o $USERNAME && \
  useradd -m -u $UID -g $GID -o -d /home/$USERNAME -s /bin/bash $USERNAME && \
  passwd -d $USERNAME && \
  usermod -aG sudo $USERNAME

COPY ./entrypoint.sh /usr/local/entrypoint.sh
RUN chmod a+rx /usr/local/entrypoint.sh \
    && sudo chown $USERNAME:$GROUPNAME /etc/wireguard

USER root
EXPOSE 51820/udp \
    22/tcp
ENTRYPOINT ["/usr/local/entrypoint.sh"]