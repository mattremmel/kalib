#!/bin/bash

# ------------------------------------------------------------------
#  Author: Matthew Remmel (matt.remmel@gmail.com)
#  Title: RotN
#
#  Description: RotN is a script that takes input and either rotates
#               the characters by 13 characters, or 47 characters,
#               to the effect of creating an invertable substitution
#               cipher.
#
#  Return:      A 1 is returned if there is a problem parsing the
#               input. A 0 is returned otherwise.
#
#  Dependency:  cat, tr
# ------------------------------------------------------------------

# --- Version and Usage ---
DESCRIPTION="Description: RotN is a script that takes input and either
rotates the characters by 13 characters, or 47 characters, to the effect
of creating an invertable substitution cipher. Default encoding is Rot47."
VERSION=0.1.0
USAGE="Usage: {input} | rotn [options] input

Options:
-h, --help       Show help and usage information
-v, --version    Show version information
-13, --rot13     Rotate input by 13 characters
-47, --rot47     Rotate input by 47 characters"

# --- Dependecy Check ---
command -v cat >/dev/null 2>&1 || { echo >&2 "[ERROR] Dependency 'cat' not installed. Exiting."; exit 1; }
command -v tr >/dev/null 2>&1 || { echo >&2 "[ERROR] Dependency 'tr' not install. Exiting."; exit 1; }

# --- Arguments ---
ROT47=0

while [[ $# > 0 ]]
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
  -13|--rot13)
      ROT47=0;;
  -47|--rot47)
      ROT47=1;;
	*)
	    echo "Unknown argument: $key"
	    exit 1;;
    esac

    shift
done

# --- Main Body ---
INPUT=$(cat "-")

if [ $ROT47 -eq 1 ]; then
  echo $INPUT | tr '\!-~' 'P-~\!-O'
else
  echo $INPUT | tr '[A-Za-z]' '[N-ZA-Mn-za-m]'
fi

exit 0
