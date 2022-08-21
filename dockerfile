FROM debian:stable-slim
LABEL MAINTAINER="Brian Hartford bhartford419@gmail.com"
RUN apt-get update && \
    apt-get install -y wireguard \
    sudo \
    ufw \
    systemctl \
    iptables  \
    curl  \
    net-tools 


#ARG UID=1000
#ARG GID=1000
#ARG USERNAME=wireguard
#ARG GROUPNAME=wireguard
=======
ARG UID=1001
ARG GID=1001
ARG USERNAME=wireguard
ARG GROUPNAME=wireguard

RUN groupadd -g $GID  $USERNAME && \
  useradd -m -u $UID -g $GID -d /home/$USERNAME -s /bin/bash $USERNAME && \
  passwd -d $USERNAME && \
  echo "$USERNAME    ALL=(ALL:ALL) NOPASSWD: /usr/bin/" | tee -a /etc/sudoers && \
  usermod -aG sudo $USERNAME
COPY ./wg_config.sh /usr/local/wg_config.sh
RUN chmod 777 /usr/local/wg_config.sh
CMD ["bash", "/usr/local/wg_config.sh"]


COPY ./entrypoint.sh /usr/local/entrypoint.sh
RUN chmod 777 /usr/local/entrypoint.sh \
    && sudo chown $USERNAME:$GROUPNAME /etc/wireguard  && \
    touch /etc/wireguard/wg0.conf && \
    chown $USERNAME:$GROUPNAME /etc/wireguard/wg0.conf


#RUN bash /usr/local/entrypoint.sh

EXPOSE 51820/udp \
    22/tcp


ENTRYPOINT ["/usr/local/entrypoint.sh"]
