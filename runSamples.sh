#!/binbash


if [ $# -ne 1 ]
then
echo "Usage : runSamples.sh  <listofbids.txt>"
exit 1
fi

filename="$1"
#dirname="$2"

while read line; do
	` /usr/local/tools/run-RNAseq-expr-analysis/run_RNAseq_expr_analysis.1.0.1.pl run_RNAseq_expr_analysis.$line.ini` 
done < "$1"
