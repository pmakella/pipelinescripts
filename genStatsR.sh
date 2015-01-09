#!/binbash
#Usage : genWig.sh <dirname> <sequencedatafilename> 

if [ $# -ne 2 ]
then
echo "Usage : genWig.sh <dirname> <sequencedatafilename>"
exit 1
fi

Dirname="$1"
n="$2"
p="/glusterfs/bionimbus/pmakella/"
DataFile="$p$n"
#ControlFile="$2"
DataFile1=`basename $DataFile`
#ControlFile1=`basename $ControlFile`
#echo $DataFile1
#echo "/glusterfs/users/malijia/source/bwa-0.5.9/bwa aln -I -B 0 -t 4 /glusterfs/users/malijia/data/ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r5.32_FB2010_09/fasta/dmel_r5.32 $Datafile > $DataFile.sai"
#/glusterfs/users/malijia/source/bwa-0.5.9/bwa aln -I -B 0 -t 4 /glusterfs/users/malijia/data/ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r5.32_FB2010_09/fasta/dmel_r5.32 $DataFile > $Dirname/$DataFile1.sai


#echo "created .sai file" 

#/glusterfs/users/malijia/source/bwa-0.5.9/bwa samse /glusterfs/users/malijia/data/ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r5.32_FB2010_09/fasta/dmel_r5.32 $Dirname/$DataFile1.sai $DataFile  > $Dirname/$DataFile1.sam
#echo "created .sam file"

#/glusterfs/users/pmakella/scripts

/glusterfs/users/pmakella/scripts/SAM.statistics.bwa.pl $Dirname/$DataFile1.sam $Dirname/$DataFile1.sam.stats
#/glusterfs/users/malijia/bin/ChIPSeq_bin/SAM.statistics.bwa.pl $Dirname/$DataFile1.sam $Dirname/$DataFile1.sam.stats
#echo "created statistics"


tmp="_q30"
ref="dmel"
DataFileref="$DataFile1$ref"
DataFileQ30="$DataFile1$tmp"

/glusterfs/users/malijia/source/samtools-0.1.17/samtools view -h -S -q 30 -o $Dirname/$DataFileQ30.sam $Dirname/$DataFile1.sam
#echo "filtered low signals, created _q30 file"

/glusterfs/users/malijia/source/samtools-0.1.17/samtools view -Sb $Dirname/$DataFileQ30.sam > $Dirname/$DataFileQ30.sam.bam
#echo "created .bam file"

#R CMD BATCH -args --baseDir=$Dirname --outDir=$Dirname --factor=$DataFile1 --ipFile=$DataFileQ30.sam.bam  /glusterfs/users/malijia/bin/ChIPSeq_bin/spp_for_wig_generation_no_ct_BAM.R
R CMD BATCH -args --baseDir=$Dirname --outDir=$Dirname --factor=$DataFileref --ipFile=$DataFileQ30.sam.bam  /glusterfs/users/pmakella/scripts/spp_for_wig_generation_no_ct_BAM.R


#R CMD BATCH -args --baseDir=/glusterfs/users/pmakella/ChIP-seq/$Dirname --outDir=/glusterfs/users/pmakella/ChIP-seq/$Dirname/wigfiles --factor=$DataFile --ipFile=$DataFileQ30.sam.bam /glusterfs/users/malijia/bin/ChIPSeq_bin/spp_for_wig_generation_no_ct_BAM.R
#echo "generated individual wiggle file" 


