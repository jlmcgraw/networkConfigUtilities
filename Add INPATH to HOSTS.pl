#!/usr/bin/perl

#Test whether every IP in a HOSTS file lies within any INPATH interface subnet in a second file
#
#Pseudocode:
#For each IP in HOST file
#	For each INPATH entry in inpath listl
#		IS IP in INPATH subnet
#			Yes, add INPATH to existing description
#			No, next INPATH entry
use warnings;
use strict;
use NetAddr::IP;

my $filename1 = 'hosts';
my $filename2 = 'inpaths.txt';

open( my $fh1, '<:encoding(UTF-8)', $filename1 )
  or die "Could not open hosts file '$filename1' $!";

open( my $fh2, '<:encoding(UTF-8)', $filename2 )
  or die "Could not open inpath file '$filename2' $!";

#Read in entire hosts file to array
my @hosts = <$fh1>;

#Read in entire file of inpath interfaces to array
#Format: 10.80.242.53/29	ATWTAI-OFFCW01-inpath0_0
my @inpaths = <$fh2>;

#Iterate over each item/line in the hosts array
foreach (@hosts) {

    #Split the line into fields based on whitespace
    my @hostfields = split /\s+/, $_;

    #Host IP address is field 0
    my $HostIPAddress = NetAddr::IP->new("$hostfields[0]");

    #Iterate of each item/line in the inpaths array
    foreach (@inpaths) {

        #split the line into whitespace separated fields
        my @inpathfields = split /\s+/, $_;

        #element zero in the line is address/netmask of an inpath interface
        my $InpathIPAddress = NetAddr::IP->new("$inpathfields[0]");

       #If host IP is within the subnet of the inpath interface print out a line
        if ( $HostIPAddress->within($InpathIPAddress) ) {
            print "$hostfields[0]\t$hostfields[1]-$inpathfields[1]\n";
        }
    }
}

