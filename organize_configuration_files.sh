#Move configuration files to separate directories based on a guess as to what they are for

#Save and then change BASH field separator so that we can handle file names with spaces in them
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

cd "configuration_files"
#if [ $? -ne 0 ] then quit

for i in `grep -lH "^## In-Path Rules" *Config*`              ; do mv "$i" ./Steelheads; done
for i in `grep -lH "^\[system\]" *Config*`                    ; do mv "$i" ./VPN; done
for i in `grep -lH "^# Full Detail Configuration" *Config*`   ; do mv "$i" ./Extreme; done
for i in `grep -lH "Total Config size " *Config*`             ; do mv "$i" ./ISG; done
for i in `grep -lH "^version 12" *Config*`                    ; do mv "$i" ./IOS12; done
for i in `grep -lH "^version 15" *Config*`                    ; do mv "$i" ./IOS15; done
for i in `grep -lH "^#version 8" *Config*`                    ; do mv "$i" ./GLX; done
for i in `grep -lH "^partition Common {" *Config*`            ; do mv "$i" ./F5; done
for i in `grep -lH "^!Command: show running-config" *Config*` ; do mv "$i" ./Nexus; done
for i in `grep -lH "^!Command: show startup-config" *Config*` ; do mv "$i" ./Nexus; done
for i in `grep -lH "^ASA Version " *Config*`                  ; do mv "$i" ./ASA; done
for i in `grep -lH "^FWSM Version " *Config*`                 ; do mv "$i" ./FWSM; done
for i in `grep -lH "^Generating configuration....$" *Config*`                 ; do mv "$i" ./ACE; done

#Restore field separator
IFS=$SAVEIFS
