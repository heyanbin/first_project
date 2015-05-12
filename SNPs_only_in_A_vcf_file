#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;
use Getopt::Long;
#script can be used for getting the mutations specific in A vcf file, and not in others(B,C,D,E...), output is only exist in this file. 
my $version='1.0';
my @rest_files=();
my ($help,$a_file,$output_file);
GetOptions(
		'help'	=> \$help,  
		'a_file|a=s'		=> \$a_file,
		'rest_files|r=s{1,}'	=> \@rest_files,
		'output_file|o=s'		=> \$output_file,) 
	or die("Error in command line arguments\n");
 
 if(defined($help)) {
     &usage;
     exit(0);
 }
# arguments must be exist, check them below.
if(!defined($a_file)){ print "A file not specified on the command line.\n";exit(0);};
if(!@rest_files){print "The rest files should be specified.\n";exit(0);};
if(!defined($output_file)){ print "Output file not specified on the command line.\n";exit(0);};
# create the A.vcf file handle
my $ko=$a_file;
open A_FILE,"<$ko" or die "can not read from $ko";
# get hash from subroutine
my %two_d_hash = &get_hash_from_others(@rest_files);
# create the output file handle
my $ok=$output_file;
open OUT,">>$output_file" or die "can not write in OUT1";
# main part
while(<A_FILE>){
	if(/^#/){
		print OUT $_;  #print the vcf header
		next;
	}		
	my @b=();
	my @bb=();
	chomp( my $tmp=$_);
	@b=split(/\s/,$tmp);
	@bb=($b[0]."_".$b[1],$b[4]); #get the chr_pos and alt
	if(!exists $two_d_hash{$bb[0]}{$bb[1]}){
	print OUT $tmp,"\n";
	}
}
sub get_hash_from_others{
	my $count=0;
	my $tmp_file="del_tmp.tmp";
	#cat all the rest files into a tmp file
	open TMP_FILE,">>$tmp_file" or die "can not open $tmp_file";
	while($count<@rest_files){
		open FILE,"<${rest_files[$count]}" or die "can not open $rest_files[$count]";
		while(<FILE>){
			next if/^#/;  #skip the comments lines in vcf file
			my @a=();
			my @aa=();
			chomp( my $tmp1=$_);
			@a=split(/\s/,$tmp1);
			@aa=($a[0],$a[1],$a[4]);  #extract the chr pos and alt from all the rest vcf files
			print TMP_FILE "@aa\n";
		}
		close FILE;
		$count++;
	}
	# sort the tmp file contain all SNPs and uniq them
	`cat $tmp_file | sort -nk1 -nk2 |uniq >> tmp_sorted_uniq.tmp`;  
	my $tmp_sued="tmp_sorted_uniq.tmp";  
	close TMP_FILE;
	open TMP_SORTED,"<$tmp_sued" or die "can not open sorted_uniq tmp file";
	# build the 2d "chr_pos alt" hash
	my %chr_pos_alt=();
	while(<TMP_SORTED>){
		my @cpa=();
		my @cp_a=();
		chomp( my $tmp1=$_);
		@cpa=split(/\s/,$tmp1);
		@cp_a=($cpa[0]."_".$cpa[1],$cpa[2]); #used the columns:chr_pos alt  to creat a 2d-hash
		$chr_pos_alt{$cp_a[0]}{$cp_a[1]}=1;
	}
	close TMP_SORTED;
	`rm del_tmp.tmp tmp_sorted_uniq.tmp`; #remove the two tmp files
	return %chr_pos_alt;
}
sub usage {
     my $usage =<<END;
	 
 #-------------------------------------------#
 # GET THE SPECIFIC MUTIONS IN ONE VCF FILE  #
 #-------------------------------------------#

 version $version
 by Lv LH (laihui126cn\@126.com)

 Usage:
 perl SNPs_only_in_A_vcf_file.pl -a|--a_file A.vcf -r|--rest_files B.vcf [C.vcf ...] -o|--output_file output_file

 Options
 =============
 --help             Display this message and quit
 --a_file| -a 	    [A file]      	Concerned vcf input file 
 --rest_files| -r   [rest files]   	Rest input files to compare
 --output_file|o=s  [output file]   Output file
 Discription:
 With this script, you can get the mutations specific in A vcf file, and not in others(like B,C,D,E...)
 and output file contents are only exist in this file. 

END

    print $usage;
 }
