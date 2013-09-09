echo "#This file was created on $(date)"
echo "Hostname,Network, Mask, RouteType, ASN"
#ls -tQ ./configuration_files/IOS12/*| xargs cat

#sort the files by date, newest first, before cat'ing them
#this way, newer devices will supercede older ones in host file

#cat ./configuration_files/IOS12/*      | perl ipv4-interfaces-from-ios12.pl
ls -tQ ./configuration_files/IOS12/*| xargs cat | perl networks-advertised-from-cisco-ios-config.pl

#cat ./configuration_files/IOS15/*      | perl ipv4-interfaces-from-ios12.pl
ls -tQ ./configuration_files/IOS15/*| xargs cat | perl networks-advertised-from-cisco-ios-config.pl

#cat ./configuration_files/Nexus/*      | perl ipv4-interfaces-from-ios12.pl
ls -tQ ./configuration_files/Nexus/*| xargs cat | perl networks-advertised-from-cisco-ios-config.pl

#cat ./configuration_files/ASA/*        | perl ipv4-interfaces-from-ios12.pl
#ls -tQ ./configuration_files/ASA/*| xargs cat | perl ipv4-interfaces-from-ios12.pl

