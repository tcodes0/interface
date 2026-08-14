The goal is to determine whether we can build a minimal, private Tailscale-like setup using WireGuard for a contract-work environment where Tailscale itself appears to be unavailable or blocked on the client's network. The setup will ultimately consist of a Windows machine inside the client's network, a Linux machine that may move between networks, and a small VPS that acts as a coordination/configuration server. We do not need to reproduce Tailscale's full control plane or functionality. The VPS should eventually provide a simple rendezvous mechanism so the clients can exchange WireGuard public keys and current network endpoints; the actual application traffic should go directly over WireGuard whenever possible.
we'll be coding the test binary in go, to run on windows. vps has fixed ip and we can port fwd on it, linux.

The first phase is strictly connectivity testing, not implementation of the finished system. The Windows machine has administrator access but sits behind a router we do not control and is permanently connected via Ethernet, while the Linux machine may change networks and public IPs. We need to determine whether the client's network permits the basic connectivity required for the eventual tunnel. Run the following tests in increasing complexity:
(1) HTTPS from Windows to our VPS on TCP/443,
(2) TCP connectivity to a non-standard VPS port,
(3) basic outbound UDP connectivity to the VPS,
(4) an actual WireGuard handshake from Windows to the VPS,
(5) actual bidirectional traffic through the WireGuard tunnel, such as ping plus TCP traffic, and
(6) tunnel stability over time, including idle periods, `PersistentKeepalive`, and reconnecting the interface.

If tests 1–6 pass, we have established that a persistent WireGuard tunnel from the Windows machine through the client's router is viable. Direct Windows↔Linux connectivity is not required for the initial tests because the VPS will remain available for coordination, and Linux's changing network is a problem the eventual coordination layer will handle rather than something we need to test separately.

1 HTTPS → VPS
Windows connects to an HTTPS endpoint on your VPS.
Confirms outbound TCP/443.
Required for the eventual coordination server.
2 TCP → VPS on another port
Test an arbitrary TCP port.
Determines whether outbound TCP is restricted to standard ports.
3 UDP → VPS
Send UDP packets to a listener on the VPS.
Confirms whether outbound UDP is permitted at all.
4 WireGuard handshake: Windows → VPS
VPS runs WireGuard.
Windows initiates the tunnel.
Confirms that actual WireGuard traffic works through the client's router/NAT.
5 WireGuard traffic: Windows ↔ VPS
Give the peers VPN addresses.
Ping the VPS through the tunnel.
Then test actual TCP traffic.
Confirms the encrypted data path works, not just the handshake.
6 WireGuard stability
Keep the tunnel running for a while.
Test idle periods and PersistentKeepalive.
Restart the WireGuard interface and verify it reconnects.
This establishes whether the client's NAT behaves acceptably for a persistent tunnel.