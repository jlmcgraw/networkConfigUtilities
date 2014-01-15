#!/bin/sh
  # CORRECT if files can't contain control chars and can't start with "-":
  set -eu                # Always put this in Bourne shell scripts
  IFS="`printf '\n\t'`"  # Always put this in Bourne shell scripts

# tac ./configuration_files/Steelheads/* | ./inpath-interfaces-and-subnets-from-steelhead.pl > inpaths.txt
ls -tQ ./configuration_files/Steelheads/*| xargs tac | ./inpath-interfaces-and-subnets-from-steelhead.pl > inpaths.txt
