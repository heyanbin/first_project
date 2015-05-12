#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;
use Getopt::Long;
#use List::AllUtils qw(min max);
my $version='1.0';
my ($help,$file,$chr_len,$bin_size,$output_file,$stat_file); # NOTE!DON'T give the 0 value, it's wrong!
#the file contain SNP info on certain chromosome 
GetOptions(
		'help'			=> \$help,
		'file|f=s'			=> \$file,
		'chr_length|l=i'	=> \$chr_len,
		'bin_size|b=i'		=> \$bin_size,
		'output_file|o=s'	=> \$output_file,
		'stat_file|s=s'		=> \$stat_file,)	or die("Error in command line arguments\n");

if(defined($help)){&usage;exit(0);}
if(!defined($output_file)){print "Output file not specified on the command line.(-o file)\n";exit(0);};
if(!defined($stat_file)){print "Statistics file not specified on the command line.(-s file)\n";exit(0);};
if(!defined($bin_size)){print "Bin size not specified on the command line.(-b number)\n";exit(0);};
if(!defined($chr_len)){print "You should specify chromosome length on the command line.(-l number)\n";exit(0);};

open IN1,"<$file" or die "can not open $file";
open OUT1,">$output_file" or die "can not open $output_file";
open OUT2,">$stat_file" or die "can not open $stat_file";
print OUT1 "#start_pos\tend_pos\tSNP_info\n";
print OUT2 "#start_pos\tend_pos\tcount\n";
my %pos_hash;
while(<IN1>){
	next if/^#/;
    #chomp(my $tmp1=$_);
    my @a=split(/\s+/,$_);
	#my $int=int($a[2]);
    $pos_hash{$a[1]}=$_;   #Here, make sure the extracted element is the pos of SNP
}
my $start=0;
my $end=0;
my $num=$chr_len/$bin_size;
for(my $i=0;$i<=$num;$i++){
	$start=$i*$bin_size;
	$end=($i+1)*$bin_size;
	my $tmp=0;
	my $center=$start+($bin_size/2);  #close to center of every bin.
	my $count=0;
	my %tmp_hash=();
	my @abs=();
	foreach $tmp (keys%pos_hash){
		if($tmp>$start && $tmp<=$end){  
			my $dist=abs($tmp-$center);
			push(@abs,$dist); #weak in the same distance of SNPs to center
			$tmp_hash{$dist}=$pos_hash{$tmp};
			$count+=1;
		}
	}
	my $min_abs=&min(@abs);  #some min_abs is zero, because the abs array may be empty, So here you may get info:"Use of uninitialized value $min_abs in hash element".
	if(exists $tmp_hash{$min_abs}){
		print OUT1 "$start\t$end\t$tmp_hash{$min_abs}"; 
	} else {
		print OUT1 "$start\t$end\tNA\n";
	}
	print OUT2 "$start\t$end\t$count\n";
}
close IN1;
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

Usage:  perl get_uniform_SNPs_on_chr.pl [-h/--help] -f SNP_file -l chr_length -b bin_size -o output_file -s stat_file 

OPTIONS:
	--help 		  | -h		Display the help message and quit.
	--SNP_file 	  | -f 		Specify file contain SNPs info.
	--chr_len     | -l		Specify chromosome length
	--bin_size    | -b		Specify a bin size to separate SNPs by chromosome position.
	--output_file | -o		Specify output_file.
	--stat_file   | -s 		Specify statistics file.

NOTES:
First: If you Specify different SNP_file, you should make sure generating the right pos_hash .
Second:We specify the statistics file in order to subsequent analysis for generating most uniform SNPs on chromosome.

DISCRIPTION:
With this script, you can get the uniform SNPs on chromosome, but sometimes you need the statistics file for generating most uniform SNPs on chromosome.
This script used for the position info of SNP is in the second column.

SNP_file can be like:

#CHROM   POS     .	.	.
  1      9634    .	.	.

Output_file:
#start_pos	end_pos		SNP_info
	0		40000		1 9634  . A G 0.24232 0.24232
	40000	80000		1 54231 . G T 0.291619 0.291619

Statistics file:
#start_pos	end_pos count
0       40000   30
40000   80000   0            #We should be pay attention to this window.
80000   120000  74

=================================================================================
END
	print $usage;
}
