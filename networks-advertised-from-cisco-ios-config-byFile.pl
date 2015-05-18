#!/usr/bin/perl

#
# Gather the networks advertised by various routing protocols via "network" statements
# Obviously this doesn't fully represent what is actually advertised but it's a start

#TODO Make use of the routing process sections code, we're not doing that yet

#Yes, this code is reading in each file twice

use warnings;
use strict;
use autodie;
use NetAddr::IP;
use File::Slurp;
use Getopt::Std;
use File::Basename;
use vars qw/ %opt /;

use v5.18;
use Params::Validate qw(:all);

#don't buffer stdout
$| = 1;

exit main(@ARGV);

sub main {
    my $bandwidth;
    my $description;
    my $interface;
    my $hostname;
    my $ip_addr;
    my $network_mask;
    my $network_masklen;
    my $route_type;
    my $AS_number;
    my $ip_addr_bigint;
    my $isRfc1918;
    my $range;
    my $subnet;
    my @fields;
    my $opt_string = 'v';

    my $arg_num = scalar @ARGV;

    unless ( getopts( "$opt_string", \%opt ) ) {
        say "Usage: $0 -v <config file>\n";
        say "-v: enable debug output";
        exit(1);
    }
    if ( $arg_num < 1 ) {
        say "Usage: $0 -v <config file>\n";
        say "-v: enable debug output";
        exit(1);
    }

    #Get the target data directory from command line options
    my $inputConfigFile = $ARGV[0];

    #Open appropriate data file in the target directory
    my ( $filename, $dir, $ext ) = fileparse( $inputConfigFile, qr/\.[^.]*/ );

    my $file;
    open $file, '<', $inputConfigFile or die $!;

    my $debug = $opt{v};

    my $ipv4AddressRegex = qr/(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.
			      (?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.
			      (?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.
			      (?:25[0-5]|2[0-4]\d|[01]?\d\d?)/mx;

    my $ipv4NetmaskRegex = qr/(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.
			      (?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.
			      (?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.
			      (?:25[0-5]|2[0-4]\d|[01]?\d\d?)/mx;

    #Read in entire file
    my $configText = read_file($inputConfigFile);

    #Find hostname
    my $hostnameRegex = qr/^hostname \s+ ([\w\-]+)/mx;
    ($hostname) = $configText =~ /$hostnameRegex/ig;

    #Find routing processes
    my $routingProcessRegex =
      qr/^ \s+ router \s+ (bgp|ospf|eigrp|rip) \s+ (\d+) $/mx;
    my @routingProcesses = $configText =~ /$routingProcessRegex/ig;

    #     say @routingProcesses;

    # my $ipv4BgpNetworkRegex =
    # qr/^\s*network\s+((?:\d{1,3}\.){3}\d{1,3})\s+mask\s+((?:\d{1,3}\.){3}\d{1,3})/smx;

    # my $ipv4NetworkRegex =
    # qr /^\s*network ((?:\d{1,3}\.){3}\d{1,3})\s+((?:\d{1,3}\.){3}\d{1,3})\s*$/smx;

    my $ipv4InterfaceIpAddressRegex =
      qr/^ \s+ ip \s+ address \s+ (?<ip>$ipv4AddressRegex) \s+ (?<mask>$ipv4NetmaskRegex) /mx;

    #Match any interface up to first "!", capturing the intervening text
    my $interfaceRegex = qr/^ interface \s+ (.*?) !/smx;

    #Pull out all config for each routing process (from "router" up to first line beginning with "!"
    my $routingProcessSectionRegex =
      qr/^router \s (?<route_type>(?:bgp|ospf|eigrp|rip)) \s+ (?<AS_number>\d+) (?<process_config>.*?) ^ \! /smx;

    #Array of all interfaces and their config text
    my (@allInterfaces) = $configText =~ /$interfaceRegex/ig;

    #Array of all routing processes and their config text
    my (@routingProcessSections) =
      $configText =~ /$routingProcessSectionRegex/ig;

    #say @routingProcessSections;

    #Find all layer 3 enabled interfaces
    foreach my $interfaceText (@allInterfaces) {

        #Clear old interface information
        $interface = $description = $bandwidth = $route_type = $AS_number =
          $ip_addr = $network_mask = $network_masklen = $subnet = "";

        if ( $interfaceText =~ /^ \s* shutdown $/ixm ) {

            # say "Interface is SHUTDOWN";
            next;
        }

        #Get bandwidth if it's defined for this interface
        ($bandwidth) = $interfaceText =~ m/^ \s+ bandwidth \s+ (\d+) $/ixmg;

        #Get description if it's defined for this interface
        ($description) = $interfaceText =~ m/^ \s+ description \s+ (.*) $/imxg;

        #The very first line of a section, should contain the interface name
        ($interface) = $interfaceText =~ m/\A (.*) \R/imxg;

        #All Ip address and netmask pairs for each interface
        # say $ipv4InterfaceIpAddressRegex;
        my @ipAddresses = $interfaceText =~ /$ipv4InterfaceIpAddressRegex/g;

        #Are any IP addresses defined on this interface?
        if ( !@ipAddresses ) {

            # say "Interface HAS NO IPv4 ADDRESS";
            next;
        }

        #Loop through each ip/mask pair
        for ( my $i = 0 ; $i < 0 + @ipAddresses ; $i = $i + 2 ) {
            my $ip   = $ipAddresses[$i];
            my $mask = $ipAddresses[ $i + 1 ];

            #Create an new subnet from proper fields
            my $subnet = NetAddr::IP->new("$ip/$mask");

            if ($subnet) {

                $ip_addr         = $subnet->addr;
                $network_mask    = $subnet->mask;
                $network_masklen = $subnet->masklen;
                $route_type      = "Connected Interface";    #routing process
                $AS_number       = "";                       #AS number
                $ip_addr_bigint  = $subnet->bigint();
                $isRfc1918       = $subnet->is_rfc1918();
                $range           = $subnet->range();

                if ($description) {

                    #strip leading and trailing whitespace
                    $description =~ s/^\s+//;
                    $description =~ s/\s+$//;

                    $description =~ s/,/-/g;
                }

                #no warnings 'uninitialized';

                # 		say "$hostname,$interface";
                #Remove line breaks from these
                $hostname =~ s/\R//g;
                $interface =~ s/\R//g;

                say
                  "$inputConfigFile,$hostname,$interface,$bandwidth,$description,$ip_addr,$network_mask,$network_masklen,$route_type,$AS_number,$ip_addr_bigint,$isRfc1918,$range";
            }
            else {
                say
                  "IP Address: couldn't create subnet for $ip_addr, mask $network_mask";
            }

        }
    }

    while (<$file>) {

        #The section reads in the file sequentially.  
        #It relies on information being in a particular order in the config
        # identify lines with "router " at the beginning
        given ($_) {
            when ( $_ =~
                  /^router \s+ (?<route_type>(bgp|ospf|eigrp|rip)) \s+ (?<AS_number>\d+) /ix
              )
            {

                #Reset variables after each new routing process just in case
                $interface = $description = $bandwidth = $route_type =
                  $AS_number =
                  $ip_addr = $network_mask = $network_masklen = $subnet = "";

                #Named captures
                $route_type = $+{route_type};    #routing process
                $AS_number  = $+{AS_number};     #AS number

                #             say "$route_type,$AS_number;"
            }

            # identify lines with "network #.#.#.# mask #.#.#.#" in them (BGP routes) and capture what we're interested in
            when ( $_ =~
                  /^ \s* network \s+ (?<ip_addr>$ipv4AddressRegex) \s+ mask \s+ (?<network_mask>$ipv4NetmaskRegex)/ix
              )
            {
                #Named captures
                $ip_addr      = $+{ip_addr};
                $network_mask = $+{network_mask};

                #Create an new subnet from captured info
                $subnet = NetAddr::IP->new("$ip_addr/$network_mask");

                if ($subnet) {

                    $ip_addr         = $subnet->addr;
                    $network_mask    = $subnet->mask;
                    $network_masklen = $subnet->masklen;
                    $ip_addr_bigint  = $subnet->bigint();
                    $isRfc1918       = $subnet->is_rfc1918();
                    $range           = $subnet->range();

                    #                 no warnings 'uninitialized';
                    say
                      "$inputConfigFile,$hostname,$interface,$bandwidth,$description,$ip_addr,$network_mask,$network_masklen,$route_type,$AS_number,$ip_addr_bigint,$isRfc1918,$range";
                }
                else {
                    say
                      "Network w/ mask1: device: $hostname couldn't create subnet for $ip_addr, mask $network_mask";
                }
            }

            # identify lines with "aggregate-address #.#.#.#  #.#.#.#" in them (BGP routes)
            when (
                $_ =~
                  /^ \s* aggregate-address \s+ (?<ip_addr>$ipv4AddressRegex) \s+ (?<network_mask>$ipv4NetmaskRegex)
            /ix
              )
            {
                #Named captures
                $ip_addr      = $+{ip_addr};
                $network_mask = $+{network_mask};

                $subnet = NetAddr::IP->new("$ip_addr/$network_mask");

                if ($subnet) {

                    #Comment next line out to not use the NetAddr object
                    $ip_addr         = $subnet->addr;
                    $network_mask    = $subnet->mask;
                    $network_masklen = $subnet->masklen;
                    $ip_addr_bigint  = $subnet->bigint();
                    $isRfc1918       = $subnet->is_rfc1918();
                    $range           = $subnet->range();

                    
                    #                 no warnings 'uninitialized';
                    say
                      "$inputConfigFile,$hostname,$interface,$bandwidth,$description,$ip_addr,$network_mask,$network_masklen,$route_type-aggregate,$AS_number,$ip_addr_bigint,$isRfc1918,$range";
                }
                else {
                    say
                      "Aggregate network w/ mask: device: $hostname couldn't create subnet for $ip_addr, mask $network_mask";
                }
            }

            # identify lines with "network #.#.#.# #.#.#.#" in them (EIGRP, OSPF, RIP routes)
            when (
                $_ =~
                  /^ \s* network \s+ (?<ip_addr>$ipv4AddressRegex) \s+ (?<network_mask>$ipv4NetmaskRegex)
            /ix
              )
            {
                #Named captures
                $ip_addr      = $+{ip_addr};
                $network_mask = $+{network_mask};

                #say "$1 $2";
                #             #strip leading whitespace
                #             $_ =~ s/^\s+//;
                #
                #             #split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
                #             @fields = split /\s+|\//, $_;

                #This little bit of magic inverts the wildcard mask to a netmask.  Copied from somewhere on the net
                my $mask_wild_dotted = $network_mask;
                my $mask_wild_packed = pack 'C4', split /\./, $mask_wild_dotted;

                my $mask_norm_packed = ~$mask_wild_packed;
                my $mask_norm_dotted = join '.', unpack 'C4', $mask_norm_packed;

                #Create an new subnet from captured info
                $subnet = NetAddr::IP->new("$ip_addr/$mask_norm_dotted");

                if ($subnet) {

                    $ip_addr = $subnet->addr;
                    $network_mask = $subnet->mask;
                    $network_masklen = $subnet->masklen;
                    $ip_addr_bigint  = $subnet->bigint();
                    $isRfc1918       = $subnet->is_rfc1918();
                    $range           = $subnet->range();

                    #                 no warnings 'uninitialized';
                    say
                      "$inputConfigFile,$hostname,$interface,$bandwidth,$description,$ip_addr,$network_mask,$network_masklen,$route_type,$AS_number,$ip_addr_bigint,$isRfc1918,$range";

                }
                else {

                    say
                      "Network w/ inverted mask: device: $hostname couldn't create subnet for $ip_addr/$mask_norm_dotted";
                }
            }

            # identify lines with "network #.#.#.#/##" in them (Nexus EIGRP, OSPF, RIP routes)
            when ( $_ =~
                  /^ \s* network \s+ (?<ip_addr>$ipv4AddressRegex) \/ (?<network_mask>\d\d)/ix
              )
            {
                #Named captures
                $ip_addr      = $+{ip_addr};
                $network_mask = $+{network_mask};

                #Create an new subnet from captured info
                $subnet = NetAddr::IP->new("$ip_addr/$network_mask");
                if ($subnet) {

                    $ip_addr         = $subnet->addr;
                    $network_mask    = $subnet->mask;
                    $network_masklen = $subnet->masklen;
                    $ip_addr_bigint  = $subnet->bigint();
                    $isRfc1918       = $subnet->is_rfc1918();
                    $range           = $subnet->range();

                    #                 no warnings 'uninitialized';

                    say
                      "$inputConfigFile,$hostname,$interface,$bandwidth,$description,$ip_addr,$network_mask,$network_masklen,$route_type,$AS_number,$ip_addr_bigint,$isRfc1918,$range";
                }
                else {
                    say
                      "Network w/ CIDR: device: $hostname couldn't create subnet for $ip_addr, mask $network_mask";
                }
            }

            # identify lines with "network #.#.#.#/##" in them (Nexus EIGRP, OSPF, RIP routes)
            when (
                $_ =~
                  /^ \s* ip \s+ route  \s+ (?<ip_addr>$ipv4AddressRegex) \s+ (?<network_mask>$ipv4NetmaskRegex)
                   /ix
              )
            {
                #Reset variables
                $interface = $description = $bandwidth = $route_type =
                  $AS_number =
                  $ip_addr = $network_mask = $network_masklen = $subnet = "";

                #Named captures
                $ip_addr      = $+{ip_addr};
                $network_mask = $+{network_mask};

                #Create an new subnet from captured info
                $subnet = NetAddr::IP->new("$ip_addr/$network_mask");

                $route_type = "static";

                if ($subnet) {

                    $ip_addr         = $subnet->addr;
                    $network_mask    = $subnet->mask;
                    $network_masklen = $subnet->masklen;
                    $ip_addr_bigint  = $subnet->bigint();
                    $isRfc1918       = $subnet->is_rfc1918();
                    $range           = $subnet->range();

                    no warnings 'uninitialized';

                    say
                      "$inputConfigFile,$hostname,$interface,$bandwidth,$description,$ip_addr,$network_mask,$network_masklen,$route_type,$AS_number,$ip_addr_bigint,$isRfc1918,$range";
                }
                else {
                    say
                      "Network w/ CIDR: device: $hostname couldn't create subnet for $ip_addr, mask $network_mask";
                }
            }
        }
    }
}
