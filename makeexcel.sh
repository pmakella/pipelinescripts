#!/bin/bash -e
mkdir excelfiles
while read -r line
do
cd $line
python ../../writetsvtoexcel.py gene_exp.diff isoform_exp.diff ../excelfiles/$line.xls 
cd ..
done < $1
