#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;
use Getopt::Long;
my $version='1.0';
my ($help,$stat1_file,$SNP_file,$chr_len,$bin_size,$output_file,$stat2_file); 
#the file contain SNP info on certain chromosome 
GetOptions(
		'help'	        	=> \$help,
		'stat_file|s1=s'	=> \$stat1_file,
		'SNP_file|f=s'		=> \$SNP_file,
		'chr_length|l=i'	=> \$chr_len,
		'bin_size|b=i'		=> \$bin_size,
		'output_file|o=s'	=> \$output_file,
		'stat2_file|s2=s'	=> \$stat2_file,)	or die("Error in command line arguments\n");

if(defined($help)){&usage;exit(0);}
if(!defined($output_file)){print "Output file not specified on the command line.(-o file)\n";exit(0);};
if(!defined($stat1_file)){print "Last statistics file not specified on the command line.(-s file)\n";exit(0);};
if(!defined($stat2_file)){print "New statistics file not specified on the command line.(-s file)\n";exit(0);};
if(!defined($bin_size)){print "Bin size not specified on the command line.(-b number)\n";exit(0);};
if(!defined($chr_len)){print "You should specify chromosome length on the command line.(-l number)\n";exit(0);};


open IN1,"<$SNP_file" or die "can ont open the $SNP_file";
open IN2,"<$stat1_file" or die "can not open $stat1_file";
open OUT1,">$output_file" or die "can not open $output_file";
open OUT2,">$stat2_file" or die "can not open $stat2_file";
print OUT1 "#start_pos\tend_pos\tSNP_info\n";
print OUT2 "#start_pos\tend_pos\tcount\n";

my %pos_hash;
while(<IN1>){
	next if/^#/;
    my @b=split(/\s+/,$_);
    $pos_hash{$b[2]}=$_;    # NOTE: Make sure which column is the position of SNP.
}

my $start=0;
my $end=0;
while(<IN2>){
	next if/^#/;
    my @a=split(/\s+/,$_);
	if(int($a[2])==0){
		$start=int($a[0]);
		$end=int($a[1]);
		my $tmp=0;
		my $center=$start+($bin_size/2);
		my %tmp_hash=();
		my $count=0;
		my @abs=();
		foreach $tmp (keys%pos_hash){
			if($tmp>$start && $tmp<=$end){  
				my $dist=abs($tmp-$center);
				push(@abs,$dist); #weak in the same distance of SNPs to center
				$tmp_hash{$dist}=$pos_hash{$tmp};
				$count+=1;
			}
		}
			my $min_abs=&min(@abs); 
		if(exists $tmp_hash{$min_abs}){
			print OUT1 "$start\t$end\t$tmp_hash{$min_abs}"; 
		} else {
			print OUT1 "$start\t$end\tNA\n";
		}
		print OUT2 "$start\t$end\t$count\n";
	}
}

close IN1;
close IN2;
close OUT1;
close OUT2;

sub min{
		my $currentMin=shift @_;
		foreach (@_){
			if($_<$currentMin){
				$currentMin=$_;
			}
		}
	return $currentMin;
}

sub usage{
	     my $usage =<<END;
	 
=================================================================================

Version:$version
Author: Lv LH(laihui126cn\@126.com)

Usage:  perl make_more_uniform_on_chr.pl [-h/--help] -s1 last_stat_file -f SNP_file -l chr_length -b bin_size -o output_file -s stat_file 

OPTIONS:
	--help     | -h		Display the help message and quit.
	--stat1_file  | -s1	Specify last stat file generated from 16_0_get_uniform_SNPs_on_chr script.
	--SNP_file    | -f 	Specify file contain SNPs info.
	--chr_len     | -l	Specify chromosome length
	--bin_size    | -b	Specify a bin size to separate SNPs by chromosome position.
	--output_file | -o	Specify output_file.
	--stat2_file  | -s2	Specify new statistics file.

DISCRIPTION:
We use the stat_file generated from 16_0_get_uniform_SNPs_on_chr script, some intervals in last stat_file got the zero SNP.
We need fill them with new SNP_file.

This script only worked on some intervals with zero SNP.

SNP_file can be like:

#CHROM   POS     .	.	.
  1      9634    .	.	.

Output_file:
#start_pos	end_pos		SNP_info
0   40000   1 9634  . A G 0.24232 0.24232
40000   80000   1 54231 . G T 0.291619 0.291619

New Statistics file:
#start_pos	end_pos count
    0       40000   30
    40000   80000   2            
    80000   120000  74

=================================================================================
END
	print $usage;
}
