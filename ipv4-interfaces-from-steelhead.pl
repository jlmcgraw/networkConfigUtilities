#!/usr/bin/perl
#
# takes text from a Riverbed Steelhead running config
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
    if ( $_ =~ /^\s*hostname / ) {

        # split that line on the whitespace character
        @hostnameFields = split /\s+/, $_;

        # hostname is the element after the "space".
        $hostname = uc $hostnameFields[2];

        #remove quotemarks
        $hostname =~ s/"//g;
    }

    # identify lines with "interface " at the beginning
    if ( $_ =~ /^\s*interface.*ip address (?:[0-9]{1,3}\.){3}[0-9]{1,3}/ ) {

        #split the good lines into space-separated fields
        @fields = split /\s+/, $_;

        #substitute - for / and : in dns names
        #$fields[1]=~s/\/|:/-/g;

        #print in "ipaddr hostname-interface" format
        $int_name = $fields[2];
        $ip_addr  = $fields[5];
        print "$ip_addr\t\t$hostname-$int_name\n";
    }
}
