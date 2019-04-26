#!/bin/env perl

use strict;
use warnings;

my $pipedir = '~/git/ilmn_spades';

my %p = ();
my @stage = (
    glob("./src/*.fastq")
);
foreach my $file (@stage){
    my @p = split(/\// , $file);
    my @u = split(/_+/, $p[-1]);
    my $sid = $u[0];
    #$sid = 'SID' . $sid;
    if($file =~ m/R1/){
	$p{$sid}{'left'} = $file;
    }elsif($file =~ m/R2/){
	$p{$sid}{'right'} = $file;
    }
}
foreach my $s (keys %p){
    unless(-e $s.'-spades.fna'){
	system("perl $pipedir/spades_pipe.pl $p{$s}{'left'} $p{$s}{'right'} $s");
	## Optional cleanup
	my @torm = ('fp*');
	foreach(@torm){
	    system("rm $_");
	}
    }
}
