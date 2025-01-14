#!/bin/bash

set -e
set -u

# Debug mode
if [ $# == 1 ] && [ "$1" == "-d" ]; then
    DEBUG=1
    set -x
fi

OVPN_CONF=riseup-ovpn.conf

echo "[+] Please wait, riseup API is slow..."

# Download new VPN client certs (private and public keys)
curl ${DEBUG:+-v} -s --connect-timeout 5 --retry 5 https://api.black.riseup.net/3/cert -o riseup-vpn.pem
chmod 0600 riseup-vpn.pem

# Copy the sample openvpn conf
cp riseup-ovpn.sample.conf $OVPN_CONF
sed -i 's/^remote .*$//g' $OVPN_CONF

# Get the VPN IP list, and add them to openvpn conf
IP_LIST=$(curl ${DEBUG:+-v} -s --connect-timeout 5 --retry 5 https://api.black.riseup.net/3/config/eip-service.json | jq -r .gateways[].ip_address)
for ip in $IP_LIST; do
    sed -i "/^remote-random$/i remote $ip 1194" $OVPN_CONF
done

echo "[+] OpenVPN conf was created with success, you can now run :"
echo "sudo openvpn --config $OVPN_CONF"
