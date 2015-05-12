#!/bin/sh
# Ts/Tv in SNPs is Transition/Transversion.
# vcf files in directory, this script need one argument:directory, and you will get the Ts/Tv result in file named TsTv_result.txt
Fold_A=$1
for i in $Fold_A/*.vcf;do
	data1=$(awk '{print FILENAME;exit}' $i) 
	data3=$(awk '{if(($4~/[AG]/ && $5~/[AG]/) || ($4~/[CT]/ && $5~/[CT]/)){print $1}}' $i |wc -l )
	data4=$(awk '{if(($4~/[AG]/ && $5~/[CT]/) || ($4~/[CT]/ && $5~/[AG]/)){print $1}}' $i |wc -l )
	echo -e "$data1 $data3 $data4" >>TsTv_result.txt
done
