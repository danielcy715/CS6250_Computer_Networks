* The Web and Caching
- Protocol: HTTP - application protocol that transfers web content
  - Client (browser) makes requests, the server responds with the web content
    - the server does not keep track of past requests, making it stateless
  - layered over byte stream protocol (almost always TCP)
* HTTP Requests
- Request line
  - Method
    - GET: return content associated with URL, can also send data to server
    - POST: sends data to server
    - HEAD: return headers but not response
  - URL
  - Version number
- Headers
  - Referer: URL that caused the page to be requested
  - User Agent: client software used to fetch the page
* Example HTTP Request
- Accept: */* - means that the client is willing to accept any content type
- Host: where the request is being made to, useful for when a single IP address is serving multiple websites
* HTTP Response
- Status line:
  - HTTP versio
  - Response code
    - 100: informational
    - 200: success
      - 200: ok
    - 300: redirection
      - 301: moved permanently
    - 400: errors
      - 404 not found
    - 500: server errors
- Location: redirection
- Server: server software
- Allow: allowed methods
- Content-encoding: describes how content is encoded
- Content-length: content-length
- Expires: how long the content can be cached
- Last-modified: when the content was last modified
* Example Response
* Early HTTP (v 0.9/1.0)
- one request/response per TCP connection
  - + simple to implement
  - - TCP connection for every request
    - 3-way handshake
    - slow start
    - servers have to force connections to stay in TIME_WAIT state, using up resources
    - solution
      - persistent connections
* Persistent Connections
- Multiple request/response on a single TCP connection
  - deliminiters indicate the ends of requests
  - content-length
- can be combined with pipelining
  - client sends request as soon as it encounters a referenced object
  - default behavior in 1.1
* Caching
- Clients can cache documents
  - in browser (local machine)
  - in network (local ISP)
    - Suppose the origin of the content is far away from the client
      - remember that the throughput is inversely proportional to RTT. The further away the content is, the slower the webpage will load
      - If the client can fetch from the local cache, performance improves
    - Improves performance when multiple clients request the same page
      - saves costs since the ISP doesn't have to pass the same page over and over again
- To ensure that clients are getting the most recent content:
  - Content can expire
  - Cache checks with the origin server for a 304, or not modified
- Clients can be redirected to a cache through several ways
  - browser configs
  - origin server can direct the browser to the cache
    - special reply to a DNS request
* CDN
Content Distribution Networks

What is a CDN?
- overlay network of web caches
  - deliver content to client from optimal location
- made of geographically disparate servers
- some are owned by content providers, or network/ISPs
* Challenges in Running a CDN
- Goal: Replicate content on many servers
  - How?
  - Where?
  - How to find?
  - How to choose server replica? "server selection"
  - How to direct clients? "content routing"
* Server Selection
- Which server to direct client to?
  - lowest load
  - lowest latency <- highest priority
  - any "alive" server
* Content Routing
- How to direct clients to a server?
- Routing (e.g. anycast)
  - simple
  - coarse
  - provides providers with little control over which server to redirect to
- Application-based (HTTP redirect)
  - requires client to go to the origin server first to get the redirect (delays)
- Naming-based (DNS) (most common)
  - client looks up domain name
  - response contains IP address of nearby cache
  - fine grained control and fast
* Naming Based Redirection
- We don't get an A name immediately, but we get a canonical name (CNAME)
- The returned CNAME is the same whether symantec.com is queried from Boston or NYC, but looking up the CNAME gives different IP addresses that are more local to their respective locations
* CDNs and ISPs
- They have symbiotic relationships
- CDNs peer w/ ISPs
  - provides better throughput, since there are no intermediate AS -> lower latency
  - redundancy (more vectors to deliver content)
  - burstiness: allows ISPs to spread their traffic across multiple links -> lowers costs

- ISPs Peer w/ CDNs
  - good performance for customers
  - lower transit costs
* Bittorrent
- Peer-to-peer content distribution
  - file sharing
  - large file distribution

Clients can get content from their peers instead of overloading a single source with requests. They can do this by each client having a different chunk of the file, and they each trade these chunks with each other, until the full file is assembled on each client. 
* Bit Torrent Publishing
There are several steps for bit torrent publishing:

1. Peer creates "torrent": contains metadata about the "tracker" and pieces, and their checksums
2. Seeders create initial copies of the file
3. Client contacts tracker which provides metadata, including a list of seeders
4. Client downloads parts of the file from the seeder
5. Clients begin swapping chunks
6. Clients that have an incomplete file is called a "leecher"

Problem: freeloading (client leaves the network as soon as it downloaded the entire file)
* Solution to Freeriding
*choking*: temporary refusal to upload chunks to another peer
- if a peer can't download from a client, don't upload to it (tit-for-tat)
* Getting Chunks to Swap
A client follows two policies:
- rarest piece first: determine which chunk is the rarest among clients and download it first
- random piece first: download a random chunk from a seeder

End game: actively request missing pieces from peers
* Distributed Hash Tables
Chord: a scalable, distributed, lookup service. A lookup service is where a value is a provided when given a key. Provides:
- Scalability
- provable correctness
- performance
* Chord Motivation
Scalable location of data in a large distributed system. What this means is a distribute hash table.
* Consistent Hashing
Keys and IDs map to the same ID space. 

When distributing key value pairs amongst nodes, we run into the problem of allocating pairs when a node is removed or added. Consistent hashings helps with this problem. 

See http://michaelnielsen.org/blog/consistent-hashing/
* Implementing Consistent HAshing
Option: every node knows the location over every other node
- lookups: O(1)
- Tables: O(N)

Option: every node knows the location of its successor (neighbor in a certain direction)
- Tables: O(1)
- lookups O(N)
* Finger Tables
Provides the best of both worlds when implementing consistent hashing. 


