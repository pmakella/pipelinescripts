#!/binbash
# Usage : genWig.sh <dirname> <sequencedatafilename>

if [ $# -ne 3 ]
then
echo "Usage : DmRmacs.sh <dirname> <sequencedatafilename> <inputfile to be subtracted> "
exit 1
fi

Dirname="$1"
DataFile="$2"
ControlFile="$3"
DataFile1=`basename $DataFile`
ControlFile1=`basename $ControlFile`


tmp="_q30"
ref="_dmel_"
DataFileref="$DataFile1$ref"
DataFileQ30="$DataFile1$tmp"


ControlFileQ30="$ControlFile1$tmp"

#echo "R CMD BATCH -args --baseDir=$Dirname --outDir=$Dirname --factor=$DataFileref --ipFile=$DataFileQ30.sam.bam --controlFile=$ControlFileQ30.sam.bam /glusterfs/users/pmakella/scripts/spp_for_wig_generation_BAM.R"
#R CMD BATCH -args --baseDir=$Dirname --outDir=$Dirname --factor=$DataFileref --ipFile=$DataFileQ30.sam.bam --controlFile=$ControlFileQ30.sam.bam /glusterfs/users/pmakella/scripts/spp_for_wig_generation_BAM.R

#echo "macs2 -t $Dirname/$DataFileQ30.sam -c $Dirname/$ControlFileQ30.sam -f SAM -g dm -p 1e-5 -m 2,50 --bw=200 -n $DataFile.macs2"
macs2 -t $Dirname/$DataFileQ30.sam -c $Dirname/$ControlFileQ30.sam -f SAM -g dm -p 1e-5 -m 2,50 --bw=200 -n $DataFile1$ControlFile1.macs2
