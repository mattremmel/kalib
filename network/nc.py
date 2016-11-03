#!/usr/bin/env python

# nc.py - Netcat related tool written in python

import sys
import socket
import getopt
import threading
import subprocess

# Global Variables
listen = False
command = False
upload = False
execute = ""
target = ""
upload_destination = ""
port = 0


def usage():
    print "Netcat Like Tool"
    print
    print "Usage: nc.py -t [target] -p [port]"
    print "-l --listen              - listen on [target]:[port] for incoming connections"
    print "-e --execute=command     - execute the given command upon receiving a connection"
    print "-c --command             - initialize a command shell"
    print "-u --upload=destination  - upon receiving connection upload a file and write to [destination]"
    print
    print
    print "Examples: "
    print "ncpy.py -t 192.168.1.1 -p 5555 -l -c"
    print "ncpy.py -t 192.168.1.1 -p 5555 -l -u c://target.exe"
    print "ncpy.py -t 192.168.1.1 -p 5555 -l -e \"/bin/sh\""
    print "echo 'abcdefghi' | ./ncpy.py -t 192.168.11.12 -p 135"
    sys.exit(0)


def main():
    global listen
    global port
    global execute
    global command
    global upload_destination
    global target

    # Check for command line arguments
    if not len(sys.argv[1:]):
        usage()

    # Parse command line arguments
    opts = []
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hle:t:p:cu:", ["help", "listen", "execute", "target", "port", "command", "upload"])

    except getopt.GetoptError as err:
        print str(err)
        usage()

    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
        elif o in ("-t", "--target"):
            target = a
        elif o in ("-p", "--port"):
            port = int(a)
        elif o in ("-l", "--listen"):
            listen = True
        elif o in ("-e", "--execute"):
            execute = a
        elif o in ("-c", "--command"):
            command = True
        elif o in ("-u", "--upload"):
            upload_destination = a
        else:
            print "Unknown option: " + o
            usage()

    # Check if listening as server or running as client
    if listen:
        server_loop()

    if not listen and len(target) and port > 0:
        # Read in buffer from stdin
        # This will block, so send CTRL-D if not sending input
        buffer = sys.stdin.read()
        client_sender(buffer)


def server_loop():
    global target

    # If no target defined, listen on all interfaces
    if not len(target):
        target = "0.0.0.0"

    try:
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.bind((target, port))
        server.listen(5)

    except Exception as e:
        print "[!!] Failed to bind to: %s:%d" % (target, port)
        print "[!!] Try another socket or check permissions"
        print str(e)
        sys.exit(1)

    try:
        while True:
            client_socket, addr = server.accept()

            # Handle new client
            client_thread = threading.Thread(target=client_handler, args=(client_socket,))
            client_thread.start()

    except Exception as e:
        print "[!!] Exception occurred, exiting.."
        print str(e)
        sys.exit(1)

    except KeyboardInterrupt:
        print "User fired keyboard interrupt, closing connection.."
        sys.exit(0)


def client_handler(client_socket):
    global upload
    global execute
    global command

    # Check for upload
    if len(upload_destination):
        # Read in all of the bytes and write to destination
        file_buffer = ""

        while True:
            data = client_socket.recv(1024)

            if not data:
                break
            else:
                file_buffer += data

        # Write out file
        try:
            file_descriptor = open(upload, "wb")
            file_descriptor.write(file_buffer)
            file_descriptor.close()
            client_socket.send("Successfully saved file to %s\r\n" % upload_destination)

        except Exception as err:
            client_socket.send("Failed to save file to %s\r\nError: %s\r\n" % (upload_destination, str(err)))

    # Check for command execution
    if len(execute):
        output = run_command(execute)
        client_socket.send(output)

    # Command shell
    if command:
        while True:
            # Show prompt
            # print "Sending prompt to client"
            client_socket.send("<ncpy:#> ")

            cmd_buffer = ""
            while "\n" not in cmd_buffer:
                cmd_buffer += client_socket.recv(1024)

            output = run_command(cmd_buffer)
            client_socket.send(output)


def run_command(command):
    # Trim newline
    command = command.strip()

    # Run command
    try:
        output = subprocess.check_output(command, stderr=subprocess.STDOUT, shell=True)

    except Exception as err:
        output = "Failed to execute command: %s\r\nError: %s\r\n" % (command, str(err))

    if len(output) == 0:
        output = "[no output]\n"

    return output


def client_sender(buffer):
    # Setup tcp client
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    try:
        # Connect to target host
        client.connect((target, port))

        if len(buffer):
            client.send(buffer)

        while True:
            # Wait for prompt
            recv_len = 1
            response = ""

            while recv_len:
                data = client.recv(4096)
                recv_len = len(data)
                response += data

                if recv_len < 4096:
                    break

            print response,

            # Wait for input
            buffer = raw_input("")
            buffer += "\n"
            client.send(buffer)

            # Wait for response
            recv_len = 1
            response = ""

            while recv_len:
                data = client.recv(4096)
                recv_len = len(data)
                response += data

                if recv_len < 4096:
                    break

            print response,

    except Exception as err:
        print "Error: " + str(err)
        print "Exiting.."
        client.close()

    except KeyboardInterrupt:
        print "User fired keyboard interrupt, closing connection.."
        sys.exit(0)


if __name__ == "__main__":
    main()
