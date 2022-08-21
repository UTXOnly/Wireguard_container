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



COPY ./entrypoint.sh /usr/local/entrypoint.sh
RUN chmod 777 /usr/local/entrypoint.sh \
    && sudo chown $USERNAME:$GROUPNAME /etc/wireguard  && \
    touch /etc/wireguard/wg0.conf && \
    chown $USERNAME:$GROUPNAME /etc/wireguard/wg0.conf

RUN sed '/net.ipv4.ip_forward=1/s/^#//' -i /etc/sysctl.conf \
    sysctl -p
WORKDIR /etc/wireguard    
RUN umask 077; wg genkey | tee privatekey | wg pubkey > publickey \
    private_key=$(< privatekey)

RUN load_config=" \
[Interface] \
PrivateKey = a_private_key \
Address = 10.0.0.0/24 \
ListenPort = 51820 \
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE \
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE \
[Peer] \
AllowedIPS = 10.0.0.1/24 \
PersistentKeepalive = 25"

RUN echo "$load_config" | tee wg0.conf  \
    sed -i "s/a_private_key/$private_key/g" /etc/wireguard/wg0.conf

RUN ufw allow 22/tcp \
    ufw allow 51820/udp \
    ufw enable

EXPOSE 51820/udp \
    22/tcp


ENTRYPOINT ["/usr/local/entrypoint.sh"]
