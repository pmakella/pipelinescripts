
#!/binbash
# Usage : makeConfigfiles.sh  <listofsamples.txt> <dirname>
# creates config files for QC, Alignment and Quantification to use tools at /usr/local/tools/...



if [ $# -ne 2 ]
then
echo "Usage : makeConfigfiles.sh  <listofsamples.txt> <dirname>"
exit 1
fi

filename="$1"
dirname="$2"

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
#    cp /glusterfs/users/pmakella/scripts/run_Illumina_QC.bid.ini  $dirname/run_Illumina_QC.$BID.ini
#    sed -i 's/BID/'"$BID"'/g' $dirname/run_Illumina_QC.$BID.ini
#    sed -i 's/SEQUENCEFILE1/'"$fname"'/g' $dirname/run_Illumina_QC.$BID.ini
    outpath=$dirname/$BID
#   replace all occurences of / with \/    
    var1=$(echo $outpath | awk '{gsub(/\//,"\/")}; $1')
    set -- $var1
#    echo $var1
#    sed -i 's/OUTPATH/'"$var1"'/g'  $dirname/run_Illumina_QC.$BID.ini

#---------------------------------
#   make Tophat alignment config file

#    cp /glusterfs/users/pmakella/scripts/run_Tophat_alignment.bid.ini  $dirname/run_Tophat_alignment.$BID.ini
#    sed -i 's/BID/'"$BID"'/g' $dirname/run_Tophat_alignment.$BID.ini
#    sed -i 's/SEQUENCEFILE1/'"$fname"'/g' $dirname/run_Tophat_alignment.$BID.ini
#    sed -i 's/RUNDATE/'"$RunDate"'/g' $dirname/run_Tophat_alignment.$BID.ini
#    sed -i 's/SAMPLE/'"$Sample"'/g' $dirname/run_Tophat_alignment.$BID.ini
    outpath=$dirname/$BID
#    sed -i 's/OUTPATH/'"$var1"'/g'  $dirname/run_Tophat_alignment.$BID.ini

#END

#---------------------------------
#   make Quantification config file

#    cp /glusterfs/users/pmakella/scripts/run_RNAseq_expr_analysis.bid.ini  $dirname/run_RNAseq_expr_analysis.$BID.ini
#    sed -i 's/BID/'"$BID"'/g' $dirname/run_RNAseq_expr_analysis.$BID.ini
#    sed -i 's/RUNDATE/'"$RunDate"'/g' $dirname/run_RNAseq_expr_analysis.$BID.ini
#    sed -i 's/SAMPLE/'"$Sample"'/g' $dirname/run_RNAseq_expr_analysis.$BID.ini
#    outpath=$dirname/$BID
#    sed -i 's/OUTPATH/'"$var1"'/g'  $dirname/run_RNAseq_expr_analysis.$BID.ini
#   make Quantification config file

    cp /glusterfs/users/pmakella/scripts/run_RNAseq_expr_analysis_novel.bid.ini  $dirname/run_RNAseq_expr_analysis_novel.$BID.ini

    sed -i 's/BID/'"$BID"'/g' $dirname/run_RNAseq_expr_analysis_novel.$BID.ini
    sed -i 's/RUNDATE/'"$RunDate"'/g' $dirname/run_RNAseq_expr_analysis_novel.$BID.ini
    sed -i 's/SAMPLE/'"$Sample"'/g' $dirname/run_RNAseq_expr_analysis_novel.$BID.ini

#    `mkdir $dirname/$BID/exome`
    outpath=$dirname/$BID/novel
    var1=$(echo $outpath | awk '{gsub(/\//,"\/")}; $1')
    set -- $var1
    sed -i 's/OUTPATH/'"$var1"'/g'  $dirname/run_RNAseq_expr_analysis_novel.$BID.ini

    inputpath=$dirname/$BID/
    var2=$(echo $inputpath | awk '{gsub(/\//,"\/")}; $1')
    set -- $var2
    sed -i 's/INPUTPATH/'"$var2"'/g'  $dirname/run_RNAseq_expr_analysis_novel.$BID.ini

done < "$1"

