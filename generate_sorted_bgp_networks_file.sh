#!/bin/bash
set -eu                # Always put this in Bourne shell scripts
IFS="`printf '\n\t'`"  # Always put this in Bourne shell scripts

# Create host file from lumped config file, sorted by IP address
./generate_bgp_networks.sh | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n 
