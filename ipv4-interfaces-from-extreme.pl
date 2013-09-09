#!/usr/bin/perl
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

while (<>) {

    chomp;    # remove newline characters

    # find the line with the hostname in it by searching
    # for the "hostname " string
    # this assumes hostname comes before interface configurations
    if ( $_ =~ /^configure snmp sysName/ ) {

        #configure snmp sysName "ndc-tas-sw-b11-blackdiamond-1"
        # split that line on the whitespace character
        @hostnameFields = split /\s+/, $_;

        # hostname is the 4th element.
        $hostname = uc $hostnameFields[3];

        #remove quotemarks
        $hostname =~ s/"//g;
    }

    # identify lines with "configure vlan" at the beginning
    if ( $_ =~
/^configure vlan.*ipaddress (?:[0-9]{1,3}\.){3}[0-9]{1,3} (?:[0-9]{1,3}\.){3}[0-9]{1,3}/
      )
    {

        #configure vlan "production" ipaddress 10.151.32.8 255.255.240.0
        #split the good lines into space-separated fields
        @fields = split /\s+/, $_;

        #substitute - for / and : in dns names
        $fields[1] =~ s/\/|:/-/g;

        #print in "ipaddr hostname-interface" format
        $int_name = $fields[2];

        #remove quotemarks from interface name
        $int_name =~ s/"//g;
        $ip_addr = $fields[4];
        print "$ip_addr\t\t$hostname-$int_name\n";
    }

    # This section handles HSRP configurations
    # identify lines with "standby # ip #.#.#.#" in them
    if ( $_ =~ /^\s*standby [0-9]{1,3} ip (?:[0-9]{1,3}\.){3}[0-9]{1,3}/ ) {

        #strip leading whitespace
        $_ =~ s/^\s+//;

#split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields       = split /\s+|\//, $_;
        $group_number = $fields[1];
        $ip_addr      = $fields[3];
        print "$ip_addr\t\t$hostname-$int_name-HSRP$group_number\n";
    }

    # This section handles GLBP configurations
    # identify lines with "glbp # ip #.#.#.#" in them
    if ( $_ =~ /^\s*glbp [0-9]{1,3} ip (?:[0-9]{1,3}\.){3}[0-9]{1,3}/ ) {

        #strip leading whitespace
        $_ =~ s/^\s+//;

#split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields       = split /\s+|\//, $_;
        $group_number = $fields[1];
        $ip_addr      = $fields[3];
        print "$ip_addr\t\t$hostname-$int_name-GLBP$group_number\n";
    }

    # This section handles IPv6 configurations
    # identify lines with "ipv6 address" in them
    if ( $_ =~ /^\s*ipv6 address/ ) {

        #strip leading whitespace
        $_ =~ s/^\s+//;

#split the good lines into space or separated fields (nexus format is #.#.#.#/mask)
        @fields = split /\s+/, $_;
        $ipv6_addr = $fields[2];
        print "$ipv6_addr\t\t$hostname-$int_name\n";
    }
}

