# kalib

Collection of custom command line tools and notes to be used alongside kali

## Tools:
- backdoor
  - backdoor.py - This python script starts a server and listens for tcp connections. Upon a connection, the program starts a client handler that serves a shell.
- encoding
  - rotn.sh - This script will rotate an input string by 13 characters (rot13) by default, or 47 characters (rot47) if specified.
- generic
  - dnsresolve.sh - This is a wrapper for the command 'host' that parses and pretty prints the result with several available options.
  - geoip.sh - This script takes a passed in hostname or ip address and pretty prints all of geographical information for it. This uses a web service for the data.
  - ip.sh - This script prints out all internal and external ip address for the host. This uses a web service for the external address.
  - log.sh - This script takes a message from stdin and prints it out in logging statement form with the log level and timestamp.
  - prettyjson.sh - This script takes JSON data from stdin and pretty prints it in the terminal. The indent level for the JSON can optionally be set.
- middle_man
  - arppoison.sh - This script will set up a man-in-the-middle attack via arp cache poisoning using the tool 'arpspoof'
- network
  - nc.py - A simple netcat like tool implemented in python
- proxy
  - socksproxy.sh - This script sets up a socks5 proxy on the host using ssh. An exit node can optionally be set to tunnel traffic from the proxy host through another server.
- reverse_shell
  - rsh.* - Reverse shell scripts implemented in several languages.

### Disclaimer:

These scripts/tools/notes were written for educational purposes only, and should not be used maliciously. Information security is a serious issue, and to understand solutions, we must first understand the problem.
