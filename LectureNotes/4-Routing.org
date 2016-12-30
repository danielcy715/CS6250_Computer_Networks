* Internet Routing
The internet is made up of connected independently operated *automonoums systems*. Traffic traverses across multiple ASes before getting to their destination. This happens via two types of routing: *intradomain routing* (routing within an AS) and *interdomain routing* (routing between ASes)
* Intra-AS Topology
An intradomain network is comprised of *nodes* or *points of presence* (POPs), and *edges* that connect them. Edges usually parallel major transportation routes. *Routing* is the process through which nodes discover other nodes and calculate which nodes to forward traffic to. There are two types of intradomain routing: *distance vector* and *link state*
* Distance Vector Routing
Each node sends "vectors" to their neighbors, or basically copies of their routing table. Routers compute costs to their destination based on shortest available path. The *Bellman-Ford* algorithm is one type of distance vector algorithm, described by the following equation: d_x(y) = min_v(c(x,v) + d_v(y)) 
* Example of Distance Vector Routing
(Just work out a sample problem to get the hang of the mechanics)

One problem of distance vector routing with the Bellman-Ford algorithm is the *count to infinity* problem, where nodes are slow to get the correct shortest distance to a node when the cost between nodes suddenly changes. [[https://youtu.be/ylzAefKENXY?t%3D11m48s][Here]] is a good explanation of the count to infinity problem.

* Routing Information Protocol
RIP is an example of a distance vector routing protocol created in 1982, where edges have unit cost, and inifinity (for the count-to-infinity problem) is 16. The table refreshes every 30 seconnds or when updates occur, and the vector is sent to all neighbors except for the one that caused the update ("*split horizon rule*"). Timeout occurs in 180 seconds (time for 6 hops). Convergence occurs within minutes (considered slow) when a disturbance occurs.
* Link State Routing
Most prevalent. Nodes distribute a network map, and then each node performs shortest path (SPF) computation between itself and all other nodes. Link state routing utilizes Dijkstra's algorithm for finding the shortest path: D(v) = min(c(v,w) + D(w), D(v)). Two common link-state routing protocols are Open Shortest Paths First (OSPF) and Intermediate System-Intermediate System (IS-IS). IS-IS is more commonly used. The problem with link state routing is scale. Complexity grows at n^3, where n is the number of nodes
* Coping with Scale: Hierarchy
One way to cope with scale is to introduce hierarchy. In OSPF, this is done with areas, and in IS-IS, this is done with levels. Routers can be divided into areas. In OSPF, the backbone area is called area 0, and areas not in area 0 have area 0 routers. These routers perform SPF, and routers in other areas independently perform SPF. 
* Interdomain Routing
'Interdomain routing' refers to routing between ASes. Each AS border router broadcasts reachability to a destination using *route advertisements* via *BGP*, or the border gateway protocol. A route advertisement contains many attributes, the most important of which are the following:
- destination IP
- the next hop IP: The IP address of the router that the first router must send traffic to, typically the first router of the next AS. They are usually on the same subnet
- the AS path: sequence of AS numbers that describe the route to the destination AS. The last AS number is the *origin AS*, or the originator of the route advertisement

The previously described advertisement that goes on between routers that lie on the border of ASes is called *external BGP* (eBGP). If an internal router inside an AS wants routing information about external ASes, it would use *internal BGP* (iBGP)
* IGP vs iBGP
- IGP: routes inside an AS to internal destinations
- iBGP: routes inside an AS to external destinations

Suppose there are two ASes, A and B. If a router inside AS A wants to communicate with a router inside AS B, AS A would learn the route to AS B by eGBP, where the next hop router would be the border router of AS B. The internal AS A router would learn the route to B via iBGP, where the next hop router would be the AS A border router. The router inside AS A would use IGP to learn the route to the AS A border router. 
* BGP Route Selection
Sometimes a router is presented with multiple routes to the destination router. The process of choosing the best route is called the *route selection process*.
* BGP Route Selection Process
1. Prefer the higher "local preference" value
   1. This value is a number chosen to indicate that a particular route should be preferred
   2. This attribute is local and does not get transmitted between ASes
2. If the local preference value is equal, prefer route with shortest AS path length
   1. A path might be better if it traverses fewer ASes
3. Multi-exit descriminator
   1. AS can specify which exit point is preferred if there are multiple exit points
   2. This only applies to routes from the same AS
   3. Lower values are preferred
4. Prefer the route that results in the shortest IGP path
   1. routers inside an AS will prefer a BGP route with the shortest IGP next hop
   2. This results in "hot potato" routing, where an AS will pass traffic to a neighboring AS via a path that traverses little of its own network as possible
5. Tiebreak
   1. arbitrary, or most stable, lowest router ID
* Local Preference
The default local pref val is 100. If the operator prefers the route via router 2, he would set the local pref val of that route to 110 on that router. In this way, an operator can adjust local pref values on /incoming routes/ to control /outbound traffic/. The route via router 2 would be designated as the primary route, and router 3 would then be designated as the backup route. 

Local pref is used to control outbound traffic, but sometimes AS can attach a BGP community to a route to effect how neighboring ASes sets local pref. A community is a tag on a route. If AS 4 wants to control its /incoming traffic/, it would tag the route via 2 as backup and the route via 3 as primary. When AS 2 sees this tag, it will modify its /outgoing traffic/ by settings its local preference for AS 3 higher than that of AS 4. 2 sends traffic to 3, and 3 sends this traffic to 4. This arrangement requires prior agreement. 
* Multiple Exit Descriminator
Suppose there are two ASes, and SF and NYC lie between both of them. Suppose AS1 would prefer that traffic goes through NYC instead of SF. The default behavior is for routers to send traffic through routes with the shortest IGP paths, resulting in hot potato routing. Some routers in AS2 will pass traffic via SF, and some routers in AS2 will pass traffic via NYC. But AS1 can override this behavior by setting the MED value of the route coming in from NYC as lower than the MED value of the route coming in from SF. So all routers in AS2 will send traffic so that it exits AS2 via NYC. 
* Interdomain Routing Business Models
Interdomain routing is all about routing money. There are two different kinds of business relationships:
1. Customer-provider relationship: money flows from customer to provider regardless of traffic flow direction
2. Peering relationship: an AS can exchange traffic with another AS free of charge. Also known as settlement-free

A provider will always prefer the route through its customer since it gets money out of it. A provider wil prefer the peering route second because it's free. The least preferred route is through a provider since it has to pay money. 

Customer > peer > provider

An AS also has to consider the filtering/export decisions. Given an AS learns a route from its neighbor, to whom should it advertise that route. A provider  will readvertise a route through a customer to everyone because that would mean more money for the provider. A route learned from a provider would only be advertised to customers. Same with routes learned from peers. 
* Interdomain Routing Can Oscillate
Sometimes an AS will break off a route in order to use a more favored path. However, this would conflict with another AS's favored path, so that AS must sever this path and pick another. This can continue ad infinitum. If the normal business relationships were followed, safety is guaranteed, but because business relationships are dynamic, interdomain routing can oscillate. 
