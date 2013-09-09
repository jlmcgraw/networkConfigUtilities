#!/usr/bin/perl
# -*- coding: utf-8 -*-
use warnings;
use strict;

use File::Spec;
use GraphViz2;

# using the peer cones from http://as-rank.caida.org/
#open( peer_file,   "<./data/as-rank.caida.peercones-with-IX.txt" );
#open( asn_file,    "<./data/as-name-nb-120211.txt" );
#open( out_file,    ">./output/as-peer-graph-$ARGV[1].dot" );

#open( asinfo_file, "<./data/as-rank.caida.as-dump-info.txt" );

#, concentrate=> 1, random_start=>1,overlap=>"false"
our $graph = GraphViz2->new(
    global => {
        directed => 0,

        #concentrate  => 1,
        #random_start => 1,
        # overlap      => 'false',
        #layout       => 'fdp'
    }
);
our @as_list = ();
our %as_hash = ();
our ( $line, $as_number );

sub as_to_n {
    my ( $line, @split_line );
    $as_number = $_[0];
    seek asn_file, 0, 0;
    while ( $line = <asn_file> ) {
        if ( $line =~ m/^#/i ) {
            next;
        }
        @split_line = split( / +/, $line );
        if ( "AS$as_number" eq $split_line[0] ) {
            return $split_line[1];
            last;
        }
    }
}

#if ( $ARGV[0] eq 'cc' ) {
#    while ( $line = <asinfo_file> ) {
#        if ( $line !~ m/^#/i ) {
#            @split_line = split( /\|/, $line );
#
#            if ( $split_line[3] eq $ARGV[1] ) {
#                push( @as_list, $split_line[0] );
#            }
#        }
#    }
#}

#if ( $ARGV[0] eq 'asn' ) {
#    @as_list = $ARGV[1];
#}

#foreach (@as_list) {
#    print "AS: $_\n";
#}

# @as_list = '2200';

#while ( $line = <asn_file> ) {
#	#skip lines that begin with "#"
#    if ( $line !~ m/^#/i ) {
#	#split into array on space
#        @split_line = split( / +/, $line );
#        foreach $as_iterator (@as_list) {
#            if ( "AS$as_iterator" eq $split_line[0] ) {
#
#                #print "$as_iterator, $split_line[0]";
#                $as_hash{$as_iterator} = $split_line[1];
#            }
#        }
#    }
#}

#print %as_hash;
# while (($key, $value) = each(%as_hash)){
#      print "$key is named $value\n";
# }
#0			1			2			3				4			5
#Hostname	Local_ID	Local_ASN	Remote_Neighbor	Remote_ID	Remote_ASN
#Add Local_ID to cluster Local_ASN
#Add edge to Remote_ID

open( out_file, ">./ASN-GRAPH.svg" );

while (<>) {
    my @split_line;

    #skip lines that begin with "#"
    if ( $_ =~ m/^#/i ) {
        next;
    }

    #split into array based on whitespace delimiters
    @split_line = split( /\s+/, $_ );

    print "Subgraph: $split_line[2]\n";

    $graph->push_subgraph(
        name  => "cluster$split_line[2]",
        graph => { label => $split_line[2] },

        #node  => { color => 'gray', shape => 'circle' },
    );
    print "local name:$split_line[1] label:$split_line[0]\n";

    #add new node based on local info
    $graph->add_node(
        name  => $split_line[1],
        label => "$split_line[0]",
        shape => 'circle',
        style => 'filled',
        color => 'green',

        #cluster => "$split_line[2]",

        #URL   => "http://bgp.he.net/AS$split_line[$i]"
    );
    $graph->pop_subgraph;

    print "Subgraph: $split_line[5]\n";
    print "remote name:$split_line[4] label:$split_line[3]\n";

    $graph->push_subgraph(
        name  => "cluster$split_line[5]",
        graph => { label => $split_line[5] },

        #node  => { color => 'gray', shape => 'circle' },
    );

    #add new node based on remote info
    $graph->add_node(
        name  => $split_line[4],
        label => "$split_line[3]",
        shape => 'circle',
        style => 'filled',
        color => 'red',

        #cluster => "$split_line[5]",

        #URL   => "http://bgp.he.net/AS$split_line[$i]"
    );
    $graph->pop_subgraph;

    #if ($split_line[2] eq $split_line[5]){
    print "\tedge from $split_line[1] to $split_line[4]\n";
    $graph->add_edge( from => $split_line[1], to => $split_line[4] );

    #}
}

#while ( $line = <peer_file> ) {
#	#skip lines that begin with "#"
#    if ( $line =~ m/^#/i ) {
#        next;
#    }
#	#split $line into arrary on | character
#    @split_line = split( /\|/, $line );
#    $as_relation = $split_line[2];
#    if (
#        !(
#               exists $as_hash{ $split_line[0] }
#            || exists $as_hash{ $split_line[1] }
#        )
#      )
#    {
#        next;
#    }
#
#    for ( $i = 0 ; $i < 2 ; ++$i ) {
#        if ( exists $as_hash{ $split_line[$i] } ) {
#            $graph->add_node(
#                $split_line[$i],
#                label => "$as_hash{$split_line[$i]}",
#                shape => 'box',
#                style => 'filled',
#                color => 'green',
#                URL   => "http://bgp.he.net/AS$split_line[$i]"
#            );
#        }
#        else {
#            $as_name = &as_to_n( $split_line[$i] );
#            $graph->add_node(
#                $split_line[$i],
#                label => "$as_name",
#                shape => 'ellipse',
#                style => 'filled',
#                color => 'red',
#                URL   => "http://bgp.he.net/AS$split_line[$i]"
#            );
#        }
#    }
#    if ( $as_relation == -1 ) {
#        $graph->add_edge( $split_line[0] => $split_line[1] );
#    }
#}
my ($format) = shift || 'dot';
my ($output_file) = shift || File::Spec->catfile( './', "sub.graph.$format" );
$graph->run( format => $format, output_file => $output_file );

#print out_file $graph->as_svg;
