* Congestion Control
Goal: "fill the pipe without overflowing it". The best way of achieving this is to "watch the sink", and adjust the flow if it starts getting full.
* Congestion
Let's suppose that we have the following network topology:

A: C, 10 Mbps
B: C, 100 Mbps
C: D, 1.5 Mbps

Hosts A and B are competing for resources. The sources are unaware of each other and the state of the network. This results in lost packets and long delays, and can result in throughput less than the bottleneck link, or *congestion collapse*
* Congestion Collapse
In *congestion collapse*, an increase in load results in a decrease of useful work. 

Up to a certain point, increasing the load results in an increase of work. Then the network reaches a saturation point, and then the increase in load results in a decrease of work. This is the point of congestion collapse.

Possible causes of congestion collapse:
- *spurious retransmission*: When senders don't receive acknowledgement for the packets they send, they'll retransmit, resulting in many copies of the same packets that are outstanding in the network
  - solution: timers and TCP congestion control
- *undelivered packets*: packets are dropped
  - apply congestion control to all traffic
* Goals of Congestion Control
- Use network resources efficiently
- Preserve fair allocation of resources
- Avoid congestion collapse
* Two Approaches to Congestion Control
In *end-to-end* congestion control, the network doesn't give feedback to senders to slow down their rates. Congestion is inferred by loss and delay. This is what occurs in TCP congestion control

In *network-assisted* congestion control, routers provide feedback, by setting a bit, or setting an explicit rate senders should send at
* TCP Congestion Control
Senders increase their rate until they see packet drops. This occurs when senders send at a rate faster than a router can drain their buffer. TCP interprets packet loss as congestion and slows down. However, packets can be dropped because packets are corrupted. Senders periodically check whether more bandwidth has become available. 

Congestion control has two parts:
1. Increase algorithm: sender must test network to determine whether network can sustain higher sending rate
3. Decrease algorithms: senders react to congestion to achieve optimal loss rates and delays in send rates
* Two Approaches to Adjusting Rates
Window-based (common): A sender can only have a certain number of packets outstanding, or in flight, and the sender uses acknowledgements from the receiver to clock the retransmission of new data. Suppose the window of the sender is 4 packets. If there are 4 packets outstanding, the sender can't send any more packets until it has received an ACK. Once it receives an ACK, it can send another packet. If a sender wants to increase the nubmer of packets it's sending, it must increase its window size. A sender might want to increase its window size when it receives an ACK. In TCP, the sender increases its window size every time it receives an ACK. This is called *additive increase*. If a packet is not acknowledged, the window decreases by half. This is called *multiplicative decrease*. Window-based congestion control is called AIMD. 

Rate-based: The sender monitors the loss rate, and uses timer to modulate the transmission rate. 
* Window-Based Congestion Control Quiz
- RTT: 100 ms
- Packet: 1 KB
- Window size: 10 packets

What is the sending rate in kilobits per sec? 

10 packets * 1 KB = 10 KB being transmitted. 
 
10 KB = 80 Kb

80 Kb / 100 ms = 800 Kb/s (tranmission time = Round trip time)
* Fairness and Efficiency in Congestion Control
The two goals of congestion control are fairness and efficiency. 

- *Fairness*: every sender gets their fair share of network resources
- *Efficiency*: network resources are used well

Fairness and efficiency can be represented in terms of a *phase plot*. Fairness can be represented by the line x1 = x2, x1 and x2 being users. Efficiency can be represented by the line x1 + x2 = c, c = capacity. Anywhere to the left of this line is underutilization, and anywhere to the right is overutilization. The optimal rate is where these two lines converge. 
* AIMD
AIMD is:
- Distributed (all senders act independently), fair, efficient

The resulting behavior caused by AIMD looks like a sawtooth (*TCP sawtooth*), with time on the x axis and rate on the y axis. 

The time between the lowest sending rate and highest sending rate is W_m / 2 + 1 round trips because:
#+BEGIN_QUOTE
...when you halve the sending rate, you are decreasing the window size by "wm/2". Then, as you gradually ramp up the sending rate 1 packet at a time, it will thus take "wm/2" packets to reach the peak of the sawtooth again. Finally, you need to send 1 more packet and fail to receive its ACK before you halve the window size once more. Thus, there will be "wm/2+1" packets transmitted between the two lowest points of the sawtooth.
#+END_QUOTE

Number of packets lost is the area within one of the triangles of the sawtooth (remember 1/2bh):
\begin{equation}
p = \frac{1}{2} * (\frac{W_m}{2})(\frac{W_m}{2} + 1) \approx \frac{W_m^2}{8}
\end{equation}

Why the area under the triangle? 
#+BEGIN_QUOTE 
In general the area under a rate curve like this one represents the amount of packets transmitted. For example, if you imagine a simple case of a sender transmitting at a constant rate of 10 packets/s. The graph would be a horizontal line. If I wanted to know how many packets were sent in 4 seconds, I would find the area of the rectangle beneath that horizontal line by multiplying the height of the rectangle (10 packets/s) times the width of the rectangle (4 seconds), yielding 40 packets. This behavior can be generalized even if the line is not horizontal - the area under that curve is the total number of packets sent.
#+END_QUOTE

Throughput is the average rate, or:
\begin{equation}
\lambda = \frac{3}{4} * \frac{W_m}{RTT}
\end{equation}

Loss rate = 1/p

Number of packets lost per second (solve for W_m):
\begin{equation}
\frac{1}{p} = \frac{8}{W_m^2}
\end{equation}
\begin{equation}
W_m^2 = \frac{8}{p}
\end{equation}
\begin{equation}
W_m = \frac{\sqrt{8}}{p}
\end{equation}
\begin{equation}
W_m = \frac{1}{\sqrt{\frac{1}{8}} * \sqrt{p}}
\end{equation}
\begin{equation}
W_m = \frac{1}{k * \sqrt{p}}
\end{equation}

If we plug this value into W_m in the throuhput equation, we get:
\begin{equation}
\lambda \approx \frac{k}{RTT * \sqrt{p}}
\end{equation}

Throughput is indirectly proportional to RTT and the square root of p
* Data Centers and TCP Incast
Typically in data centers, we have racks of servers that are connected to each other through switches, and switches are connected by some higher network device. As a result, we have the following consequences:
- High "fan-in", or a large number of inputs for a device, like a switch
- high bandwidth, low latency
- lots of parallel requests each w/ small amount of data

There are some constraints:
- small switch buffers

The throuhput collapse that occurs as a result is called the *TCP incast problem*. Incast is reduction in application throughput that results when servers using TCP all simultaneous request data. This results in underutilization of capacity in many-to-one communication networks. 

The filling up of switch buffers result in *bursty retransmissions* that overfill the switch buffers. Bursty retransmissions are caused by TCP timeouts that could last hundreds of milliseconds. The RTT in a datacenter network is usually less than a millisecond. Because RTT is so much smaller than a timeout, senders have to wait a long time because of the timeout before they can retransmit. Application throughput can be reduced by as much as 90% as a result of link idle time. 
* Barrier Synchronization and Idle Time
A common request pattern in network datacenters is called *barrier synchronization*, where a client might have many parallel threads, and no progress can't be made until all threads are satisfied. If one of the the threads is dropped, TCP will timeout. The link is idle for a long time while that thread is timed out. This causes severe packet loss and inducing throughput collapse. 

Possible solutions are:
- microsecond granularity retransmission
- ACKs for every other packet
* Multimedia and Streaming
Overview:
- Digital audio and video data
- multimedia applications
- multimedia transfers over best-effort networks
- quality of service
* Challenges
- Large volume of data: many samples (picture/sound) per second
- Data volume varies over time
- Users have low tolerance for delay variation
- Users have low tolerance for delay period

Some loss IS acceptable
* Digitizing Audio and Video
Suppose we have an analog signal that we would like to digitize, or turn into bits. We could sample the signal at fixed intervals and represent the amplitude with a given number of bits. Suppose we want to represent amplitude on a scale from 0 to 15. We could quantize the signal with 4 bits (2^4 = 16). 
* Digitizing Audio and Video Quiz 1
Suppose for digitize speech, we take 8000 samples/sec, and there are 8 bits/sample. What is the sampling rate in kb/s?

8 b/samp * 8000 samp/s = 64000 b/s = 64 kb/s
* Video Compression
Video is just a sequence of images, and each image is compressed through spatial redundancy - there are some details in each image that humans tend to miss. Compression also occurs /across/ images through temporal redundancy - there might be very little difference between two frames.

Derived frames, or P frames, are derived in terms of the reference/anchor frame, or I frame, plus some motion vectors. A common compressoin format for videos on the internet is MPEG. 
* Streaming Video
A server stores the audio/video files. Clients request the files and plays the data as it's being downloaded. The files need to be played at the right time. This can be done by dividing the video into chunks, and labeling each segment with a timestamp indicating the time when the segment should be played. The data must arrive quickly enough. The solution is a *playout buffer*, where the client stores data as it arrives, and plays the data to the user in a smooth fashion. 
* Playout Delay
We want to avoid any delays in receiving packets. If we wait at the beginning before playout, we can receive packets in a more orderly fashion to allow for smoother playout. A client can't tolerate much variance in the rate of receiving packets if the playout delay is not long enough. Loss does not disrupt playback, but retransmission does. 
* Streaming Quiz
Which pathologies can streaming audio/video tolerate?
- Loss  // YES, results in slight loss in audio/video quality
- Delay // YES, at the beginning
- Variation in delay // Might cause starvation of buffer
* TCP is Not a Good Fit
TCP is not a good fit for audio/video streaming. 
- TCP retransmits lost packets, but retransmission is not always useful
- TCP might reduce sending rate when packets are lost
- Protocol overhead: header of 20 bytes for every packet, and sending ACKs for every packet is not necessary

Alternative: UDP
- No retransmission
- No sending rate adaptation
- Smaller header

Higher layers must solve these problems left by UDP, like when to retransmit, how to encapsulate, how to adapt the quality, etc. Still needs to be fair to other TCP senders sharing the link. 
* More Streaming
- Youtube: uploaded videos are converted to Flash over HTTP/TCP. Simple at the expense of quality.
  - Requests are redirected to content distribution networks
  - Client sends HTTP GET request to CDN server, CDN server responds with the stream
- VoIP: audio is digitized and sent over the internet. Digitization is performed by some phone adapter, like Vonage.
- Skype: based on P2P tech where individual users route traffic through one another
* Skype
- Has central login
- P2P to exchange data
- Compression: 67 bytes/pkt, 140 pps, 40 kbps each direction, avoiding POPs
- Encryption

Factors that could degrade voice quality:
- Delays
- Congestion
- Disruption

Quality of Service can be done through reservations, or marking some streams as higher quality than others
* Marking and Policing
Apps compete for bandwidth. Suppose we want audio packets to receive priority over file transfer packets. We mark the audio packets as they arrive at the routers as higher priority. VoIP are put in high priority queues. 

Alternative: 
- Fixed bandwidth for application
  - Problem: inefficiency if an application doesn't fully utilized its allocated bandwidth
- Weighted fair queueing: high priority packets are served more often
- Admission control: Application declares its needs in advance, and the network can block an application if it doesn't satisfy needs
* QoS Quiz
Commonly used QoS for streaming audio/video?
- Marking packets
- Scheduling
- Admission control
- Fixed allocations
* Parking Lot Problem
Talks about the project
