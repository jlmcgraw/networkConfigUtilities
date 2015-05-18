#!/usr/bin/perl

use warnings;
use strict;
use autodie;

use NetAddr::IP;

use v5.10;
#
# Gather the networks advertised by various routing protocols via "network" statements
# Obviously this doesn't fully represent what is actually advertised but it's a start
#

my ( @hostnameFields, @fields );
my ( $hostname, $route_type, $AS_number, $ip_addr, $network_mask,
    $network_masklen );
my ($subnet);

my $ip4Address =
  qr/([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])/m;
my $netmask = qr//m;
while (<>) {

    chomp;    # remove newline characters

    # find the line with the hostname in it by searching
    # for the "hostname " string
    # this assumes hostname comes before interface configurations
    if ( $_ =~ /^hostname / ) {

        #Reset variables after each new hostname just in case
        $hostname = $route_type = $AS_number = $ip_addr = $network_mask =
          $network_masklen = $subnet = "";

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

        #split the good lines into space or "/" separated fields (nexus format is #.#.#.#/mask)
        @fields = split /\s+|\//, $_;

        #Create an new subnet from proper fields
        $subnet = NetAddr::IP->new("$fields[1]/$fields[3]");

        if ($subnet) {

            # $ip_addr      = $fields[1];
            # $network_mask = $fields[3];

            #Comment next line out to not use the NetAddr object
            $ip_addr         = $subnet->addr;
            $network_mask    = $subnet->mask;
            $network_masklen = $subnet->masklen;

            say
              "$hostname,$ip_addr,$network_mask,$network_masklen,$route_type,$AS_number";
        }
        else {
            say
              "Network w/ mask1: couldn't create subnet for $fields[1]/$fields[2]";
        }
    }

    # identify lines with "network #.#.#.# #.#.#.#" in them (EIGRP, OSPF, RIP routes)
    if ( $_ =~
        /^\s*network ((?:\d{1,3}\.){3}\d{1,3})\s+((?:\d{1,3}\.){3}\d{1,3})\s*$/
      )
    {
        say "$1 $2";

        #strip leading whitespace
        $_ =~ s/^\s+//;

        #split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields = split /\s+|\//, $_;

        #This little bit of magic inverts the wildcard mask to a netmask.  Copied from somewhere on the net
        my $mask_wild_dotted = $fields[2];
        my $mask_wild_packed = pack 'C4', split /\./, $mask_wild_dotted;
        my $mask_norm_packed = ~$mask_wild_packed;
        my $mask_norm_dotted = join '.', unpack 'C4', $mask_norm_packed;

        # if ($fields[1] && $mask_norm_dotted) {
        # print $fields[1];
        # print "/";
        # print $mask_norm_dotted;
        # print "\n";

        #Create an new subnet from proper fields
        $subnet = NetAddr::IP->new("$fields[1]/$mask_norm_dotted");

        # $ip_addr      = $fields[1];
        # $network_mask = $fields[2];
        if ($subnet) {

            #Comment next lines out to not use the NetAddr object
            $ip_addr         = $subnet->addr;
            $network_mask    = $subnet->mask;   #Change to masklen to get length
            $network_masklen = $subnet->masklen;
            say
              "$hostname,$ip_addr,$network_mask,$network_masklen,$route_type,$AS_number";

        }
        else {

            say
              "Network w/ mask2: couldn't create subnet for $fields[1]/$fields[2]";
        }
    }

    # identify lines with "network #.#.#.#/##" in them (Nexus EIGRP, OSPF, RIP routes)
    if ( $_ =~ /^\s*network (?:\d{1,3}\.){3}\d{1,3}\/\d\d/ ) {

        #strip leading whitespace
        $_ =~ s/^\s+//;

        #split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields = split /\s+|\//, $_;

        #Create an new subnet from proper fields
        $subnet = NetAddr::IP->new("$fields[1]/$fields[2]");
        if ($subnet) {

            # $ip_addr      = $fields[1];
            # $network_mask = $fields[2];

            #Comment next lines out to not use the NetAddr object
            $ip_addr         = $subnet->addr;
            $network_mask    = $subnet->mask;
            $network_masklen = $subnet->masklen;

            say
              "$hostname,$ip_addr,$network_mask,$network_masklen,$route_type,$AS_number";
        }
        else {
            say
              "Network w/ CIDR: couldn't create subnet for $fields[1]/$fields[2]";
        }
    }

    # identify lines with "ip address #.#.#.#" in them
    if ( $_ =~ /\s+ip address\s$ip4Address.*$/i ) {

        #strip leading whitespace
        $_ =~ s/^\s+//;

        #split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields = split /\s+|\//, $_;

        # $ip_addr = $fields[2];
        # $ip_mask = $fields[3];
        # print $fields[2];
        # print $fields[3];

        #Create an new subnet from proper fields
        $subnet = NetAddr::IP->new("$fields[2]/$fields[3]");

        if ($subnet) {

            #Comment next line out to not use the NetAddr object
            $ip_addr         = $subnet->addr;
            $network_mask    = $subnet->mask;
            $network_masklen = $subnet->masklen;
            $route_type      = "Connected";        #routing process
            $AS_number       = "";                 #AS number
            say
              "$hostname,$ip_addr,$network_mask,$network_masklen,$route_type,$AS_number";
        }
        else {
            # say @fields;
            say "IP Address: couldn't create subnet for $fields[1]/$fields[2]";
        }
    }
}
