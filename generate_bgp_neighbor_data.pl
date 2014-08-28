#!/usr/bin/perl
use warnings;
use strict;

#
#name	Local_ID	Local_ASN	Remote_Neighbor	Remote_ID	Remote_ASN
#
print
  "#Hostname\t\t\tLocal_ID\t\tLocal_ASN\tRemote_Neighbor\t\tRemote_ID\t\tRemote_ASN\n";
while (<>) {
    our (
        $hostname,        $Local_ID,  $Local_ASN,
        $Remote_Neighbor, $Remote_ID, $Remote_ASN
    );
    our @fields;

    chomp;    # remove newline characters

    # find the line with the hostname in it by searching
    if ( $_ =~ /^..TOWW..........#/ ) {

        #Remove the trailing hash
        $hostname = substr $_, 0, 16;

    }

    # identify lines with "BGP router identifier" at the beginning
    #BGP router identifier 172.20.16.94, local AS number 65165
    if ( $_ =~ /^BGP router identifier/ ) {

        #split the good lines into space-separated fields
        @fields = split /\s+/, $_;
        chop( $fields[3] );
        $Local_ID  = $fields[3];
        $Local_ASN = $fields[7];
    }

    # identify lines with "BGP neighbor is" at the beginning
    #BGP neighbor is 10.78.32.138,  remote AS 65165, internal link
    if ( $_ =~ /^BGP neighbor is/ ) {

        #split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields = split /\s+/, $_;

        #Remove the comma
        chop( $fields[3] );
        chop( $fields[6] );
        $Remote_Neighbor = $fields[3];
        $Remote_ASN      = $fields[6];

    }

    # identify lines with "BGP version" at the beginning
    #BGP version 4, remote router ID 172.20.16.95" in them
    if ( $_ =~ /^\s*BGP version/ ) {

        #split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields = split /\s+/, $_;
        $Remote_ID = $fields[7];

        #ignore lines that contain 0.0.0.0 which indicates an invalid/down peer
        if ( $_ !~ /0\.0\.0\.0/ ) {
            print
              "$hostname\t\t$Local_ID\t\t$Local_ASN\t\t$Remote_Neighbor\t\t$Remote_ID\t\t$Remote_ASN\n";
        }
    }

}

