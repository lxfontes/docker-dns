FROM ubuntu

RUN     apt-get update && apt-get -y install dnsmasq docker.io vim
COPY    dnsmasq.conf /etc/dnsmasq.conf
COPY    dnslol /dnslol
COPY   init /init

EXPOSE 53/udp

VOLUME ["/var/run/docker.sock"]
CMD    ["/init"]
