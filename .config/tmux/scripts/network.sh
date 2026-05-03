#!/usr/bin/env bash

# Colors for tmux
G="#[fg=green,bold]"
R="#[fg=red,bold]"
NC="#[fg=default]"

# 1. DNS: Check if proxy is actually listening on port 53
if nc -z -u -w 1 127.0.0.1 53 2>/dev/null; then
	DNS_OUT="${G}DNSCRYPT${NC}"
else
	DNS_OUT="${R}DNS-DOWN${NC}"
fi

# 2. VPN: Check for tunnel interface and ping Mullvad internal gateway
if ifconfig | grep -q "utun" && ping -c 1 -t 1 10.64.0.1 >/dev/null 2>&1; then
	VPN_OUT="${G}VPN${NC}"
else
	VPN_OUT="${R}NO-VPN${NC}"
fi

# 3. LEAKS: Monitor TCP established connections via local physical IP
LOCAL_IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)
if [ -n "$LOCAL_IP" ]; then
	LEAKS_COUNT=$(sudo lsof -i -nP -itcp | grep "$LOCAL_IP" | grep "ESTABLISHED" | grep -v "127.0.0.1" | wc -l | xargs)
	if [ "$LEAKS_COUNT" -eq 0 ]; then
		LEAK_OUT="${G}SAFE${NC}"
	else
		LEAK_OUT="${R}LEAK:$LEAKS_COUNT${NC}"
	fi
else
	LEAK_OUT="${R}OFFLINE${NC}"
fi

# 4. TOR: Check SOCKS connectivity on port 9050
if nc -z -w 1 127.0.0.1 9050 2>/dev/null; then
	TOR_OUT="${G}TOR${NC}"
else
	TOR_OUT="${R}NO-TOR${NC}"
fi

echo "$TOR_OUT $VPN_OUT $DNS_OUT $LEAK_OUT"
