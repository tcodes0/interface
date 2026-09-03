# netdiag — client network connectivity diagnostic harness

Go client/server pair that characterizes what the client's network permits, before building the
own WireGuard VPN ([29]). Tailscale is unavailable/blocked on the client network, so we're
evaluating our own WireGuard infrastructure. The harness only _characterizes_ the network —
no VPN logic, no traffic relay, no bypassing anything without authorization.

## Topology

| Node                                                 | Role                                                                                                                 |
| ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Windows PC (permanently in client network, Ethernet) | future exit node; runs test **client**                                                                               |
| Linux PC (travels between networks)                  | future exit-node consumer; will also run client                                                                      |
| Hetzner VPS (fixed public IP)                        | runs test **server**; later, coordination server. Coordinates only — no app traffic unless a relay becomes necessary |

## The harness

Lives at `src/netdiag/`. Two binaries: `server` (linux/amd64, on the VPS) and `client`
(windows/amd64, in the client network). One shared package for the protocol.
Stdlib + WireGuard userspace (wireguard-go/tun/wintun) only — no gRPC, no protobuf, no framework.

**Control plane:** plain HTTP + small JSON, in-memory results map. The server is the oracle —
it sees the public address the client arrives from, records **source IP:port per test**, and
hands it back so the CLI can print it. Each test prints its own line as it completes; only the
Conclusion prints at the end.

### The 7 tests, in order

1. **HTTPS/TCP 443** — baseline: normal outbound works
2. **TCP arbitrary port** (8443) — is TCP restricted to standard ports?
3. **UDP arbitrary port** — application-level ACK from server (small binary round-trip with
   checksum, not send-and-hope); distinguishes real bidirectional UDP from one-way drop
4. **WireGuard handshake** on UDP/51820 — the protocol-specific question
5. **WireGuard handshake** on UDP/443 — separates port filtering from WireGuard fingerprinting
6. **Persistent UDP** — hold tunnel, let it idle, resend; with PersistentKeepalive —
   measures how the client's NAT ages UDP mappings
7. **Bidirectional traffic** — data both directions through the tunnel, proves more than a handshake

Failure at each step is diagnostic: e.g. #3 passes but #4 fails means fingerprinting
WireGuard packets. #4 passes but #5 fails means port-filtering, not protocol-filtering.

### Example report

```text
Client Network Connectivity Test
[PASS] HTTPS TCP/443             src=1.2.3.4:12345  42ms
[PASS] TCP/8443                  src=1.2.3.4:12346  38ms
[PASS] UDP/51820                 src=1.2.3.4:54321  51ms
[PASS] WireGuard UDP/51820       src=1.2.3.4:51234  120ms
[PASS] WireGuard UDP/443         src=1.2.3.4:55678  98ms
[PASS] Persistent UDP (60s)      src=1.2.3.4:51234  keepalive=OK
[PASS] Bidirectional WG traffic  latency=102ms  500B each direction

Conclusion: Direct WireGuard connectivity appears viable.
```

## Milestones

1. **Build + first run from Thom's own network** (Windows) — smoke test. On a normal network
   everything should be green; validates the harness itself and gives a baseline to diff against.
2. **Run from the client network** — the actual diagnosis.
3. Then (follow-up in [29]) strip the test logic, keep the VPS/client control channel, and build
   the minimal coordination server: peers exchange WG public keys + endpoints, VPS relays only
   that metadata.

## Out of scope

No Tailscale feature parity, no kernel modules, no exit-node/routing logic in the harness,
no traffic relay on the VPS.
