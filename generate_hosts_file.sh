#!/bin/bash
# CORRECT if files can't contain control chars and can't start with "-":
set -eu                # Always put this in Bourne shell scripts
IFS=$(printf '\n\t')  # Always put this in Bourne shell scripts

echo "#This host file was created on $(date)"
#ls -tQ ./configuration_files/IOS12/*| xargs cat

#sort the files by date, newest first, before cat'ing them
#this way, newer devices will supercede older ones in host file

#cat ./configuration_files/IOS12/*      | perl ipv4-interfaces-from-ios12.pl
# ls -tQ ./configuration_files/IOS12/*| xargs cat | perl ipv4-interfaces-from-ios12.pl
find ./configuration_files/IOS12/* -print0 | xargs -0 cat | perl ipv4-interfaces-from-ios12.pl

#cat ./configuration_files/IOS15/*      | perl ipv4-interfaces-from-ios12.pl
# ls -tQ ./configuration_files/IOS15/*| xargs cat | perl ipv4-interfaces-from-ios12.pl
find ./configuration_files/IOS15/* -print0 | xargs -0 cat | perl ipv4-interfaces-from-ios12.pl

#cat ./configuration_files/Nexus/*      | perl ipv4-interfaces-from-ios12.pl
# ls -tQ ./configuration_files/Nexus/*| xargs cat | perl ipv4-interfaces-from-nexus.pl
find ./configuration_files/Nexus/* -print0 | xargs -0 cat| perl ipv4-interfaces-from-nexus.pl

#cat ./configuration_files/ASA/*        | perl ipv4-interfaces-from-ios12.pl
# ls -tQ ./configuration_files/ASA/*| xargs cat | perl ipv4-interfaces-from-ios12.pl
find ./configuration_files/ASA/* -print0 | xargs -0 cat | perl ipv4-interfaces-from-ios12.pl

#In Steelhead configs the interfaces come first and the hostname later in the file so I'll simply reverse the input file to get it in the right order (hack)
#tac ./configuration_files/Steelheads/* | perl ipv4-interfaces-from-steelhead.pl
# ls -tQ ./configuration_files/Steelheads/*| xargs tac | perl ipv4-interfaces-from-steelhead.pl
find ./configuration_files/Steelheads/* -print0 | xargs -0 tac | perl ipv4-interfaces-from-steelhead.pl

#In Extreme configs the interfaces come first and the hostname later in the file so I'll simply reverse the input file to get it in the right order (hack)
#tac ./configuration_files/Extreme/* | perl ipv4-interfaces-from-extreme.pl
# ls -tQ ./configuration_files/Extreme/*| xargs tac | perl ipv4-interfaces-from-extreme.pl
find ./configuration_files/Extreme/* -print0 | xargs -0 tac | perl ipv4-interfaces-from-extreme.pl

#In ISG configs the interfaces come first and the hostname later in the file so I'll simply reverse the input file to get it in the right order (hack)
#tac ./configuration_files/ISG/* | perl ipv4-interfaces-from-isg.pl
# ls -tQ ./configuration_files/ISG/*| xargs tac | perl ipv4-interfaces-from-isg.pl
find ./configuration_files/ISG/* -print0 | xargs -0 tac | perl ipv4-interfaces-from-isg.pl
