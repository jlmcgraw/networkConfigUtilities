#!/usr/bin/perl
#
# takes text from a Cisco Nexus config
# and produces an output for import into DNS or host file
# this makes traceroutes more readable
#
# this really only works with IPv4
#

while (<>) {

    chomp;    # remove newline characters

    # find the line with the hostname in it by searching
    # for the "hostname " string
    # this assumes hostname comes before interface configurations
    if ( $_ =~ /^(hostname)|(switchname) \w+/ ) {

        # split that line on the whitespace character
        @hostnameFields = split /\s+/, $_;

        # hostname is the element after the "space".
        $hostname = uc $hostnameFields[1];

    }

    # identify lines with "interface " at the beginning
    if ( $_ =~ /^interface / ) {

        #split the good lines into space-separated fields
        @fields = split /\s+/, $_;

        #substitute - for / and : in dns names
        $fields[1] =~ s/\/|:/-/g;

        #set the variable
        $int_name = $fields[1];
    }

    if ( $_ =~ /^\s+hsrp \d+/ ) {

        #strip leading whitespace
        $_ =~ s/^\s+//;

        #split the good lines into space-separated fields
        @fields = split /\s+/, $_;

        #substitute - for / and : in dns names
        $fields[1] =~ s/\/|:/-/g;

        #set the variable
        $hsrp_group = $fields[1];
    }

    # identify lines with "ip address #.#.#.#" in them
    if ( $_ =~ /^\s*ip address (?:[0-9]{1,3}\.){3}[0-9]{1,3}/ ) {

        #strip leading whitespace
        $_ =~ s/^\s+//;

        #split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields = split /\s+|\//, $_;
        $ip_addr = $fields[2];
        print "$ip_addr\t\t$hostname-$int_name\n";
    }

    # This section handles HSRP configurations
    # identify lines with "standby # ip #.#.#.#" in them
    if ( $_ =~ /^\s*ip (?:[0-9]{1,3}\.){3}[0-9]{1,3}/ ) {

        #strip leading whitespace
        $_ =~ s/^\s+//;

        #split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields = split /\s+|\//, $_;
        $ip_addr = $fields[1];
        print "$ip_addr\t\t$hostname-$int_name-HSRP$hsrp_group\n";
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

