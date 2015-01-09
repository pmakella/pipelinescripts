
#!/binbash
# Usage : makeConfigfiles.sh  <listofsamples.txt> <dirname> <prjname>
# creates config files for QC, Alignment and Quantification to use tools at /usr/local/tools/...



if [ $# -ne 3 ]
then
echo "Usage : makeConfigfiles.sh  <listofsamples.txt> <dirname> <prjname>"
exit 1
fi

filename="$1"
dirname="$2"
prjname="$3" # for input path in /glusterfs/bionimbus/prj

while read line; do    
#   echo $line
    fname=`basename $line`
#    echo $fname

#   extract BID
    var=$(echo $fname | awk -F"_" '{print $1,$2,$3}')   
    set -- $var
    BID="$1"
#    echo $BID
    RunDate="$2"
#    echo $RunDate
    Sample="$3"
#    echo $Sample

# comment block
#: <<'END'
#---------------------------------
#   make QC config file
    cp /glusterfs/users/pmakella/scripts/run_Illumina_QC.bid.ini  $dirname/run_Illumina_QC.$BID.ini
    sed -i 's/BID/'"$BID"'/g' $dirname/run_Illumina_QC.$BID.ini
    sed -i 's/SEQUENCEFILE1/'"$fname"'/g' $dirname/run_Illumina_QC.$BID.ini
    outpath=$dirname/$BID
#   replace all occurences of / with \/    
    var1=$(echo $outpath | awk '{gsub(/\//,"\/")}; $1')
    set -- $var1
#    echo $var1
    sed -i 's/OUTPATH/'"$var1"'/g'  $dirname/run_Illumina_QC.$BID.ini

    ipath=/glusterfs/bionimbus/$prjname
    var2=$(echo $ipath | awk '{gsub(/\//,"\/")}; $1')
    set -- $var2
    sed -i 's/INPUTPATH/'"$var2"'/g'  $dirname/run_Illumina_QC.$BID.ini


done < "$1"

