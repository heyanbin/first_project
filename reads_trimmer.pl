#!/usr/perl

#该程序用于修剪fastq文件(里面reads长度不一)中，任意长度的碱基
#输入四个参数，一个是读取的文件名，一个是多长的reads需要修剪，一个是修剪掉多少bp，一个输出文件名

my($file1,$trimReadLen,$trimNum,$file2)=@ARGV;
open IN,"<$file1" or die "can't open the input file";
open OUT,">>$file2" or die "please enter the fourth parameter!";
#my $a=$trimReadLen*1;
#my $b=$trimNum*1;

while (<IN>) {
	print OUT ; #第一行直接打印
	$_ = <IN>; #读入第二行，下面开始判定
	chomp;
	$len=length($_);
	if($len=$trimReadLen){
	  $tmp=substr($_,0,($trimReadLen-$trimNum));#修剪特定长度的read，末尾的指定碱基数目
	  print OUT "$tmp\n";  
	} else {
	  print OUT "$_\n"; #否则原样打印出来#
	}
	$_ = <IN>; #读入第三行
	print OUT;
	$_ = <IN>; #读入第四行，下面开始判定
	chomp;
	$len=length($_);
	if($len=$trimReadLen){
	  $tmp=substr($_,0,($trimReadLen-$trimNum));#修剪特定长度的read，末尾的指定碱基数目
	  print OUT "$tmp\n";  
	} else {
	  print OUT "$_\n"; #否则原样打印出来#
	}
}
close IN;
close OUT;
