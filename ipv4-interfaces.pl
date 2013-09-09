#!/usr/bin/perl
#
# takes output from a Solarwinds Orion NCM command script
# that runs "show ip interface brief | exclude unassigned"
# and produces a "hostname IP" output for import into DNS
# this makes traceroutes more readable
#
# usage: ./interface2dns.pl < inputfile.txt
# inputfile.txt will look like this
# when produced by Orion NCM 6.x:
#
# routerA.test.com  (10.38.16.126)
# Interface   IP-Address      OK? Method Status Protocol
# Loopback0   172.29.255.1    YES NVRAM  up     up
# Vlan163     10.38.16.126    YES NVRAM  up     up
# Vlan165     10.38.16.117    YES NVRAM  up     up
#
#
while (<>) {

    chomp;    # remove newline characters

    # find the line with the hostname in it by searching
    # for the "#" character
    # catowwtorca01s05

    #if ($_=~/\#/) {
    if ( $_ =~ /^\w{16}\#/ ) {

        # split that line on the # character
        @hostnameFields = split /\#/, $_;

        # hostname is the first element before the first .
        $hostname = uc $hostnameFields[0];

    }

    # identify lines with "up" in them to remove garbage
    if ( $_ =~ /\s+up\s+/ ) {

        #split the good lines into space-separated fields
        @fields = split /\s+/, $_;

        #find RFC1918-like addresses only
        #    if ($fields[1]=~/^10\.|172\.|192\./){

        # skip IP addresses that are already in DNS
        #unless (`dig -x $fields[1] +short`) {

        #substitute - for / and . and : in dns names
        $fields[0] =~ s/\/|:|\./-/g;

        #print in "ipaddr hostname-interface" format
        print "$fields[1]\t\t$hostname-$fields[0]\n";

        #print just the hostname if this is for loopback0
        #if ($fields[0]=~/Loopback0/) {
        #print "$fields[1]\t\t$hostname\n";
        #}
        #        }
        #   }
    }
}
