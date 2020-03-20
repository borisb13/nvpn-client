#!/usr/bin/env bash

echo "Creating tun device"
mkdir -p /dev/net
[[ -c /dev/net/tun ]] || mknod /dev/net/tun c 10 200

# Add Alpine scripts to configure resolve.conf
sed -i \
  -e "/auth-user-pass/a script-security 2" \
  -e "/auth-user-pass/a up /etc/openvpn/up.sh" \
  -e "/auth-user-pass/a down /etc/openvpn/down.sh" \
  /config/config.ovpn

if  [ -z ${OVPN_USERNAME} ] || [ -z ${OVPN_PASSWORD} ] ; then
    echo "OpenVPN credentials not set. Exiting"
    exit 1
else
    echo "Adding OpenVPN credentials from environment."
    echo "${OVPN_USERNAME}" > /etc/openvpn/creds.txt
    echo "${OVPN_PASSWORD}" >> /etc/openvpn/creds.txt
    chmod 600 /etc/openvpn/creds.txt

    sed -i "s:auth-user-pass:auth-user-pass /etc/openvpn/creds.txt:" /config/config.ovpn
fi

if [ -n ${LOCAL_NETWORKS} ] ; then
    gateway="$(ip route show 0.0.0.0/0 dev eth0 | cut -d ' ' -f 3)"
    for network in ${LOCAL_NETWORKS//;/ }; do
        echo "Adding route for ${network}"
        ip route add to ${network} via ${gateway} dev eth0
    done
fi

echo "Running OpenVPN"
exec openvpn /config/config.ovpn
