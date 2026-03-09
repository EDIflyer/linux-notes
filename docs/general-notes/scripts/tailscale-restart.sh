#!/bin/bash

LOGFILE="/root/tailscale-restart.log"
echo "$(date): Tailscale restart script started" >> "$LOGFILE"

# Wait for tailscaled socket
while [ ! -S /run/tailscale/tailscaled.sock ]; do
  sleep 1
done
echo "$(date): tailscaled socket ready" >> "$LOGFILE"

# Run tailscale down with logging
tailscale down 2>&1 | tee -a "$LOGFILE"

# Run tailscale up with logging
tailscale up --ssh --accept-routes=true --advertise-routes=192.168.1.0/24 --accept-dns=false 2>&1 | tee -a "$LOGFILE"
RET=$?

if [ $RET -eq 0 ]; then
  echo "$(date): tailscale up succeeded" >> "$LOGFILE"
else
  echo "$(date): tailscale up failed (code $RET)" >> "$LOGFILE"
fi

echo "$(date): Tailscale restart script completed" >> "$LOGFILE"
exit $RET