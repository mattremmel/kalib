#!/bin/bash

# ------------------------------------------------------------------
#  Author: Matthew Remmel (matt.remmel@gmail.com)
#  Title: dnsresolve
#
#  Description: Lists the IP addresses associated with a provided
#               hostname.
#
#  Return:      A 0 is returned if the lookup finishes without error.
#               A 1 is returned otherwise.
#
#  Dependency:  host
# ------------------------------------------------------------------

# --- Version and Usage ---
DESCRIPTION="Description: Displays IP addresses for hostname"
VERSION=0.1.0
USAGE="Usage: dnsresolve [OPTION] HOSTNAME

Options:
-h, --help       Show help and usage information
-v, --version    Show version information
-s, --server     Specify dns server to use
-4, --ipv4       Show ipv4 addresses only
-6, --ipv6       Show ipv6 addresses only"

# --- Dependecy Check ---
command -v host >/dev/null 2>&1 || { echo >&2 "[ERROR] Dependency 'host' not installed. Exiting."; exit 1; }

# --- Arguments ---
# Check that there is at least one argument. If not show usage.
if [ $# -eq 0 ]; then
    echo "$DESCRIPTION"
    echo
    echo "$USAGE"
    echo
    exit 1
fi

SERVER=""
IPV4ONLY=1
IPV6ONLY=1
NOFORMAT=1

while [[ $# > 1 ]]
do
    key="$1"

    case $key in
	-h|--help)
	    echo "$DESCRIPTION"
	    echo
	    echo "$USAGE"
	    echo
	    exit 0;;
	-v|--version)
	    echo "Version: $VERSION"
	    exit 0;;
  -s|--server)
      SERVER="$2"
      shift;;
	-4|--ipv4)
	    IPV4ONLY=0;;
	-6|--ipv6)
	    IPV6ONLY=0;;
  -n|--no-format)
      NOFORMAT=0;;
	*)
	    echo "Unknown argument: $key"
	    exit 1;;
    esac

    shift
done

HOST=$1

# --- Main Body ---
# Retreive and parse IPv4 and IPv6 addresses
RESULT=$(host $HOST $SERVER)
IPV4ADDRS=$(echo "$RESULT" | grep "has address"  | rev | cut -d" " -f1 | rev)
IPV6ADDRS=$(echo "$RESULT" | grep "IPv6 address" | rev | cut -d" " -f1 | rev)

# Output DNS information
if [ $NOFORMAT -eq 1 ]; then
  echo "Host: $HOST"
  if [ "$SERVER" = "" ]; then
    echo "DNS: default"
  else
    echo "DNS: $SERVER"
  fi
fi

if [ $IPV6ONLY -eq 1 ]; then
  for ADDR in $IPV4ADDRS; do
    if [ $NOFORMAT -eq 1 ]; then
      echo "IPv4: $ADDR"
    else
      echo "$ADDR"
    fi
  done
fi

if [ $IPV4ONLY -eq 1 ]; then
  for ADDR in $IPV6ADDRS; do
    if [ $NOFORMAT -eq 1 ]; then
      echo "IPv6: $ADDR"
    else
      echo "$ADDR"
    fi
  done
fi

exit 0
