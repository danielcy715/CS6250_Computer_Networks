* Brief history of the internet
Internet has its roots in the ARPANET

ARPANET (1966-1967): goal was to connect academic computers
  - UCLA, SRI, UCSB, Utah
  - NPLNet in UK around same time
  - 50 kbps
  - ~20 nodes

There were other networks besides ARPANET
  - Satellite, radio, ethernet LAN

TCP/IP
- 1973 Work began to replace the network control protocol with TCP/IP
- TCP/IP was standardized from 1978-1981
- Jan 1, 1983 (Flag day), internet adopted TCP/IP

Milestones:
- DNS (1982)
- TCP congestion control (1988)
- BGP (1989)

Lot of application-type milestones in the 90s
- Audio/video (1992)
- Web (1993)
- Search engine (AltaVista 1995)
- P2P file sharing (2000)
* Problems and Growing Pains
1. Running out of addresses (only 2^32 addresses, or ~ 4 billion, with IPv4)
   - Some addresses not allocated efficiently
2. Congestion control
   - insufficient dynamic range (don't work well over slow or flaky links or high speed intercontinental paths)
3. Routing (how nodes discover paths to take to reach a dest)
   - BGP: lack of security, easily misconfigured, poor convergence, non-determinism
4. Security: bad at key management, deploying secure software and deployment
5. DOS: easy for attacker to overload servers or links

All these require changes to the basic infrastructure, which is difficult
* Architectural Design Principles
Discussed in 'Design Philosophy of the DARPA Internet Protocols'

Principles were designed for a certain type of network, leading to some growing pains

Technical designs
- Packet switching
- Fate sharing
* Goal
Goal of the internet: Multiplexed utilization of existing interconnected networks
- Multiplexing = shared use of a single communications channel
  - solution: statistical multiplexing/packet switching
- Interconnection
  - solution: narrow waist
* Packet Switching
- Information for forwarding traffic is contained in destination address of packet
  - No state established ahead of time
  - "Best effort" service: few assumptions made about the level of service the network provides
- Many senders can send over the network at the same time, sharing the resources along the way
  - In contrast to the phone network
    - resources are dedicated and allocated until the phone call ends
    - "circuit switching": a signaling protocol sets up a dedicated path out of band. 
  - Advantage: sender never gets the busy signal
  - Disadvantage: delay and potential for data loss/dropped packets
* Packet Switching vs Circuit Switching Quiz
| PS | CS |                                                 |
|----+----+-------------------------------------------------|
| x  |    | Variable Delay                                  |
|    | x  | Busy signal                                     |
| x  |    | Sharing of network resources                    |
|    | x  | Dedicated resources between sender and receiver | 
* Narrow Waist
Goal: Interconnect many existing networks and hide underlying technology from applications

- The Internet has a lot of layers. In the middle is the internet protocol in the network layer. Every internet device must speak IP!
  - Layers provide some guarantees to the layers that sit on top of it.
  - Layers:
    - Application layer (HTTP, SMTP)
    - Transport layer guarantees reliable transport and congestion control
    - Network layer guarantees end-to-end connectivity to the transport layer (TCP/UDP)
      - Ex. if a host has an IP address, then the network layer guarantees that the packet with that dest IP address should be sent to that host
    - Link layer: provides p2p (point to point) connectivity, or connectivity on a LAN
    - Physical layer underneath link layer
  - The network layer only has one protocol in use, IP. Every device must speak it, but as long as it can speak it, it can get on the internet (IP over anything)
    - Drawback: difficult to make changes to this layer
- I think 'Narrow waist' refers to how there is basically one network layer protocol in the middle, but there are many protocols at each layer
* Other Goals: Survivability
- Survivability: network works even if some devices fail
  - to achieve this
    - replication: if any node crashes, there's a standby to take over
    - fate sharing: it's acceptable to lose state for some entity if that entity is lost. 
      - ex. if a router crashes, routing tables are lost
      - this makes it easier to
	- withstand complex failures
	- engineer
      - Answer from piazza:
	- The idea of fate sharing is the node running the application also maintains state information for the connection. So it is more host A is connecting through a series of routers to get to host B. If host A starts a file transfer to host B, in the fate sharing model, host A also keeps track of the packets sent and acknowledged. If a router goes down in between, the file transfer information is still maintained on host A and when the traffic reroutes to another router inbetween, the transfer can continue where it was. If host A goes down, both the file transfer and the state information associated with it are lost together. They share the same fate. 
* Other Goals: Heterogeneity
Supported by TCP/IP protocol stack
- TCP/IP is a monolithic transport
  - TCP provided flow control and reliable delivery
  - IP provided universal forwarding
- Not every application needs reliable delivery (streaming, DNS)
- Narrow waist of IP allowed for proliferation of other transport protocols besides TCP

Also supported by "Best effort service" model: network doesn't provide quality guarantees, or info about failures, performance, etc.
  - simple design but makes debugging hard
* Other Goals: Distributed Management
Achieved by:
- Addressing (ARIN in US, RIPE in UK)
- Naming: DNS (allows each organization to manage its names)
- Routing: BGP (allows each network to configure its own routing policy)
- Allows for organic growth and stable management
- but there are no "owners"
  - difficult to figure out who/what is causing problems
  - local misconfiguration can have global effects

- Other design goals:
  - cost: arguably successful
  - ease of attachment: successful, since IP is plug and play (narrow waist)
  - accountability: not prioritized. Billing is less precise

* What's missing from the paper
No discussion of:
- security
- availability
- mobility
- scaling
* DARPA Paper Quiz
- Which topics were discussed in the paper?
  - Security
  - Heterogeneity   // YES
  - Interconnection // YES
  - Sharing         // YES
  - Mobility
* End to End Argument
- The knowledge you need to implement an application should be placed at the endpoints and not in the middle of the network
- ex.
  - error handling in file transfer
  - end-to-end encryption
  - TCP/IP split in error handling
- Essentially, "Dumb network, intelligent endpoints"
* E2E Argument: File Transfer
Example 1 - Comp A wants to send file to B:
- on A
  1. Read file from disk
  2. communication system sends file
  3. Transmit packet
- on B
  1. Give file to file transfer program
  2. Write to disk
- So what could go wrong with this?
  - Reading and writing
  - Breaking up and assembling the file
  - communication system
- Possible solutions
  - ensure each step has error checking
    - all checks require application level checking, so it might not be economical to perform checks at different layers and at different places
  - end to end checking
    - use checksum
  - We need to think of tradeoffs between reliability and performance. Is it really worth the loss in performance for checking at each step?

Example 2 - encryption:
- Keys are maintained by end applications and cipher text is generated before the application sends the message across the network
- What are the "ends"? This needs to be answered first
  - if application involves routing, the ends are routers
  - if application is a transport protocol, the ends are end hosts

* E2E Argument Violations
The End-to-End argument is not a theorem or law; it's just a principle to abide by

The following violate the argument:
- NAT
- VPN tunnels
- TCP splitting (done to improve performance, when last hop is wireless. Loss on last hop may not reflect congestion, and we don't want TCP to react to losses not related to congestion)
- Spam (users are ends, but the spam is being prevented from getting to the ends, which is in violation of the argument)
- P2P systems (files are exchanged between two nodes, but are assembled in chunks that are traded among peers)
- Caches

It's worth asking whether the argument is still relevant today and in what cases.

Questions:
- What's in/out
  - routing
  - multicast
  - QoS (quality of service)
  - NAT

Is the argument restricting innovation?
* E2E Argument: Violation NAT Part 1
- Home gateways perform network address translation, and a home network is given one public IP address by the ISP. However, there are multiple home network devices
  - each of these devices are given a private IP address
  - The internet sees only one public IP address
- Outgoing traffic (home to internet): source IP is overwritten with public IP address
- Incoming traffic (internet to home): NAT needs to know which device to send to
  - It uses mapping of port numbers to determine which device in the home network to send to
  - NAT rewrites the destination address with the appropriate private IP address
  - ex.
    - device 1: 192.168.51:1000 -> 68.211.6.120:50878
    - device 2: 192.168.52:1000 -> 68.211.6.120:50879
* E2E Argument: Violation NAT Part 2
- NAT violates the principle because the machines behind the NAT are not globally addressable or routable, and other hosts on the internet cannot initiate inbound connections with these machines behind the NAT
- Ways to get around this:
  - STUN (signalling and tunneling through UDP enabled NAT devices)
    - device sends outbound packet somewhere to create an entry in the NAT table
    - we now have a globally routable address and port to which devices on the internet can send traffic
  - statically map the addresses on NAT
