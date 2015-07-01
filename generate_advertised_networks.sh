#!/bin/bash
set -eu                # Always put this in Bourne shell scripts
IFS=$(printf '\n\t')  # Always put this in Bourne shell scripts

echo "#This file was created on $(date)"
echo "file,hostname,interface,bandwidth,description,ip_addr,network_mask,network_masklen,route_type,AS_number,ip_addr_bigint,isRfc1918,range"

#ls -tQ ./configuration_files/IOS12/*| xargs cat

#sort the files by date, newest first, before cat'ing them
#this way, newer devices will supercede older ones in host file


#ls -tQ ./configuration_files/IOS12/*| xargs cat | perl networks-advertised-from-cisco-ios-config.pl
find ./configuration_files/IOS12/ -name "*" -type f -exec ./networks-advertised-from-cisco-ios-config-byFile.pl {} \;

# ls -tQ ./configuration_files/IOS15/*| xargs cat | perl networks-advertised-from-cisco-ios-config.pl
find ./configuration_files/IOS15/ -name "*" -type f -exec ./networks-advertised-from-cisco-ios-config-byFile.pl {} \;

# ls -tQ ./configuration_files/Nexus/*| xargs cat | perl networks-advertised-from-cisco-ios-config.pl
find ./configuration_files/Nexus/ -name "*" -type f -exec ./networks-advertised-from-cisco-nexus-config-byFile.pl {} \;

# ls -tQ ./configuration_files/ASA/*  | xargs cat | perl ipv4-interfaces-from-ios12.pl
# find ./configuration_files/ASA/ -name "*" -type f -exec networks-advertised-from-cisco-ios-config-byFile {}.pl {} \;
