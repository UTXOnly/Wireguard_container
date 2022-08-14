FROM debian:stable-slim
RUN apt-get update && \
    apt-get install -y wireguard && \
    sudo \
    ufw \
    systemctl
COPY ./entrypoint.sh /usr/local/entrypoint.sh
RUN chmod a+rx /usr/local/entrypoint.sh
EXPOSE 51820/udp \
    22/tcp
ENTRYPOINT ["/usr/local/entrypoint.sh"]