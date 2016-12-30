* Traffic Classification and Shaping
- Ways to classify traffic
- Traffic shaping approaches
  - Leaky bucket
  - (r, t)
  - Token bucket
  - Composite
- Motivation:
  - resource control
  - ensure flows don't exceed rate
* Source Classification
- Data: bursty, periodic, or regular
- Audio: continuous, periodic
- Video: continuous, bursty (due to the nature of compression), periodic
- Two classes of traffic:
  - Constant bit rate source (CBR source)
    - traffic arrives at regular intervals and packets are the same size
    - ex. audio
    - shaped according to peak rate
  - Variable bit rate source (VBR source)
    - ex. video, data
    - shaped according to average rate
* Leaky Bucket Traffic Shaping
- Each flow has its own bucket of size \beta and the bucket drains at a rate of \rho. \rho controls the average rate, since you can always increase or decrease the rate at which the bucket is filled, but the fill rate can't exceed rate \rho. \beta controls the maximum burst size that a sender can send for a flow. The sender might be able to send at a faster rate as long as the total size of the burst doesn't exceed \beta. 

For example, for an audio application, the size of the bucket is 16 KB, and packets are set at 1 KB. This would mean that we could have a burst rate of 16 packets in the bucket. However, the drain rate of 8 packets per second ensures that we have an average rate of 8 KB per second. A larger bucket size leads to a larger burst rate. A larger \rho can accomodate a faster packet rate
* (r, T) Traffic Shaping
Traffic is divided into T-bit frames. A flow can inject <= r bits in any T-bit frame. A flow that obeys this rule is said to have *(r, T) smooth* traffic shaping. 

Variable flows have to request data rates that are equal to the peak rates, which is wasteful. 

(r, T) traffic shaping is more relaxed than leaky bucket traffic shaping because instead of being restricted by the number of packets that a flow can send every second, it's restricted by the number of bits that a flow can send every second. 

If a flow exceeds rate, assign the excess packets of that flow lower priority. Priorities can be assigned at the sender or at the network (policing, done by routers)
* Shaping Bursty Traffic Patterns
Sometimes we might want to shape bursty traffic patterns to allow for bursts but ensure that the average rate is not exceeded. For this, we could use a token bucket. \rho is the rate at which tokens are placed in the bucket, while \beta is again the size of the bucket. Traffic may arrive at an average rate of \lambda_avg, and peak rate of \lambda_peak. Traffic can be sent by the regulator as long as there are tokens in the bucket. 

Suppose we want to send a packet of size b that's less than \beta.
- If the bucket is full, then packet is sent, and we remove b tokens from the bucket
- If the bucket is empty, then the packet must wait until b tokens arrive
- If the bucket is partially full
  - If the number of tokens exceeds b, then the packet is sent immediate
  - Else, wait until there are at least b tokens
* Token Bucket vs. Leaky Bucket
| Token                                                      | Leaky                                                 |
|------------------------------------------------------------+-------------------------------------------------------|
| Permits burstiness but bounds it by the rate \rho          | Smooths bursty traffic                                |
| at any time T, rate < \beta * T * \rho (T = time interval) |                                                       |
| long term rate will always be < \rho                       |                                                       |
| no discard or priority                                     | priority policies for flows that exceed soothing rate |
| policing is difficult                                      |                                                       |

Policing for token bucket shaping is difficult because 
#+BEGIN_QUOTE  
Since the rate of tokens entering the bucket is ρ, which is the limiter (traffic only flows when there is equivalent number of tokens available), the long term rate will be less than ρ.
Now consider the scenario when there are already β tokens in the token bucket at the beginning of the flow.
If there is a burst of β + ρ packets in the flow in the next second, it will be allowed as there would be that many number of tokens at the end of that second. Thus rate is β + 1 * ρ, which exceeds ρ and thus is difficult to police i.e. keep <= ρ
#+END_QUOTE
* Policing with Token Buckets
Done with a composite shaper. Traffic is first regulated by the token bucket, and then passes through the leaky bucket. This way, the leaky bucket can regulate any burst traffic that might exceed the maximum rate of the token bucket. 
* Token Bucket Shaper Quiz
\beta = 100 KB
\rho = 10 packets/sec
packet size = 1 KB
T = 1 sec 

Remember that max rate = \beta + T * \rho
Max rate? 
100 KB + 1 s * 10 packets/sec = 100 KB + 10 KB = 110 KB = 880 Kb
* Power Boost
Traffic shaping mech first deployed in 2006 by Comcast. 

Allows subscriber to send at a higher rate for a brief period of time. It gives spare capacity to users who do not put sustained loads on the network. 

Two types of power boost:

If the burst rate is set to not exceed a certain rate, then the policy is a *capped power boost*. Otherwise it's *uncapped*. 
* Calculating Powerboost
Sending rate r > R_{sustained}

Power boost bucket size: \beta

How long can a sender send at the rate r that exceeds R_sustained? What is the value of d?
(Get the area underneath the power boost rectangle):
\begin{equation}
\beta = d * (r - R_{sust})
\end{equation}
Solve for d:
\begin{equation}
d = \frac{\beta}{(r - R_{sust})}
\end{equation}
* Examples of Powerboost
BISmark: Different homes have different shaping profiles. Some are steady and some are erratic. 
* Effects on Latency
Powerboost has an effect on latency. Latency is measured in RTT. Latency and loss increases at a higher rate. This is because the link cannot support the higher rate. If a sender can only send at R_{sustained} but bursts at R, then buffers may fill up and introduce delays in the network, since packets are being buffered instead of dropped. To solve this problem, the sender could shape its rate so that it never exceeds R_{sust}. 
* Buffer Bloat
The delay experienced by packets that are queued as a result of a burst rate exceeding the sustained rate is equal to the amount of data in the buffer divided by R_{sust}:

Delay = data-in-buffer / R_{sust}

This can ruin performance for critical applications. Buffers appear in home routers, home APs, hosts, switches. 
* Buffer Bloat Example
As packets fill up the buffer, the senders' sending rates are still increasing because no packet loss is detected. 

Solutions:
- as mentioned before, we can make sure that the burst rate never exceeds R_{sust} using traffic shaping
* Network Measurement
How to "see" what traffic is being sent ont he network?

- Passive measurement: collection of packets, flow stats that are already on the network
- Active measurement: inject additional traffic to measure various characteristics
  - ex. actively sent traffic to measure speeds of downloads
  - ping (measure delay), traceroute (measure path between two hosts)
* Why Measure?
- Billing:
  - We might want to charge customer based on how much traffic is sent. We want to passively measure this.
    - 95th percentile billing: customer pays for *committed information rate*. Throughput is measured every 5 min. Customer is billed on 95th percentile of inbound traffic.
- Security:
  - Network operators may want to know what kind of traffic is happening on the network. They'll watch out for botnets or DOS
* How to Measure (Passively)?
- SNMP (Simiple Network Management Protocol)
  - Many network devices provide a *management information base* (MIB), that can be polled for information
  - We can poll an interface for the number of bytes and packets sent
  - advantage: ubiquitous
  - disadvantage: coarse (we can't ask specific questions like how much traffic is sent by a particular host)
- packet monitoring
- flow monitoring
* Packet Monitoring
- Full packet contents or at least the headers
  - example: tcpdump, ethereal, wireshark
  - sometimes performed with hardware that's mounted in servers
    - optical link can be split so that one path sends the traffic, and the other sends the traffic to the monitoring system
- advantage: lots of detail
- disadvantage: high overhead
- Flow Monitoring provides a good middle ground
* Flow Monitoring
- monitors record statistics per flow
- A flow consists of packets that share common:
  - src and dst IP
  - src and dst port
  - protocol type
  - TOS byte
  - interface
  - time (packets grouped together in a period of time)
- flow can also contain next-hop IP, and src/dst AS
- advantage: less overhead
- disadvantage: more coarse, no packet/payloads
- Sampling: flow stats based on samples of packets
* Passive Traffic Quiz
| Packet | Flow |                    |
|--------+------+--------------------|
| x      |      | Timing information |
| x      |      | Packet headers     |
| x      | x    | Number of bytes in each flow |
