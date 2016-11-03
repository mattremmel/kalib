#!/bin/bash

# ------------------------------------------------------------------
#  Author: Matthew Remmel (matt.remmel@gmail.com)
#  Title: socksproxy
#
#  Description: Sets up a socks4/5 proxy using ssh.
#
#  Return:      A 0 is returned if the server starts without error.
#               A 1 is returned otherwise.
#
#  Dependency:  host
# ------------------------------------------------------------------

# --- Version and Usage ---
DESCRIPTION="Description: Sets up a socks4/5 proxy using ssh"
VERSION=0.1.0
USAGE="Usage: socksproxy [OPTION] PORT

Options:
-h, --help        Show help and usage information
-v, --version     Show version information
-i, --interface   Set which interface to listen on (default=0.0.0.0)
-p, --port        Set which port to listen on
-e, --endpoint    Set endpoint for proxy tunnel (default=localhost)
-b, --background  Run proxy in background as a daemon"

# --- Dependecy Check ---
command -v ssh >/dev/null 2>&1 || { echo >&2 "[ERROR] Dependency 'ssh' not installed. Exiting."; exit 1; }

INTERFACE="0.0.0.0"
PORT=1212
ENDPOINT="127.0.0.1"
BACKGROUND=""

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
  -i|--interface)
      INTERFACE="$2"
      shift;;
	-p|--port)
	    PORT="$2"
      shift;;
	-e|--endpoint)
	    ENDPOINT="$2"
      shift;;
  -b|--background)
      BACKGROUND="-f";;
	*)
	    echo "Unknown argument: $key"
	    exit 1
	    ;;
    esac

    shift
done

# --- Main Body ---
echo "Starting proxy for interface: $INTERFACE port: $PORT"
ssh $BACKGROUND -N -D $INTERFACE:$PORT $ENDPOINT
exit 0
