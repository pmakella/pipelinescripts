#!/binbash


if [ $# -ne 1 ]
then
echo "Usage : runSamples.sh  <listofbids.txt>"
exit 1
fi

filename="$1"
#dirname="$2"

while read line; do
    fname=`basename $line`
#    echo $fname

#   extract BID
    var=$(echo $fname | awk -F"_" '{print $1,$2,$3}')
    set -- $var
    BID="$1"

	`nohup /usr/local/tools/run-Tophat-alignment/run_Tophat_alignment.1.0.1.pl run_Tophat_alignment.$BID.ini` 
done < "$1"
