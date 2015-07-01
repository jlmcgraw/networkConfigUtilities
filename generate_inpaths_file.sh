#!/bin/bash
set -eu                # Always put this in Bourne shell scripts
IFS=$(printf '\n\t')  # Always put this in Bourne shell scripts

# tac ./configuration_files/Steelheads/* | ./inpath-interfaces-and-subnets-from-steelhead.pl > inpaths.txt
# ls -tQ ./configuration_files/Steelheads/*| xargs tac | ./inpath-interfaces-and-subnets-from-steelhead.pl > inpaths.txt
find ./configuration_files/Steelheads/* -print0 | xargs -0 tac | ./inpath-interfaces-and-subnets-from-steelhead.pl > inpaths.txt