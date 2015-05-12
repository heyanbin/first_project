#!/usr/bin/perl

#处理的对象是fastq文件，文件格式是4行的，首行为header，且有#分隔
#该脚本用于fastx-toolkit的fastq_quality_filter命令之后，导致原本配对的pair-end fastq1和fastq2文件不再配对，通过该脚本将配对的一一对应导出，不配对的另外输出到文件
#该脚本要求五个参数，两个pair-end fastq的输入文件，两个输出文件名分别存放一一配对的reads，第五个参数是输出文件名，存放未配对的reads。

my %hash1,%hash2;
my $fq;
my ($in1,$in2,$out1,$out2,$out3)=@ARGV;   

open IN2,"<$in2" or die "can not open IN2";
while(<IN2>){
  my @a=split(/\//,$_); #逐行读行赋值给默认变量$_，用/分隔，取第一列  
  $hash2{$a[0]}=1;   #将数组@a的第一列建立哈希数组hash2，keys就是@a的第一列，values都是1（临时）。
  <IN2>;<IN2>;<IN2>; #此时将fastq2文件中每四行的第一行建立了hash2数组
}
close IN2;

open IN1,"<$in1" or die "can not open IN1";
open OUT1,">$out1" or die "can not write in OUT1";
open OUT3,">$out3" or die "can not write in OUT3"; 
while(<IN1>){
  my @b=split(/\//,$_);  #浏览fastq1文件，逐行读行赋值给默认变量$_，用/分隔，取第一列
    if(exists $hash2{$b[0]}){
		print OUT1 "$_";	#判断数组@b中的元素$b[0]在在hash2数组中是否存在（注意hash数组的用法），如果存在则连续输出四行到$out1文件中，里面内容是fastq1和fastq2文件共有的fastq1这部分reads内容
		$_=<IN1>;print OUT1;
		$_=<IN1>;print OUT1;
		$_=<IN1>;print OUT1;
	}else{                  
		print OUT3;             #如果不存在，就打印四行输出到$out3文件中，里面得到了fastq1特有的reads内容
		$_=<IN1>;print OUT3;
		$_=<IN1>;print OUT3;
		$_=<IN1>;print OUT3;
		}
}
close IN1;
close OUT1;
close OUT3;
#现在，fastq1文件已经被分成两部分了，一部分在out1，另一部分在out3中。


open IN1,"<$in1" or die "can not open IN1";
while(<IN1>){
  my @c=split(/\//,$_,0); 
  $hash1{$c[0]}=2;    
  <IN1>;<IN1>;<IN1>;		#此时将fastq1文件中每四行中的第一行建立了hash1数组
}
close IN1;

open IN2,"<$in2" or die "can not open IN2";
open OUT2,">$out2" or die "can not write in OUT2";
open OUT3,">>$out3" or die "can not write in OUT3";  #注意此处用的是追加，前面已经将fastq1中特有的reads写入到OUT3，这儿是将fastq2中特有的reads追加到OUT3
while(<IN2>){
  my @d=split(/\//,$_);  
    if(exists $hash1{$d[0]}){
		print OUT2 "$_";	#判断数组@d中的元素$d[0]在hash1数组中是否存在（注意hash数组的用法），如果存在则连续输出四行到$out2文件中，里面内容是fastq1和fastq2文件共有的fastq2这部分reads内容
		$_=<IN2>;print OUT2;
		$_=<IN2>;print OUT2;
		$_=<IN2>;print OUT2;
	}else{                  #如果不存在，就将四行追加输出到$out3文件中，里面得到了fastq2特有的reads内容
		print OUT3;
		$_=<IN2>;print OUT3;
		$_=<IN2>;print OUT3;
		$_=<IN2>;print OUT3;
		}
}
close IN2;
close OUT2;
close OUT3;
