#!/bin/env perl

use strict;
use warnings;
use Cwd 'abs_path';

## usage:  perl mcpipe.pl FWD.fq REV.fq prefix

my $preprocess = 1;
my $k = 31;
my $threads = 38;

## Setup script path
my $script_dir = abs_path($0);
$script_dir =~ s/\/mcpipe\.pl//;

## Parse args
my ($fwd, $rev, $pref) = (shift, shift, shift);

if($preprocess==0){
    ## SPADES
    system("spades.py -1 $fwd -2 $rev -t $threads -o $pref-spades");
}else{
    ## Previous pipeline...Musket-->Flash
    ## Musket
    #system("musket -p $threads -inorder -omulti $pref.musket -k $k 536870912 $fwd $rev");
    #system("mv $pref.musket.0 $pref.musket.0.fastq");
    #system("mv $pref.musket.1 $pref.musket.1.fastq");
    ## Flash pairs
    #system("flash -t $threads -o $pref $pref.musket.0.fastq $pref.musket.1.fastq");
    ## SPADES
    #system("spades.py --pe1-1 $pref.notCombined_1.fastq --pe1-2 $pref.notCombined_2.fastq --s2 $pref.extendedFrags.fastq -t $threads -o $pref-spades");
    
    ## New pipeline...fastp
    my $t = 8;
    $t = $threads if($threads < 8);
    system("fastp --in1 $fwd --out1 fp1.$pref.fq --in2 $rev --out2 fp2.$pref.fq -h fp.$pref.html -j fp.$pref.json -w $t");
    system("spades.py --pe1-1 fp1.$pref.fq --pe1-2 fp2.$pref.fq -t $threads -o $pref-spades");
    
    ## Rename
    system("cp $pref-spades/contigs.fasta ./$pref-spades.fna");
}
