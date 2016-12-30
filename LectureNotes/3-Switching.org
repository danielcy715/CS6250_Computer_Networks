* Intro
A network serves to route packets between machines on the network
* Switching and Bridging
Problem:
- How hosts find each other on a subnet
- How subnets are interconnected

Also:
- Switches vs. hubs
- Switches vs. routers
- How to scale ethernet
* Bootstrapping: Networking Two Hosts
- Host 1 and 2 are connected by two ethernet adaptors, or network interfaces, and each host has a LAN or MAC address
- A host that wants to send a datagram can send the datagram via its ethernet adapter with the destination MAC address of the other host
  - A destination can also be a broadcast MAC address, in which case the datagram is sent to all machines on the network
- Problem: How does a host learn the MAC address of another host?
  - ARP: Address resolution Protocol
* ARP: Address Resolution Protocol
- Host queries with IP address "who has IP address <ip>?"
  - This is broadcast
- Host with that IP responds with MAC address
  - This is unicast
- The querying host receives a reply, adds entry in ARP table
  - maps IP addresses with corresponding MAC addresses
- the host can now just look up the MAC address in this table
  - Host wants to send packet to a certain IP
  - encapsulates IP packet in ethernet frame with corresponding dest MAC address
* Quiz: ARP
What are the queries and responses in ARP?
- Query: Broadcast asking about IP, Response: Unicast with MAC address // YES
- Query: Unicast asking about IP, Response: Broadcast with MAC address
- Query: Broadcast asking about MAC address, Response: Unicast with IP address
* Interconnecting LANs with Hubs
LANS can be connected via hub. Hubs don't really exist today anymore

A hub is a broadcast medium among all connect hosts
- packets are broadcast, even if a packet was meant for one other host
  - causes a lot of flooding
  - collisions of frames
    - collision introduces latency (other hosts have to back off and not send as soon as they see other senders trying to send)
    - vulnerable to failures/misconfiguration (one failing device will affect the entire network)
- we want a connecting device that imposes some traffic isolation
* Switches: Traffic Isolation
- Partitions the LAN into separate broadcast domains
- A switch breaks a subnet into multiple LAN segments
- A frame bound for a host in the same subnet is not forwarded to other segments
  - If are three hubs connected to a switch, and a host sends a packet within the segment, that frame will be broadcast, but the switch will not forward that frame to the other LAN segments
- This requires a switch table that keeps track of state
  - Maps destination MAC to output port
* Learning Switches
A learning switch maintains a table with the MAC address and the output port on a switch
- Initially the table is empty, so the learning switch must at first broadcast incoming frames if the dest host doesn't have an entry in the table
- For example, if host A sends a frame destined to host C and the table is empty, the frame floods to all outgoing ports
- The switch can make an association between the src host A and the incoming port, and makes an entry in the table
- Host C replies with frame destined to A. The switch now has an entry that says not to flood the packet, and just sends the packet directly to A
- Also, when C replies, switch learns the association between the src host C and the incoming port, and makes an entry for host C in its table

Learning switch floods when there's no entries in the table, and when there are broadcast frames, so we still need to be careful of loops
- Loops are for redundancy to maintain connectivity in case of failure
- Suppose you have two learning switches
  - A host broadcasts a frame, and one switch hears the frame, and rebroadcasts on all ports
  - The other switch hears the frame, and rebroadcasts on all outgoing ports
  - This process continues, and creates loops and broadcast storms
  - We need a protocol to create a logical forwarding tree to ensure that the switch doesn't always rebroadcast on all outgoing ports
* Quiz: Learning Switches
Say that Host D on port 4 sends a frame to Host B on port 2. Assuming the table is empty, fill out the new entry in the table:

| DST | PORT |
|-----+------|
| D   | 4    |
* Spanning Tree
Solution to looping: spanning tree, a loop free topology that covers every node
- Nodes forward packets to other nodes that are part of the tree

** Constructing a Spanning Tree
1. Elect a root (switch with smallest ID)
   - at first, every node thinks it is the root
   - each switch updates what it thinks the root is
   - each switch then computes its distance from the root
2. At each switch
   - exclude link if not on shortest path to root
* Spanning Tree Example
Message Format: (y: claimed root, d: distance from root, x: origin/id)

Assume that switches 2, 4, and 7 are connected in a triangle
1. Initially, each switch broadcasts a message like (x, 0, x) (it thinks itself is the root)
2. Let's say switch 4 thinks its a root, so it sends (4, 0, 4) to switch 2 and 7
3. 2 thinks it's the root, so it sends (2, 0, 2). 4 will update its view of the root to 2. It will also see that it's just one hop away from the root, so it updates its distance from the root
4. 4 will hear a message from (2, 1, 7), indicating that 7 thinks it's 1 hop away from 2, and realize that 7 is the longer path to the root, 2
5. This process repeats itself until a spanning tree is constructed
* Switches vs. Routers
- Switches operate at layer 2, common protocol: ethernet
  - auto-configuring
  - forwarding tends to be fast
  - more convenient, but limited in broadcast
    - spanning tree and ARP queries impose a high load
    - but there are still ways to scale this to larger topologies
- Routers operate at layer 3, common protocol: IP
  - not restricted to spanning tree
    - Can have multipath routing. Packet can be sent to one of multiple possible pathsa

SDN blurs the line between layer 2 and layer 3
* Buffer Sizing
Important question in switch design: How much buffering do routers/switches need?
- Routers and switches need packet buffers to accommodate for statistical multiplexing.

Rule of thumb (assume routers and switches can be used interchangeably)
- Router is a store and forward device
- Source - Router -C- Destination
  - Roundtrip time: 2T
  - C is the bottlenck link
  - Router needs a buffer of 2T * C 
    - C is bits/sec, T is sec
    - Number of bits of outstanding data that can be on this path at any given time
    - The bigger the buffer, the bigger the cost and queueing delay, and the longer the source can hear about congestion on the network
* Buffer Sizing for a TCP Sender
Read [[https://en.wikipedia.org/wiki/TCP_congestion_control#Congestion_window][this]] for some context

Seems like this has to do something with TCP congestion control. To avoid congestive collapse, the rate of sending packets must be controlled. This rate is controlled by the congestion window, W. This window is increased using the slow start algorithm up to a certain threshold (ssthresh), at which point, AIMD algorithm, a congestion avoidance algorithm, is used to increase and decrease the congestion window

Lecture notes:
- Number of packets in flight = number of packets unacknowledged with ACK packets
- TCP sender sends packet where the packet sending rate is controlled by window W
- Rate of packet sending, R = W / (Round trip time)
- TCP: uses AIMD (additive increase, multiplicative decrease) congestion control
- For W ACKS received, send W + 1 packets
- The required buffer size (the number of packets in flight) is the height of the TCP sawtooth, the distance between W and W/2
- We want sender to send at a constant rate of R

See some handwritten notes on how the instructor arrives at B = 2T * C since he just skims over the algebra.

B = 2T * C makes sense if 20,000 flows are synchronized. If these flows are desynchronized, we can use a smaller buffer
* 
