#!/bin/sh
  # CORRECT if files can't contain control chars and can't start with "-":
  set -eu                # Always put this in Bourne shell scripts
  IFS="`printf '\n\t'`"  # Always put this in Bourne shell scripts

#Display hosts with duplicate IP addresses (ignoring lines with HSRP in them)
awk -F' ' '{print $1}' hosts |sort|uniq -d|grep -F -f - hosts | grep -v HSRP
