# graph-pdu-schneider-e
Automation of graphing energy usage etc. from the PDU of Schneider Electric.

## Something about versions:

### One-time logging
It connects to the server once, downloads the log and makes a graph. Suitable for one-off or regular runs on a personal computer.

### Periodic logging
It downloads the log at regular itervals, making it possible to make longer-term graphs. Suitable for constant running on servers.