#!/bin/bash
# Generate certs (valid 365 days)
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/nginx-selfsigned.key \
  -out certs/nginx-selfsigned.crt \
  -subj "/C=GB/ST=Scotland/L=Dundee/O=Test/CN=captive.ediflyer.net"

