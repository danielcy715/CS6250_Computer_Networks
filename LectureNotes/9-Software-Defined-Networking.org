* Network Management Overview
What is network management?

Network management is the process of configuring a network to achieve a variety of tasks:
- acheiving load balance
- meeting security goals
- maintaining business relationships

Mistakes in network management can lead to:
- oscillation: routers can't agree on a route to a destination
- loops: packets end up stuck between two routers and never makes it to its destination
- partitions: network is split into two or more segments that are not connected
- black hole: packet reaches a router that doesn't know what to do with it and drops it
* Why is Configuration Hard?
1. Defining correctness is hard
2. Interactions between routing protocols -> unpredictability
   - each AS is independently configured, and interaction between these ASes lead to unwanted behavior
3. Operators make mistakes
   - configuration is difficult, policy is complex
   - devices in a network are configured with vendor specific configuration
   - SDN changes this by centralizing configuration

What operators need (and what SDN provides):
1. Network-wide views
   1. topology
   2. traffic
2. Network-level objectives
   1. load balance
   2. security
   3. etc
3. Direct control
   1. allows operator to write a control program that directly affects the data plane

To make network operations easier, routers should:
- forward packets
- collect measurements
- a router shouldn't have to compute routes. These calcualtions can be done in a centralized location
  - AKA SDN == "Remove routing from routers"
* Software Defined Networking
- What is an SDN
  - Today's networks have two functions:
    - data plane: forward packets. Routing tables maintain state that allows routers to make decisions on where to forward packets
    - control plane: compute routing tables
      - in SDN, the control plane runs in a logically centralized controller that controls all the routers in a network
      - This separation of data from control allows a shift from vertically-integrated networks to open interfaces and faster innovation
- Brief history of SDN
  - pre-2004: distributed distribution -> buggy behavior
  - 2004: RCP (routing control platform) focused on BGP
  - 2005: RCP was generalized for planes (4D)
    - decision plane: computed state for devices on the network
    - data plane: forwarded traffic based on decisions made by the decision plane
    - dissemination and discovery planes: provide the decision plane info so that it can compute states
  - 2008: These concepts became mainstream through OpenFlow when silicon vendors opened their APIs so that switch chipsets could be controlled from software -> cheap switches that can be controlled from software -> allowed the decoupling of data and control planes
* Advantages of SDN
1. Coordination of behavior among devices
2. evolve
3. reasoning

These are rooted from the fact that the control plane and data plane are separate. 

These advantages allow us to apply CS techniques to networking problems

Infrastructure:
- Control plane is a software program written in a high level language
- data plane is typically programmable hardware
- The control plane controls the data plane with control commands. OpenFlow is one standard that defines commands . 

Applications:
- data centers
- backbone networks
- enterprise networks
- internet exchange points (IXPs)
- home networks
* Control Plane Operations
Examples of contorl plane operations?

- Computing a forwarding path that satisfies a high level policy // YES
- Computing a shortest path routing tree // YES
- rate-limiting traffic // NO - dataplane
- load balancing traffic based on hash of of source IP // YES
- Authenticating a user's device based on MAC address // YES
* Control Plane and Data Plane
Control plane contains the logic that control forwarding behavior
- routing protocols
- configuration for network middle boxes
Data plane:
- forward packets according to control plane logic at the IP layer
- packet switching at layer 2

Why is separating the two functions a good idea?
- independent evolution
  - software control of the network can evolve independently from the network hardware
- control from a high-level program
  - allows for easier debugging
- provides opportunities for:
  - better network and data management such as VM migration to better cater to fluctuating network demands
  - routing: provide more control for decision logic
  - enterprise networks: ability to write security applications
* Reasons for Separating Data and Control
- Independent evolution of data and control plane
- separating vendor hardware from control logic
- easier reasoning about network behaivor
* Example: Data centers
- One example of a benefit of SDNs is in a data center
- a cluster in a data center can contain about 20,000 servers, each with 200 VMS = 400,000 VMs
- problem: migration of these VMs from one serer to another in response to load
- solution: program switch state from a central controller
- also made easier by the fact that the servers are addressed with layer 2 addressing, so the entire datacenter looks like a flat layer 2 topology
  - so this means a VM can be migrated to another server without obtaining a new address. We just need to update the switch state
* Managing Data Centers Quiz
How does control/data separation make managing data centers easier?
Answers:
- monitoring control of routes from a central point
- migrating VMs without renumbering host addresses
* Challenges
Another example of a benefit of SDNs is in backbone security. The goal is to filter attack traffic. A central controller will install a null-route to ensure that the attacker traffic is not reaching the victim

The following are challenges present in SDN:
- Scalability: hundreds to thousands of switches
- consistency: ensuring that replicated controllers have the same state
- security (robustness): what if one of these replicas fails or is compromised
* Coping with scalability (Quiz)
Ways to cope with scalability challenges?

Answers:
- Eliminate redundant data structures
- only perform control-plane operations for a limited # of ops
- cache forwarding decisions in switches
- run muliple controllers
* Different SDN Controllers
- NOX
- Ryu
- Floodlight
- Pyretic
- Frenetic
- etc.
* NOX: Overview
- first gen OpenFlow controller
- open source, stable, widely used
 
Two flaors
- classic: C++ Python
- New: C++ only, fast, clean

Components:
1. switches
2. network-attached servers

- Controller has a network view, and the controller might have some applications running on it that operating on this view
- Abstraction: switch control
- Control: flow granularity
   - Flow = ten-tuple of src IP, dst IP, src port, etc
 
A flow is defined by the header (ten-tuple), counter (maintains statistics, actions (forward, drop, send to controller)

When a switch receives a packet, it updates its counter for that flow, and applies the corresponding action

Programmatic Interface is based on events
 - switch join/leave
 - packet in/receievd
 - statistics
 - controller keeps track of a network view

Controller protocol can update the state of switches

NOX controller implements OpenFlow protocol

NOX is implemented in C++ and supports OpenFlow 1.0

Programming model is event-based

Good performance, but low-level openflow and needs to be written in C++ (slow development). POX can be used as a Python alternative, but has worse performance
* When to use POX?
- Class project or university research (need to quickly protoype and evaluate a control application). Less applicable in a large data center because it doesn't perform well
* Ryu, Floodlight, Nox, and Pox
Ryu
- python (doesn't perform as well)
- OF 1.0, 1.2, 1.3, Nicira extension (advantage)
- OpenStack (advantage)

Floodlight
- Java
- OF 1.0
- Fork from Beacon
- Good documentation, REST development, performance
- Hard to learn
* Customizing Control
- Review hub/switch
- POX controller w/ simple mininet topology
- two types of control

Hub:
- doesn't maintain state for which output port to forward packet to. It forwards to every output port.
- POX:
  - when controller starts, it adds listener that listens for connection up (connection to switch)
  - when switch connects, it sends openflow modification that says "flood all packets out all output ports"

Switch
- learning switch maintains table that associates hosts with output ports
- When first packet arrives at switch, it's diverted to the controller.
- controller maintains hash table that maps address to output port
- If multicast, contoller floods
- if no table entry, controller floods
- if src = dst, drop
- install flow table entry corresponding to the destination address and output port

* Summary
Modifying forwarding behavior is easy because forwarding decisions are based on matches based on openflow ten-tuple

Switching: 
- {*, *, ... DST MAC, * } -> output port

Flow switching:
- {all entries are matched} -> output port

Firewall:
- {...src mac, *, *, ...} -> forward/drop

Caching
1. Packets only reach controller if no flow table entry at switch
2. When controller decides an action, installs in switch
3. Decision/flow table entry is cached
4. Switch doesn't need to divert packets to controller for that flow

Summary:
- Customizing control is easy
- Turning switch -> firewall < 40 lines of code
- Performance benefits of caching rules/decisions (sending packets to controller slows things down)
* Updates SDNs
- Last lesson: updating switch flow table entries from the controller

Consistency Problems:
1. Updates to multiple switches may disrupt along an end to end path (packet-level)
2. Packets from the same flow may be disrupted and subjected to two different states (flow-level)
* SDN Programming Introduction
1. Controller needs to read/monitor state and events (failures, topology changes, security events)
2. Compute policy based on state (role of decision plane)
3. Write policy back to switches by installing flow table

Inconsistency occurs in two steps
1. Controller reads state from network switches at different times, resulting in inconsistent view of network state
2. Controller writes policy as traffic is flowing through the network

Reading and writing is challenging because OpenFlow is a simple pattern match mechanism

Reading state w/ Multiple rules

Example: Web server traffic except src 1.2.3.4:
- simple match action rules don't allow such exceptions
- solution: predicates
  - (srcip != 1.2.3.4) && (srcport == 80)
  - runtime system translates predicates to lower level openflow rules

Problem: Limited # of rules. It's not possible to install all possible patterns

Solution: runtime system dynamically "unfold" rules as traffic arrives
- programmer specifies "groupby(srcip)"
- Runtime system dynamically adds rules
* Reading Network State
Extra unexpected events might introduce inconsistency

Idiom: packet goes to controller, control makes decision, and installs rules to switches
- What if more packets arrive before the controller can install rules
- The application may not want to see these additional packets
- solution: programmer specificies limit(1) (application only sees first packet of the flow)

So far, we've talked problems about consistency in reading state and their three approaches to guarantee consistency:
- predicates
- unfolding
- suppression
* Writing Network Policy
We can write policy to change state in network swithces:
- maintenance
- unexpected failure
- traffic engineering

When state transition happens, we want to make sure forwarding remains consistent
- no forwarding loops
- no "black holes" (router receives packet and doesn't know what to do with it)
- no security violations

Example: Traffic Engineering
- Suppose operator wants to change the network state to shift traffic off of a link. He could do so by updating the link weight
- But what if the state of the top switch is updated before the bottom switch? We would have a potential forwarding loop. The top switch forwards to the bottom switch, but the bottom switch didn't get the updated state yet, so it forwards it back to the top switch
- The packet arrived to the bottom switch before the rule did
- We require atomic updates of the entire configuration

Solution: Two-Phase Commit so packets are subjected either to the old config on all switches, or the new config on all switches
- tag packets with version numbers (e.g. p1, p2). This refers to the version of the state rules
- Only when all the switches receive the new rules will the network treat the packets with the new rules
- Remove the old rules when packets marked with the old version run out
- The naive approach to this solution is to do this for all switches at once, which doubles the rule space requirements since we're storing both rules for P1 and P2. We could optimize by applying the mechanism only on affected portions of the network 
* Inconsistent Policy Write Quiz
What problems can arise from inconsistent "writes" of network state?
- Inability to respond to failures
- forwarding loops // YES
- a flood of traffic at the controller // Reading state
- security policy violations // YES
* Coping with Inconsistency Quiz
What are some ways of coping with inconsistency?
- Different controllers for different switches
- keeping a "hot spare" replica
- Keeping the old and new state on the router/switch // YES
- relying on the routers to resolve conflicts
* Network Virtualization
- What is network virtualization?
  - abstraction of physical network where mulitple logical networks on shared physical substrate
    - a logical network might map onto an underlying physical topology
    - multiple logical networks can map onto the same physical topology
    - each logical network has its own private view of the network
    - nodes in the physical network are shared, or sliced. The nodes may be virtual machines
    - links might map to multiple logical links
      - this is achieved by tunneling
    - Analogy to virtual machines
      - a hypervisor arbitrates access to underlying physical resources
      - a network hypervisor does the same to multiple virtual networks providing the illusion that each network has its own dedicated resources
* Why use Network Virtualization
- Ossification of internet architecture
  - IP was so pervasive, it was difficult to make changes to the underlying architecture
  - virtualization allows for easier evolution by letting multiple architectures exist in parallel
- In practice, network virtualization is often used in multi-tenant datacenters (multiple applications running on a shared cluster of servers)
  - amazon EC2
- Adjust resources to services
* Network Virtualization Quiz
Motivation for virtual networking?
- easier troubleshooting
- facilitating research/evolution by allowing coexistence // YES
- better forwarding performance
- adjusting resources to demand // YES
* Network Virtualization Uses SDN
Promised benefits of network virtualization:
- rapid innovation (software speed): innovation can proceed at the rate at which software evolves, instead of hardware
- new forms of network control
- (potentially) simpler programming

SDN (separate data and control) vs Network virtualization (separate logical and physical)
* Characteristics of Network Virtualization?
Which of the following are characteristics of network virtualization?
- Allowing multiple tenants to share underlying physical infrastructure // YES
- Controlling behavior from a centralized controller
- Separating logical and physical networks // YES
- Separating data and control planes
* Design Goals for Network Virtualization
- Flexible: support different topologies, configurations
- Manageable: separate policy and mechanisms
- Scalable: maximize number of coexisting networks
- Secure: separate coexisting networks
- Programmable
- Able to support different technologies

How are virtual networks implemented?
- Nodes: VM, or virtual environment (jail, vserver)
- Edges: Tunnel
  - Encapsulate the IP packet with an ethernet frame  when sending the traffic, and decapuslate the ethernet frame to get the IP packet. This gives the illusion that the VMs are connected on Layer 2, even if they are actually separated by multiple IP hops
    - A switch provides this function. A Linux bridge is one example of this
* Virtualization in Mininet
We are running a virtual network on a single machine
- Each host is a bash process with its own network namespace
  - network namespace is sort of a lightweight virtual machine, OS level virtualization
- root namespace manages communication between these nodes and the switch
- ethernet interfaces are assigned to these host nodes
- openflow switch performs forwarding between interfaces in root namespace. Because these interfaces are paired to virtual interfaces, it gives the illusion of sending traffic between different hosts.
- modifications to the openflow switch is done in the root namespace

Summary
- virtual networks facilitate flexible, agile development
  - rapid innovation
  - vendor independence
  - scale
- SDNs vs. virtual networks
- tehnologies: VMs, tunneling
* SDN Programming Difficulty
Problem: programming openflow is not easy
- it offers low level of abstraction in the form of match action rules
- controller only sees events that switches don't know how to handle
- race conditions if switch-level rules are not installed properly
  - consistent updates
* SDN Programming Interface
- Solution: "Northbound" API
  - at the low level, we have a controller that updates state in the switch using openflow rules (southbound)
  - above that, we have applications and orchestration systems that perform more sophisticated tasks like path computation and loop avoidance
  - but we need a higher level programming interface that allows apps to talk to controller so that the app is not writing low level openflow rules but instead expresses higher level behavior
  - benefits: vendor independence, customize control with various programming languages
  - application can be written in a higher level language, and not worry about low level switch modification, but express policies with higher level abstractions such as:
    - large virtual switch
    - security apps
    - middlebox integration
  - there is no standardized northbound API
* Frenetic Language
- SQL-like query language
- example: count number of bytes grouped by dest mac address and report updates to counters every 60 seconds
#+BEGIN_SRC 
select(bytes)
   where (in: 2 & srcport: 80)
   groupBy(dstMAC)
   every(60)
#+END_SRC
http://frenetic-lang.org
* Overlapping Network Policies
An issue with writing at a higher level of abstraction is that a programmer programs modules that affect the same traffic. For example, suppose there are modules that:
- monitor traffic
- route traffic
- specifies firewall rules
- balances traffice load

All these apps are combined into a single openflow rules. We need composition operators, or ways to specify how these modules are combined
* Composing Network Policies
- Parallel: perform both operations simultaneously (e.g. counting and forwarding)
- Sequential: Perform one operation, then the next (e.g. whatever passes through the firewall is subjected to the counting policy)

Example of Sequential Composition: Load balancer
- a policy takes some traffic coming from half of source IP address and rewrite it to one server replica, and take other half and rewrite it to another server replica.
- We need a routing module to forward traffic out the appropriate ports of the switch
- we used sequential composition to first apply load balance policy that rewrites the dst ip address based on src ip address, and sequentially apply routing policy that forwards traffic out the appropriate port depending on the dst ip address
- we can use predicates to specify which traffic traverses which modules using fields like input ports and header fields
- benefits 
  - allows each module to partially specify functionality without having to write policy for the entire network
  - allows for module reuse, since a module is not tied to a network setting

Summary:
- northbound API that sits on controller that provides higher-level abstractions that allows a programmer to write policies without having to worry about open flow rules
- composition: how to compose policies to implement more complex applications
* Pyretic Language
SDN language and Runtime

Language: expresses policy
Runtime: compiling these policies to openflow rules

key abstraction: "located" packets - we apply policies based on a packet and its location in the network

features:
- take as input a packet and return packets at different location in the network
  - implements network policy as a function
    - in openflow, policies are just bit patterns/match statements
    - in pyretic, policies are function that map packets to other packets
      - identity function: original packet
      - none (drop)
      - match (returns identity if function = v)
      - mod (modify packet so that f = v)
      - forward (syntactic sugar of mod)
      - flood (returns 1 packet for each port)
- boolean predicates: unlike openflow rules
- virtual packet header fields: allows programmer to refer to packet locations and to tag packets so that specific functions can be applied
- composition operators: parallel and sequential

- in addition to standard packet header fields, pyretic offers virtual packet header fields
  - in pyretic, a packet is a dictionary of field names to values
* Composing Network Policies in Pyretic
Sequential Composition
- match(dstIP=2.2.2.8) >> fwd(1)
  - >> is the sequential composition operator

Parallel Composition:
- match(dstIP=2.2.2.9) >> fwd(1) + match(dstIP=2.2.2.8) >> fwd(2)
  - + is the parallel composition operator

Pyretic allows operator to query packet streams:
- self.query = packets(1, ['srcmac', 'switch'])
  - allows operator to see packets arriving at the switch with a particular src mac
  - 1: we only want to see first packet
- self.query.register.callback(learn_new_mac)
* Dynamic Policies in Pyretic
Dynamic policies can change and are represented by a timeseries of static policies

current value: self.policy

An idiom in pyretic:
1. set default policy
2. register callback that updates policy

Summary:
- network policy as a function
- predicates on packets
  - and, or, not
- virtual packet headers
- policy composition

