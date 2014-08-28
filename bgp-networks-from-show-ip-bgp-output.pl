#!/usr/bin/perl

use warnings;
use strict;

#
#name	Local_ID	Local_ASN	Remote_Neighbor	Remote_ID	Remote_ASN
#

while (<>) {

    chomp;    # remove newline characters

    # find the line with the hostname in it by searching
    # for the "hostname " string
    # this assumes hostname comes before interface configurations
    if ( $_ =~ /^????????????????#/ ) {

        #Remove the trailing hash
        $_ = chop($_);

        # hostname is the element after the "space".
        $hostname = uc $hostnameFields[1];

    }

    # identify lines with "interface " at the beginning
    #BGP router identifier 172.20.16.94, local AS number 65165
    if ( $_ =~ /^BGP router identifier/ ) {

        #split the good lines into space-separated fields
        @fields = split /\s+/, $_;

        $Local_ID  = $fields[3];
        $Local_ASN = $fields[7];
    }

    # identify lines with "ip address #.#.#.#" in them
    if ( $_ =~
        /^\s*network (?:\d{1,3}\.){3}\d{1,3} mask (?:\d{1,3}\.){3}\d{1,3}/ )
    {

        #strip leading whitespace
        $_ =~ s/^\s+//;

        #split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields       = split /\s+|\//, $_;
        $ip_addr      = $fields[1];
        $network_mask = $fields[3];
        print "$ip_addr\t\t$network_mask\t\t$hostname\t\t$AS_number\n";
    }
    if ( $_ =~ /^????????????????#quit/ ) {
        print
          "$hostname\t\t$Local_ID\t\t$Local_ASN\t\t$Remote_neighbor\t\t$Remote_ID\t\t$Remote_ASN\n";

    }

}

