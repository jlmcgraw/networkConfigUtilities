#!/bin/bash
#
#Move configuration files to separate directories based on a guess as to what they are for
#
# CORRECT if files can't contain control chars and can't start with "-":
SAVEIFS=$IFS
set -eu                # Always put this in Bourne shell scripts
IFS=$(printf '\n\t')  # Always put this in Bourne shell scripts

#go to where configuration files are stored
cd "configuration_files"

#Move them based on text found within
for i in $(grep -lH "^## In-Path Rules" ./*)              ; do mv "$i" ./Steelheads; done
for i in $(grep -lH "^## Inpath Rules" ./*)               ; do mv "$i" ./Steelheads; done
for i in $(grep -lH "^\[system\]" ./*)                    ; do mv "$i" ./VPN; done
for i in $(grep -lH "^# Full Detail Configuration" ./*)   ; do mv "$i" ./Extreme; done
for i in $(grep -lH "Total Config size " ./*)             ; do mv "$i" ./ISG; done
for i in $(grep -lH "^version 12" ./*)                    ; do mv "$i" ./IOS12; done
for i in $(grep -lH "^version 15" ./*)                    ; do mv "$i" ./IOS15; done
for i in $(grep -lH "^#version 8" ./*)                    ; do mv "$i" ./GLX; done
for i in $(grep -lH "^partition Common {" ./*)            ; do mv "$i" ./F5; done
for i in $(grep -lH "^!Command: show running-config" ./*) ; do mv "$i" ./Nexus; done
for i in $(grep -lH "^!Command: show startup-config" ./*) ; do mv "$i" ./Nexus; done
for i in $(grep -lH "^ASA Version " ./*)                  ; do mv "$i" ./ASA; done
for i in $(grep -lH "^FWSM Version " ./*)                 ; do mv "$i" ./FWSM; done
for i in $(grep -lH "^Generating configuration....$" ./*) ; do mv "$i" ./ACE; done

#Restore field separator
IFS=$SAVEIFS
