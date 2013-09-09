#!/usr/bin/perl

use warnings;
use strict;
use autodie;

use NetAddr::IP;

#
# takes text from a Cisco IOS, Nexus or PIX running config
# and produces an output for import into DNS or host file
# this makes traceroutes more readable
#
# this really only works with IPv4
#
# usage: ./hosts-from-running-config.pl < inputfile.txt > hosts
#   where inputfile.txt is one or more config files lumped together
#
# if you want to get more crafty you can pipe through sort and uniq:
# ./hosts-from-running-config.pl < inputfile.txt | sort | uniq > hosts
#
# You'll have to put this hosts file in the proper place for your OS to make it
# take effect (google is your friend)

our ( @hostnameFields, @fields );
our ( $hostname, $route_type, $AS_number, $ip_addr, $network_mask, $network_masklen );
our ($subnet);

while (<>) {

    chomp;    # remove newline characters

    # find the line with the hostname in it by searching
    # for the "hostname " string
    # this assumes hostname comes before interface configurations
    if ( $_ =~ /^hostname / ) {

        #Reset variables after each new hostname just in case
        $hostname = $route_type = $AS_number = $ip_addr = $network_mask = $network_masklen = $subnet = "";

        # split that line on the whitespace character
        @hostnameFields = split /\s+/, $_;

        # hostname is the element after the "space".
        $hostname = uc $hostnameFields[1];

    }

    # identify lines with "router " at the beginning
    if ( $_ =~ /^router (bgp|ospf|eigrp|rip) \d+/ ) {

        #split the good lines into space-separated fields
        @fields = split /\s+/, $_;

        $route_type = $fields[1];    #routing process
        $AS_number  = $fields[2];    #AS number
    }

    # identify lines with "network #.#.#.# mask #.#.#.#" in them (BGP routes)
    if ( $_ =~
        /^\s*network (?:\d{1,3}\.){3}\d{1,3} mask (?:\d{1,3}\.){3}\d{1,3}/ )
    {
        #strip leading whitespace
        $_ =~ s/^\s+//;

	#split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields = split /\s+|\//, $_;

        #Create an new subnet from proper fields
        $subnet = NetAddr::IP->new("$fields[1]/$fields[3]");

        $ip_addr      = $fields[1];
        $network_mask = $fields[3];

        #Comment next line out to not use the NetAddr object
        $ip_addr      = $subnet->addr;
        $network_mask = $subnet->mask;
	$network_masklen = $subnet->masklen;

        print "$hostname\t\t$ip_addr\t\t$network_mask\t\t$network_masklen\t\t$route_type\t\t$AS_number\n";
    }

    # identify lines with "network #.#.#.# #.#.#.#" in them (EIGRP, OSPF, RIP routes)
    if ( $_ =~ /^\s*network (?:\d{1,3}\.){3}\d{1,3} (?:\d{1,3}\.){3}\d{1,3}/ ) {

        #strip leading whitespace
        $_ =~ s/^\s+//;

	#split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields = split /\s+|\//, $_;

        #This little bit of magic inverts the wildcard mask to a netmask.  Copied from somewhere on the net
        my $mask_wild_dotted = $fields[2];
        my $mask_wild_packed = pack 'C4', split /\./, $mask_wild_dotted;
        my $mask_norm_packed = ~$mask_wild_packed;
        my $mask_norm_dotted = join '.', unpack 'C4', $mask_norm_packed;

        #Create an new subnet from proper fields
        $subnet = NetAddr::IP->new("$fields[1]/$mask_norm_dotted");

        $ip_addr      = $fields[1];
        $network_mask = $fields[2];

        #Comment next line out to not use the NetAddr object
        $ip_addr      = $subnet->addr;
        $network_mask = $subnet->mask;    #Change to masklen to get length
	$network_masklen = $subnet->masklen;
        print "$hostname\t\t$ip_addr\t\t$network_mask\t\t$network_masklen\t\t$route_type\t\t$AS_number\n";
    }

    # identify lines with "network #.#.#.#/##" in them (Nexus EIGRP, OSPF, RIP routes)
    if ( $_ =~ /^\s*network (?:\d{1,3}\.){3}\d{1,3}\/\d\d/ ) {

        #strip leading whitespace
        $_ =~ s/^\s+//;

	#split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields = split /\s+|\//, $_;

        #Create an new subnet from proper fields
        $subnet = NetAddr::IP->new("$fields[1]/$fields[2]");

        $ip_addr      = $fields[1];
        $network_mask = $fields[2];

        #Comment next line out to not use the NetAddr object
        $ip_addr      = $subnet->addr;
        $network_mask = $subnet->mask;
	$network_masklen = $subnet->masklen;

        print
"$hostname\t\t$ip_addr\t\t$network_mask\t\t$network_masklen\t\t$route_type\t\t$AS_number\n";
    }
}

