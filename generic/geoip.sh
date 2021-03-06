#!/bin/bash

# ------------------------------------------------------------------
#  Author: Matthew Remmel (matt.remmel@gmail.com)
#  Title: GeoIP
#
#  Description: GeoIP retreives the geographical information for
#               the supplied IP address.
#
#  Return:      A 1 is returned if the IP information is retrieved
#               successfully. A 1 is returned otherwise.
#
#  Dependency:  curl
# ------------------------------------------------------------------

# --- Version and Usage ---
DESCRIPTION="Description: Displays the geographical information for the supplied IP address"
VERSION=0.1.1
USAGE="Usage: geoip [OPTION] [IP Address]

Options:
-h, --help       Show help and usage information
-v, --version    Show version information
-r, --raw        Show raw json output
-n, --no-format  Show only unformatted data"

# --- Dependecy Check ---
command -v curl >/dev/null 2>&1 || { echo >&2 "[ERROR] Dependency 'curl' not installed. Exiting."; exit 1; }
command -v grep >/dev/null 2>&1 || { echo >&2 "[ERROR] Dependency 'grep' not installed. Exiting."; exit 1; }

# --- Arguments ---
# Check that there is at least one argument. If not show usage.
if [ $# -eq 0 ]; then
    echo "$DESCRIPTION"
    echo
    echo "$USAGE"
    echo
    exit 1
fi

# Handle arguments
RAWOUTPUT=1
NOFORMAT=1

while [[ $# > 1 ]]
do
    key="$1"

    case $key in
	-h|--help)
	    echo "$DESCRIPTION"; echo
	    echo "$USAGE"; echo
	    exit 0;;
	-v|--version)
	    echo "Version: $VERSION"
	    exit 0;;
	-r|--raw)
	   RAWOUTPUT=0;;
	-n|--no-format)
	    NOFORMAT=0;;
	*)
	    echo "Unknown argument: $key"
	    exit 1;;
    esac

    shift
done

IP=$1


# --- Main Body ---
# Retreive geolocation data from ipinfo.io
GEODATA=$(curl -m 5 ipinfo.io/$IP 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "[ERROR] Error retreiving geolocation data. Check connection."
    exit 1
fi

# Display raw output
if [ $RAWOUTPUT -eq 0 ]; then
    echo "$GEODATA"
    exit 0
fi

# TODO: Message "Please provied a valid IP address" can be returned while curl still returns 0
# TODO: Make sure that returned data is valid JSON. Can probably happen while being parsed

# IP Address
IP=$(echo $GEODATA | grep -o '"ip":\s"[^,]*' | cut -d"\"" -f4)

# Hostname
HOST=$(echo $GEODATA | grep -o '"hostname":\s"[^,]*' | cut -d"\"" -f4)

# City
CITY=$(echo $GEODATA | grep -o '"city":\s"[^,]*' | cut -d"\"" -f4)

# Region
REGION=$(echo $GEODATA | grep -o '"region":\s"[^,]*' | cut -d"\"" -f4)

# Country
COUNTRY=$(echo $GEODATA | grep -o '"country":\s"[^,]*' | cut -d"\"" -f4)

# Location
LATITUDE=$(echo $GEODATA | grep -o '"loc":\s"[^"]*' | cut -d"\"" -f4 | cut -d"," -f1)
LONGITUDE=$(echo $GEODATA | grep -o '"loc":\s"[^"]*' | cut -d"\"" -f4 | cut -d"," -f2)

# Organization
ORGANIZATION=$(echo $GEODATA | grep -o '"org":\s"[^,]*' | cut -d"\"" -f4)

# Postal Code
POSTAL=$(echo $GEODATA | grep -o '"postal":\s"[^,]*' | cut -d"\"" -f4)


# Print all information
if [ $NOFORMAT -eq 0 ]; then
    echo $IP; echo $HOST; echo $CITY; echo $REGION; echo $COUNTRY; echo $LATITUDE; echo $LONGITUDE; echo $ORGANIZATION; echo $POSTAL;
else
    echo "IP:            $IP"
    echo "Host:          $HOST"
    echo "City:          $CITY"
    echo "Region:        $REGION"
    echo "Country:       $COUNTRY"
    echo "Latitude:      $LATITUDE"
    echo "Longitude:     $LONGITUDE"
    echo "Organization:  $ORGANIZATION"
    echo "Postal:        $POSTAL"
fi

exit 0
