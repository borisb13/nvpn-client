FROM alpine:latest

RUN apk --no-cache --no-progress add \
  openvpn tini bash jq curl

COPY openvpn.sh /usr/bin/

VOLUME /config

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/openvpn.sh"]
