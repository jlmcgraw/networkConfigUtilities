#!/usr/bin/perl
#
# takes text from a Riverbed Steelhead running config
# and produces an outfile with information about the INPATH interfaces
# You can use xxx to merge this file with your existing hosts file so that
# tac ./configuration_files/Steelheads/* | ./inpath-interfaces-and-subnets-from-steelhead.pl > inpaths.txt

while (<>) {

    chomp;    # remove newline characters

    # find the line with the hostname in it by searching
    # for the "hostname " string
    # this assumes hostname comes before interface configurations, which it will if you use TAC instead of CAT to pipe the input
    if ( $_ =~ /^\s*hostname / ) {

        # split that line on the whitespace character
        @hostnameFields = split /\s+/, $_;

        # the hostname is the element after the "space".
        $hostname = uc $hostnameFields[2];

        # remove quotemarks
        $hostname =~ s/"//g;
    }

    # identify lines with "interface inpath" at the beginning
    if ( $_ =~
        /^\s*interface inpath\d_\d ip address (?:[0-9]{1,3}\.){3}[0-9]{1,3}/ )
    {

        #split the good lines into space-separated fields
        @fields = split /\s+/, $_;

        #substitute - for / and : in dns names
        #$fields[1]=~s/\/|:/-/g;

        #print in "ipaddr hostname-interface" format
        $int_name = $fields[2];
        $ip_addr  = $fields[5];
        $netmask  = $fields[6];
        print "$ip_addr$netmask\t$hostname-$int_name\n";
    }
}
