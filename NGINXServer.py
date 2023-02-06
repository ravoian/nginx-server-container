#!/usr/local/bin/python3
# See bottom of file for command examples

# System Modules
import os
import sys
import argparse
import socket
import time

#Directory to serve static content from
serveDirectory = '/mnt/'

# Use simple std logging for basic DataDog collection 
class log:
    scriptName = os.path.basename(sys.argv[0])
    def info(msg):
        print(f'{log.scriptName}: {msg}', file=sys.stdout)
    def error(msg):
        print(f'{log.scriptName}: {msg}', file=sys.stderr)

def IsPortOccupied(port: int) -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0

def _ParseArguments() -> (bool, argparse.Namespace):
    # Generate our parser
    parser = argparse.ArgumentParser()
    # Service configuration
    parser.add_argument('--port', dest="serverPort", required=True, action='store', help='What file share to use')
    parser.add_argument('--dir', dest="serverDirectory", required=True, action='store', help='What mount point to use')
    # Parse what we got
    parsedArguments = parser.parse_args()
    return (True, parsedArguments)

def _EntryPointAsScript():
    # Parse the arguments
    operationSuccess, parsedArguments = _ParseArguments()
    if not operationSuccess:
        log.error('Failed to parse command line arguments')
        return -1
    serverPort = parsedArguments.serverPort

    global serverDirectory
    serverDirectory = parsedArguments.serverDirectory

    # Run the server and handle the output
    log.info('Starting NGINX server')
    if not IsPortOccupied(int(serverPort)):        
        try:
            # Run the server  2> /dev/null
            os.system("/usr/sbin/nginx")
            # Avoid overlap with NGINX starting log
            time.sleep(1)
            log.info(f'Serving {serveDirectory}')
        except Exception as e:
            log.error(f'{e}')
    else:
        log.info("Already running")

# Since we are running as a script; go ahead and run the entry point
if __name__ == '__main__':
    if sys.version_info.major < 3:
        log.error(f'Script requires Python3') 
    exitCode = _EntryPointAsScript()
    
# Example usage
# python3 NGINXserver.py --port 443 --dir /mnt/ 