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
    # for the "set hostname xxxxx" string
    # this assumes hostname comes before interface configurations
    if ( $_ =~ /^set hostname/ ) {

        # split that line on the whitespace character
        @hostnameFields = split /\s+/, $_;

        # hostname is the element after the "space".
        $hostname = uc $hostnameFields[2];

    }

    # identify lines with "set interface ethernet4/1 ip 10.155.1.100/29" at the beginning
    if ( $_ =~ /^set interface .* ip (?:[0-9]{1,3}\.){3}[0-9]{1,3}\// ) {

        #split the matching lines into space-separated fields
        @fields = split /\s+/, $_;

        #substitute - for / and : in interface names
        $fields[2] =~ s/\/|:/-/g;

        #print in "ipaddr hostname-interface" format
        $int_name = $fields[2];

        #split the good lines into space or "/"separated fields (nexus format is #.#.#.#/mask)
        @fields2 = split /\s+|\//, $fields[4];
        $ip_addr = $fields2[0];
        print "$ip_addr\t\t$hostname-$int_name\n";
    }

}

