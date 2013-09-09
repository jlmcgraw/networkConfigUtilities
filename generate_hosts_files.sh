echo "#This host file was created on $(date)"
#ls -tQ ./configuration_files/IOS12/*| xargs cat

#sort the files by date, newest first, before cat'ing them
#this way, newer devices will supercede older ones in host file

#cat ./configuration_files/IOS12/*      | perl ipv4-interfaces-from-ios12.pl
ls -tQ ./configuration_files/IOS12/*| xargs cat | perl ipv4-interfaces-from-ios12.pl

#cat ./configuration_files/IOS15/*      | perl ipv4-interfaces-from-ios12.pl
ls -tQ ./configuration_files/IOS15/*| xargs cat | perl ipv4-interfaces-from-ios12.pl

#cat ./configuration_files/Nexus/*      | perl ipv4-interfaces-from-ios12.pl
ls -tQ ./configuration_files/Nexus/*| xargs cat | perl ipv4-interfaces-from-nexus.pl

#cat ./configuration_files/ASA/*        | perl ipv4-interfaces-from-ios12.pl
ls -tQ ./configuration_files/ASA/*| xargs cat | perl ipv4-interfaces-from-ios12.pl

#In Steelhead configs the interfaces come first and the hostname later in the file so I'll simply reverse the input file to get it in the right order (hack)
#tac ./configuration_files/Steelheads/* | perl ipv4-interfaces-from-steelhead.pl
ls -tQ ./configuration_files/Steelheads/*| xargs tac | perl ipv4-interfaces-from-steelhead.pl

#In Extreme configs the interfaces come first and the hostname later in the file so I'll simply reverse the input file to get it in the right order (hack)
#tac ./configuration_files/Extreme/* | perl ipv4-interfaces-from-extreme.pl
ls -tQ ./configuration_files/Extreme/*| xargs tac | perl ipv4-interfaces-from-extreme.pl

#In ISG configs the interfaces come first and the hostname later in the file so I'll simply reverse the input file to get it in the right order (hack)
#tac ./configuration_files/ISG/* | perl ipv4-interfaces-from-isg.pl
ls -tQ ./configuration_files/ISG/*| xargs tac | perl ipv4-interfaces-from-isg.pl
