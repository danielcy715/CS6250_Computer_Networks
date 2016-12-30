* Need for Network Security
Why do we need network security?

Attacks:
- routing: BGP is susceptible to attacks
  - AS advertises a false prefix: "route hijacks"
- naming: DNS
  - reflection: way of generating large amounts of traffic aimed at a victim (DDOS)
  - phishing: attacker exploits domain name system to trick user to reveal information
* Internet is Insecure
- designed for simplicity. security was not in mind when originally designed
- "on by default". When a host is connected to the internet, it is by default reachable by other hosts
- hosts are insecure
- attacks can look like "normal" traffic
- federated design obstructs cooperation for diagnosis or mitigation
  - internet is run by tens of thousands independently operated networks
* Resource Exhaustion Attacks
Packet Switching: Resource Exhaustion

- In a packet switched network, resources are not reserved, and packets are self-contained; every packet travels independently to the host. A link may be shared by multiple senders by statistical multiplexing. A large number of senders can overload a link. Circuit-switched networks don't have this problem because every connection has its own dedicated resources. 
- Packet-switched networks are vulnerable to resource exhaustion attacks

Components of Security
- availability: ability to use a resource
- confidentiality: concealing information
- authenticity: assures origin of information
- integrity: prevent unauthorized changes

threat: potential violation of any one of the above (potential violation)
attack: action that results in the violation of one of the above
* Confidentiality and Authenticity Attacks
Confidentiality:
- Eavesdropping
  - attacker "Eve" gains access to info being sent from Alice to Bob
  - packet sniffers (wireshark, tcpdump) set a NIC to promiscuous mode
  - if Alice, Bob, and Eve are on the same LAN where packets are being flooded (e.g. hub), Eve can hear those packets if wireshark is in promiscuous mode
  - some info can be useful:
    - DNS lookups: find out what websites you're visiting
    - packet headers: type of applications you're using
    - payloads: attackers can see content, private messages

Authenticity:
  - packets can be modified and reinjected
  - Eve can impersonate Alice (Man in the Middle Attack)
* Network Attack Quiz
A DOS attack is an attack on which property?
- Availability // YES
- confidentiality
- authenticity
- integrity
* Negative Impacts of Attacks
- theft of confidential info
- unauthorized use of resources
- spread of false info
- disruption of services
* Routing Security
- we'll focus on interdomain routing (BGP) and control plane authentication
- goal of control plane security is to determine the veracity of routing advertisements
  - session authentication: protects point to point communic. between routers
  - path: protects AS path
  - origin: protects origin AS, guaranteeing that the origin AS is the owner of an advertised prefix
- we also have to worry about data plane security - ensuring packets is traveling on the intended route to the destination
* BGP Routing Security Quiz
- A route hijack is an example of an attack on which of the following:
  - session
  - path
  - origin // YES
* Route Attacks
How?
- route is misconfigured
- router is compromised, and attacker can misconfigure router
- unscrupulous ISPs

Types of attacks
- misconfigure router, tamper with mgmt sftwr that changes configuration
- tamper w/ software
- tamper w/ routing data

Most common attack: hijack attack
* Route Hijacking
Why Hijacks Matter

Suppose you want to visit a website
- issue DNS query
- authoritative DNS server is located in distant network
- DNS uses a hierarchy to direct query to the authoritative name server
- an attacker can run a rogue DNS server, intercept the DNS query, return a false IP address. The rogue DNS server can use BGP to advertise a route for the IP prefix that contains that authoritative DNS server. DNS queries that were going to the legitimate DNS server can be redirected to the rogue server.
- MITM as a result
  - traffic ultimately reaches the correct destination, but the rogue server is in the middle of the path now
  - but how to disrupt the path of the traffic from the host to the legitimate DNS nameserver, while keeping the path between the MITM server and the legitimate DNS nameserver intact?
* Route Hijacking (cont)
Suppose AS 200 originates a prefix. Suppose AS 100 seeks to be a MITM. If the original prefix is p, the MITM can also advertises the same prefix p, but we want to make sure that we keep a path between 100 and 200. We want to make sure neither the ASes in between accept the hijacked route. We can do this by AS path poisoning. 

If AS 100 advertises a route that includes the ASes in between (AS 10 and 20) in the AS path, both 10 and 20 will drop the announcement because they think they've already heard the announcement and don't want to form a loop. Other ASes in the internet not on the path will switch, and now all traffic from other ASes en route to AS 200 will go to AS 100.

A traceroute will look weird, but the attacker can hide its presence. Remember traceroute consists of ICMP time exceeded messages that result when a packet reaches a TTL of 0. Each router will decrement along the path, but if the attacker router doesn't decrement the TTL, then no time exceeded message will be generated by routers in AS 100, so the traceroute won't show AS 100. 
* AS Session Authentication
Session authentication attempts to ensure that BGP routing messages sent between routers between ASes are authentic. These sessions are TCP sessions, so we can use TCP's MD5 authentication option. 

Every message contains the message and the hashed message with a shared secret key. This key distribution is manual; the operator of both ASes must agree on the key out of band (e.g. a phone call). 

Another way is to have AS 1 transmit packets with a TTL of 255, and have the receiving AS to drop packets with a TTL < 254. Because BGP sessions are between ASes one hop away, it's impossible for a remote attacker to get around. This is called the TTL Hack defense. 
* Origin and Path Authentication
There is a propose to secure BGP to add signatures to route advertisements (BGPSEC)
- origin attestation: certificate binding prefix to owner (address attestation)
  - cert must be signed by trusted party, like a routing registry or the organization that allocated the prefix
- path attestation: signatures along AS path
* Autonomous System Path Attestation
Suppose we have 3 ASes. Each AS has a public-private key pair. An AS can sign a message or route with its private key, and other ASes can check that signature with that AS's public key. 

Suppose AS1 advertises a route for prefix p. The BGP message will look like:
- "P", 1 (prefix, AS path)
- {2 1} k1 (path attestation, signed by AS1's private key)

When AS2 readvertises the route to AS3:
- "P", 2 1
- {3 2 1} k2
- {2 1} k1 (AS1's path attestation)

A recipient can verify every step of the AS path. AS3 can use the first path attestation to ensure that the path from 2 to 1 includes just AS 2 and 1. 

The reason the recipient AS is included in the path attestation (the "3" part of {3 2 1} k2 when AS2 advertises its route to AS3, for example), is to ensure that an attacker can't just insert itself into the path. For example, suppose that the recipient is not included in the path attestation. Then when AS2 advertises the route to AS3, we'll have the following:
- "P", 2 1
- {2 1} k2
- {1} k1

An attacker can steal the attestations above and advertise the following route:
- "P", 4 1
- {1} k1

This path attestation can prevent:
- hijacks
- shortening
- modification of the AS path

It cannot prevent:
- If an AS fails to advertise a route
- replay attacks (premature readvertisement of a withdrawn route)
- no way to guarantee that the traffic travels along the AS path
* DNS Security
Review of architecture:
- stub resolver that issues query to a caching resolver
  - we can have a MITM that can forge a response to this query
- query goes to cache resolver
  - if the query goes further, like to an authoritative name server, an attacker could send a reply back to the cache resolver before a real reply comes back to poison or corrupt the cache with bogus DNS records (cache poisoning)
- masters and slaves can be spoofed
- zone files can be corrupted
- updates to the dynamic update system can also be spoofed
* Why is DNS Vulnerable?
- Resolvers trust responses
  - sometimes these responses can be forged
  - when a resolver sends a query, a race condition is generated, where if an attacker responds before the resolver receives a legitimate response, the resolver will believe that bogus response
- responses can contain info unrelated to the query
- there is no authentication
- DNS is connectionless (UDP)
  - a resolver does not have a way to map the response to a query, other than a query ID, which can be forged
* DNS Cache Poisoning
- Suppose a stub resolve issues a query, A google.com?, to a recursive resolver. The recursive resolver sends the query to the start of authority for that domain.
- normally, the SOA will respond with the correct IP address
- an attacker can respond to the recursive resolver's request with many replies with multiple IDs. One of these will match the ID of the resolver's query.
- if this bogus response arrives before the recursive resolver receives a legitimate reply from the SOA, it will not only accept the bogus response, but cache it
- the recursive resolver will continue to forward this response every time it receives a query for that domain name until the entry expires from the cache

Defenses:
- query ID (can be guessed)
- randomize the ID, making it tougher to guess, but it's only 16 bits
- the fact that an attacker has to race against to SOA to provide the recursive resolver with a reply
  - if the attacker loses, it has to wait until the recursive resolver sends another request to the SOA
    - but the attacker can generate its own queries, which will be forwarded by the recursive resolver to the SOA, starting a new race
    - an attacker can even reply with not just an A record, but with an NS record, thus owning the entire zone (Kaminsky attack)
* DNS Cache Poisoning Defense
- ID + randomization
- source port randomization by the resolver, adding another 16 bits of entropy
  - resource intensive
  - NAT could derandomize the port
- 0x20 encoding
  - DNS is case insensitive
  - the 0x20th bit that controls whether a letter is capitalized can be used to introduce entropy
  - only resolver and authoriative server know the appropriate combo of upper and lowercase letters of a domain name in a request
* DNS Amplification Attack
- Exploits asymmetry in size between DNS queries and responses
- attacker will send a query for a domain that might be only 60 bytes
- the attacker will indicate the src as the victim IP address
- the resolver will send a reply to the victim IP, which is 2x larger (this is where 'amplification' comes from)
- adding other attackers will multiply the amount of data sent to the victim, and we get a DOS

Defenses:
- prevent IP spoofing using filtering rules
- disable ability of DNS resolvers to resolve queries from arbitrary parts of the internet
* DNSSEC DNS Security
DNSSEC adds authentication to DNS responses by adding signatures to the responses:
- when a stub resolver sends a request to the resolver, the resolver forwards the request to the root server
- root server replies with the IP and public key of the .com server. This reply is signed, which the resolver can check if it knows the root server's pub key
- the resolver can use the .com public key sent by the root server to check .com's reply, which includes the IP and public key of the google.com server
- the resolver can then use google.com public key sent by the .com server to check google.com's reply, which includes the A record for the request
