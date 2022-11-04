# graph-pdu-schneider-e
Graph of PDU Schneider Electric

## Something about versions:

### v1.X
This version downloads the data directly from the PDU and makes a graph from it.

### v2.X
This version has 2 parts: server and client. The server periodically downloads the log from the PDU, which makes it possible to make graphs over a longer period without losing precision. The client then downloads the data from the server and makes a graph from it.