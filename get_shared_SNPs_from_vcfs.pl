#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;
use Getopt::Long;
my $version='1.0';
my @vcf_files=();
my ($help,$directory,$output_file); 
GetOptions(
		'help'			        => \$help, 
		'vcf_files|v=s{2,}'		=> \@vcf_files,
		'directory|d=s'			=> \$directory,
		'output_file|o=s'		=> \$output_file,)  
	or die("Error in command line arguments\n");
 if(defined($help)) {
     &usage;
     exit(0);
 }
if(!defined($output_file)){print "Output file not specified on the command line.\n";exit(0);};
if(@vcf_files){
	&get_from_vcf_files(@vcf_files);
	} else { 
		if(defined($directory)){
			&get_from_dir($directory);
			} else {
			print "Please input \"-vcf vcf_file1 vcf_file2 ...\" or a directory(containing at least two vcf files)";
			}
		}
sub get_from_vcf_files{
	no warnings;  
	my $in1=$vcf_files[0];
	my $output =$output_file;
	my $n_vcfs=@vcf_files;
	print "You inputed $n_vcfs files. Start processing...\n";
	print "$in1 is the first file used for creating hash.\n";
	for(my $j=1; $j<@vcf_files;$j++){
        my %hash;
        open IN1,"<$in1" or die "can not open $in1";
        while(<IN1>){
            next if/^##/;
            chomp(my $tmp1=$_);
            my @a=split(/\s+/,$tmp1);
            my @aa=($a[0]."_".$a[1],$a[4]); #used the columns:chr_pos alt  to creat a 2d-hash
            $hash{$aa[0]}{$aa[1]}=1;
        }
		print "Hash has been created in loop $j\n";
		close IN1;
		$in1=$output;
		open (IN2,"<${vcf_files[$j]}") or die "can not open $vcf_files[$j]\n";
		open OUT,">$in1" or die "can not write in $in1";
		print "$directory/$vcf_files[$j] is being processed...\n";
		while(<IN2>){
            if(/^##/){
				print OUT $_;
				next;
            }
			chomp(my $tmp2=$_);
			my @b=split(/\s+/,$tmp2);
			my $len=@b-9;
			my @bb=($b[0]."_".$b[1],$b[4]);
			if(exists $hash{$bb[0]}{$bb[1]}){
					print OUT "$b[0]\t$b[1]\t$b[2]\t$b[3]\t$b[4]\t$b[5]\t.\t.\t.\n";
			}
		}
		print "$directory/$vcf_files[$j] is done!\n";
        close IN2;
        close OUT;
	}
}
sub get_from_dir{
	opendir (HAND,"$directory") or die "Error! Can not open the dir.";
	print "Wait! The directory($directory) you inputed starts being processed...\n";
	my @files=();
	@files=grep(/\.vcf/, readdir(HAND));
	closedir HAND,or die "$!\n";
	my $in1="$directory/$files[0]";
	my $output ="$directory/$output_file";
	print "$in1 is the first file used for creating hash.\n";
  for(my $j=1; $j<@files;$j++){
        my %hash;
        open IN1,"<$in1" or die "can not open $in1";  # !The file you got is under the $directory
        while(<IN1>){
                next if/^##/;
                chomp(my $tmp1=$_);
                my @a=split(/\s+/,$tmp1);
                my @aa=($a[0]."_".$a[1],$a[4]); #used the columns:chr_pos alt  to creat a 2d-hash
                $hash{$aa[0]}{$aa[1]}=1;
        }
		print "Hash has been created in loop $j\n";
		close IN1;
		$in1=$output;
		open (IN2,"$directory/$files[$j]") or die "can not open $files[$j]";
		open OUT,">$in1" or die "can not write in $in1";
		print "$directory/$files[$j] is being processed...\n";
		while(<IN2>){
            if(/^##/){
            print OUT $_;
            next;
            }
			chomp(my $tmp2=$_);
			my @b=split(/\s+/,$tmp2);
			#print "$b[7]\n";
			my $len=@b-9;
			my @bb=($b[0]."_".$b[1],$b[4]);
			if(exists $hash{$bb[0]}{$bb[1]}){
					print OUT "$b[0]\t$b[1]\t$b[2]\t$b[3]\t$b[4]\t$b[5]\t.\t.\t.\n";
			}
		}
		print "$directory/$files[$j] is done!\n";
        close IN2;
        close OUT;
	}
}
sub usage {
     my $usage =<<END;
	 
=================================================================================

Version:$version
Author: Lv LH(laihui126cn\@126.com)

Usage:  perl get_shared_SNPs_from_vcfs.pl [-h/--help] -d dir -o output_file 
		perl get_shared_SNPs_from_vcfs.pl [-h/--help] -v A.vcf B.vcf [...] -o output_file 

OPTIONS:
	--help | -h				Display the help message and quit.
	--vcf_files   | -v		Specify vcf_files
	--directory   | -d		Specify a dir containing vcf files
	--output_file | -o		Specify output_file

NOTES:
First: If -d specified, the directory should contain at least two vcf files.
Second: If -v specified, at least two vcf files needed.

DISCRIPTION:
With this script, you can get the shared SNPs from many vcf files(>=2).

They are common vcf like:
       ##fileformat=VCFv4.1
       ##samtoolsVersion=0.1.19-44428cd
       ##contig=<ID=1,length=315321322>
       #CHROM  POS     ID      REF     ALT ......
And the output file containing shared SNPs like:
#CHROM   POS     ID      REF     ALT   .	.	.
  1      9634     .       C       T    .	.	.

=================================================================================
END
	print $usage;
}
