#!/usr/bin/perl

while (<>) {

    chomp;    # remove newline characters

    # find the line with the hostname in it by searching
    # for the "#" character
    # catowwtorca01s05

    #if ($_=~/\#/) {
    #if ($_=~/^\w{16}\#/) {
    #    # split that line on the # character
    #    @hostnameFields = split /\#/,$_;
    #    # hostname is the first element before the first .
    #    $hostname=uc $hostnameFields[0];
    #
    #}

    #split the good lines into space-separated fields
    @fields = split /\s+/, $_;

    #find RFC1918-like addresses only
    # if ($fields[1]=~/^10\.|172\.|192\./){

    # remove subnet mask from IP addresses
    #$fields[1]=~s/\/\d\d//g;

    # print in "ipaddr hostname-interface" format
    print "$fields[1]\n";

    #     }
}
