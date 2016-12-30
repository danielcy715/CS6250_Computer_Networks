* Traffic Engineering Overview
- The process of reconfiguring the network in response to changing traffic loads, to achieve some operational goal like:
  - peering ratios
  - relieve congestion on certain links
  - balance load 

IP Networks Must Be Managed. Some examples:
- TCP senders send less traffic when there's congestion
- Routing protocols will adapt to topology changes

Problem: Does the network run efficiently? 

How should routing adapt to traffic?
- avoid congested links
- satisfy application requirements 

Outline:
- Tuning routing protocol configuration
- intranet and interdomain traffic engineering
- multipath routing
* Interdomain Traffic Engineering
Tuning Link Weights

Suppose we have a single AS with static link weights
- routes will flood information to learn topology like link weights
- an operator configures link weights
  - this affects the shortest path between two points
  - if an operator wants to reduce the load on a link, it can increase the link weight

An operator can change the link weights in a variety of weights
- inversely proportional to capacity
- proportional to propogation delay
- network-wide optimization
* Measuring, Modeling, and Controlling Traffic
- Traffic engineering is done in three steps: measuring, modeling, and controlling traffic
  - measure: figure out current load
  - model: model how configuration affects the underlying paths
  - control: reconfigure network

A network operator will feed topology and traffic info to a what-if model that predicts what will happen under configuration changes, decide what changes to affect the network, and control the network behavior by readjusting link weights

Intradomain Traffic Engineering: Optimization
- intradomain traffic engineering attempts to solve an optimization problem where the input is:
- Graph G(R, L)
  - R: set of routers
  - L: set of links
  - each link has c_l: capacity of l
  - traffic matrix: M_{ij}
- output is set of link weights w_l that would result in a fraction of the traffic from i to j traversing each link l such that these fractions satisfy the requirements of the objective function
* Link Utilization Function
Cost of congestion increases in a quadratic manner as load increases. Solving the optimization problem is easier if we use a piecewise linear cost function

Utilization: Amount of traffic on a link / capacity of a link

objective: 
\begin{equation}
min\Sigma f(\frac{u_l}{c_l})
\end{equation}

This is NP complete, meaning there's no efficient algorithm. We have to resort to searching through configuration settings. Graphs are small enough where this is feasible. In practice, we could:
- minimize changes to the network
- changes must be resistant to failure
- limit the frequency of changes

Intradomain vs. Interdomain Routing
- Intradomain: within a domain (e.g. ISP, campus, datacenter)
- Interdomain: between domains
* Interdomain Routing Quiz
Which of the following are examples of interdomain routing?
- Peering between two ISPs // YES
- Peering between a university network and its ISPs // YES
- Peering at an Internet exchange point // YES
- Routing in a data center
- Routing across multiple datacenters // YES
* BGP in Interdomain Traffic
Interdomain traffic engineering involves reconfiguration of BGP
- Changing BGP policies at edge routers can cause routers inside an AS to direct traffic to or away from certain edge links
- We can also change egress links for a destination
- An operator might want to reconfigure links if there is congestion at a link, if a link is upgraded, or there is a violation of a peering agreement
  - if the load exceeds a previously agreed upon limit, traffic can be shifted from one egress link to another
* Interdomain Traffic Engineering Goals
- predictability:
  - suppose that a downstream neighbor is trying to reach top AS. The middle AS wants to relieve congestion on a peering link. The downstream neighbor will then send ttraffic through a different AS, but now it's using a longer path. In response, the downstream neighbor might not use that path at all. All that work was for nothing...
  - Solution: avoid making changes that are globally visible. 
- limit influence of neighboring domains
  - an AS might try to make a path look longer with AS path prepending. If we consider treating paths with similar AS path lengths as a group, we might get more flexibility
  - enforce a constraint that neighbors advertise consistent BGP route advertisements over multiple peering links -> additional flexibility to send traffic over different egress points (difficult in practice)
- reduce overload of routing changes
  - group related prefixes
* Multipath Routing
An operator can establish multiple routing paths in advanced

applies to both inter and intradomain routing:
- intradomain: set link weights such that routes with equal cost exist between two points (equal cost multipath (GCMP). Traffic can be split between the two paths of equal cost based on level of congestion along the paths. It can do this by having multiple routing table entries with different next hops for outgoing packets to the same destination
* Source Router Path Quiz
- How can a source router adjust paths?
  - dropping packets to cause TCP backoff
  - Alternating between forwarding table entries // YES
  - Sending alerts to incoming senders
* Data Center Networking
- What characterizes a datacenter?
  - multi-tenancy: allows a datacenter provider to advertise cost of shared infrastructure that must also provide security and resource isolation for each tenant
  - resources are elastic: as demand fluctuates, operator can change resources
  - flexible service management: move loads across different locations in the datacenter
    - add additional VMs, or move VMs to different servers -> creates need for TE solutions inside a datacenter. Virtualizing servers allows moving and migrating servers and services easier. TE is needed to allow network to reconfigure in response to changing workloads and migrating services
* Data Center Networking Challenges
- Traffic load balance
- support for VM migration
- power savings
- provisioning network when demand fluctuations
- security guarantees when there are multiple tenants

Data center topology typically has 3 layers:
- access: connects servers
- aggregation: connects access layer
- core: historically data 3, but modern core is layer-2
  - makes it easier to perform migration of services from one topology because they don't need new ip addresses when they move
  - easier to load balance
  - makes scaling difficult: we have a ton of servers on flat topology. layer-2 addresses are not hierarchical
    - but layer 3 hierarchy offers single points of failure and oversubscription of core links (200 times the amount of traffic of access links)
* Data Center Topologies
- Scale problem arises because we have many servers on flat layer-2 topology. Every switch stores a forwarding table entry for every mac address
- solution: assign pods, and make pseudo mac corresponding to pod
  - switches can have FT entry for pods. The switch of a pod maintains FT entries inside its own pod
  - problem: mapping pseudo mac to real mac
    - hosts will still respond to ARP queries with their real MAC addresses.
    - solution: when a host issues ARP query, query is intercepted by a switch. Instead of flooding, the switch intercepts the query and forwards it to the fabric manager. Fabric manager responds with psuedo mac corresponding to the MAC address. The host sends frame with dst pseudo mac address, and switches forward frame to the right pod with the pseudo mac address. Once the packet reaches the pod, the switch of the pod maps pseudo mac address to the real mac address. The dst host receives a frame with its real mac address
    - this way we achieve hiearchical forwarding in a flat layer-2 topology without modifying host software
* Data Center (Intradomain) Traffic Engineering
Through customized topologies and special load balancing to reduce link utilization and hops, and make it easier to maintain data center

- limited server-to-server capacity because of oversubscription of links at the top of the topology
- services are migrated to different part of the data center leads to fragmentation, lowering utilization
  - if a service is running mostly in one part of the datacenter, and a little bit in another part, it requires the traffic to traverse the datacenter, lowering utilization and cost efficiency
  - reducing this results in complicated L2/L3 re-configuration
    - we'd like the abstraction of one large L2 switch, which VL2 provides
      - achieves layer 2 semantics across the whole datacenter topology using a name-location separation and resolution service, like the fabric manager
      - relies on flow based random interaction using valiant load balancing
* Valiant Load Balancing
Goals:
- spread traffic evenly
- ensure traffic is distributed independently of dst of traffic flows

Achieves this by inserting indirection level in the switching hierarchy
- when a switch at the access layer wants to send traffic to dst, it selects a switch at the indirection level to send traffic at random. This switch forwards traffic to ultimate dst depending on dst mac address. subsequent flows might select different indirection switches
* Jellyfish Data Center Topology
Jellyfish: Networking Data Centers Randomly

Goals: 
- achieve high throughput to support big data or VMs
- incremental expandability to support easy replacement of servers

Problem: structure constrains expansion
- hypercube needs 2^k servers
- 3-level Fat Tree: quadratic
* Data Center Topology Quiz
Where does datacenter structure constrain expansion?
- servers
- aggregation switches
- top level switches // yes 
* Jellyfish Random Regular Graph
Jellyfish's topology is a random regular graph.
- random: each graph is uniformly selected at random from the set of all regular graphs
- regular graph: each node has same degree
- switches are nodes

Approach:
- construct a random graph at the Top of Rack switch layer
- every switch i has some total number of k_i ports, r_i of which is used to connect to other ToR switches. k_i - r_i of these ports are used to connect to servers
- with N racks, network supports N * (k_i - r_i) servers
- network is a random regular graph denoted as RRG(N, k, r)
- RRG are sample uniformly from a space of R regular graphs
* Constructing a Jellyfish Topology
-Pick a random switch pair with free ports, and they are not neighbors. Join them with a link. 

Benefits: Higher capacity - 25% more servers. This is due to shorter paths in the topology. 

Open questions:
- topology design
  - how close are random graphs to optimal?
  - what about heterogeneous switches with different # of ports or link speeds
- system design?
  - cabling?
  - routing, congestion control?
