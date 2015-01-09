#!/usr/bin/perl -w

# Parse the config file and run Tophat alignments
# Elizabeth Bartom
# 08/21/2011

################################
# Setup used for all pipelines.
################################

use lib '/usr/local/tools/pipelineTools/';
use IgsbPerl;
use strict;
use Config::Abstract::Ini;

my $config_file = shift;
if(!$config_file) {
	print STDERR "Useage: $0  <config_file.ini>\n";
	exit;
}

my $log_file = &IgsbPerl::createLogFile($config_file);
open(LOG,">$log_file");

# Redirect STDERR to log file.
*STDERR = *LOG;

&IgsbPerl::printIP;
&IgsbPerl::getImageName;

my $abstract = new Config::Abstract::Ini($config_file) or die $!;

print LOG "----------\n$abstract\n";
my %PARAMETERS = $abstract->get_entry('PARAMETERS');
my $cistrackID = $PARAMETERS{'cistrackID'};
my $sample = $PARAMETERS{'sample'};
my $readGroup = $PARAMETERS{'readGroup'};
if ((!$readGroup)||($readGroup eq "")){ $readGroup = $cistrackID;}
my $runTesting = $PARAMETERS{'runTesting'};
my $postStatus = $PARAMETERS{'postStatus'};
my %LIB = $abstract->get_entry('INPUT_LIBS');
my %IN = $abstract->get_entry('INPUT_FILES');
my $path = $abstract->get_entry_setting('OUTPUT_DIR', 'path');
my $tmpDir = $abstract->get_entry_setting('OUTPUT_DIR', 'tmpDir');
if (!$tmpDir) { $tmpDir = "$path\/tmp";}
my %SCRIPTS = $abstract->get_entry('SCRIPTS');
my $scriptsConfig = $SCRIPTS{'scriptsConfig'}; 
my $scriptsAbstract = new Config::Abstract::Ini($scriptsConfig) or die $!;
print LOG "-----------\n$scriptsAbstract\n------------\n\n";
my %SCRIPTS2 = $scriptsAbstract->get_entry('SCRIPTS');
my $updateProgress = $SCRIPTS2{'updateProgress'};
my $pipeline = $0;

# Create output directory if necessary.
unless (-d $path) { system("mkdir -pv $path");}
&IgsbPerl::datePrint("Printing output files to $path");

# Create temp  directory if necessary.
unless (-d $tmpDir) { `mkdir -pv $tmpDir`;}
&IgsbPerl::datePrint("Printing temp files to $tmpDir");

# Derive readGroup name if necessary and possible.
if (!$readGroup){
    if ($path !~ /\//){ 
	$readGroup = $path;
    } elsif ($path =~ /.*\/([\w\-]+)/){
	$readGroup = $1;
	&IgsbPerl::datePrint("The read group was undefined; being set to $readGroup.");
    }
}
my $fname = $readGroup;
$fname =~ s/\s/-/g;

###############################
# Pipeline-specific variables
###############################

my $seqfiles2 = "";
my $seqfiles3 = "";
my $runDate = "";
my $platform = "";
my $minReadLength = $PARAMETERS{'minReadLength'};
my $mateInnerDist = $PARAMETERS{'mateInnerDistance'};
my $mateStdDev = $PARAMETERS{'mateStdDev'};
my $numThreads = $PARAMETERS{'numThreads'};
my $javaMaxMemString = $PARAMETERS{'javaMaxMemString'};
my $pairedEnds = $PARAMETERS{'pairedEnds'};
$runDate = $PARAMETERS{'runDate'};
my $species = $PARAMETERS{'species'};
my $genomeAssembly = $PARAMETERS{'genomeAssembly'};
my $sequencingCenter = $PARAMETERS{'sequencingCenter'};
$platform = $PARAMETERS{'platform'};
my $platformUnit = $PARAMETERS{'platformUnit'};
my $flavor = $PARAMETERS{'flavor'};
my $Qscale = $PARAMETERS{'Qscale'};
my $runTophat = $PARAMETERS{'runTophat'};
my $runLaneStats = $PARAMETERS{'runLaneStats'};
my $cleanTopHatResults = $PARAMETERS{'cleanTopHatResults'};
my $bowtieIndex = $LIB{'bowtieIndex'};
my $referenceSeq = $LIB{'referenceSeq'};
my $inputpath = $IN{'inputpath'};
my $seqfiles1 = $IN{'seqfiles1'};
$seqfiles2 = $IN{'seqfiles2'};
$seqfiles3 = $IN{'seqfiles3'};
my $samfile = $IN{'samfile'};
my $bamfile = $IN{'bamfile'};
my $picardTmp = $abstract->get_entry_setting('OUTPUT_DIR', 'picardTmp');
if ($picardTmp) {
    $picardTmp = "TMP_DIR=$picardTmp";
} else {
    $picardTmp = "TMP_DIR=$tmpDir";
}
my $tophat = $SCRIPTS2{'tophat'}; 
my $sam2laneStats = $SCRIPTS2{'sam2laneStats'};
my $oneAln2laneStats = $SCRIPTS2{'oneAln2laneStats'};
my $cleanUpTopHat = $SCRIPTS2{'cleanUpTopHat'};
my $samtoolspath = $SCRIPTS2{'samtoolspath'};
my $picardpath = $SCRIPTS2{'picardpath'};

if (!$samfile) {  $samfile =  "$fname\_align.sam";}
if (!$bamfile) {  $bamfile =  "$fname\_align.bam";}

if ($seqfiles2) {chomp $seqfiles2;}
if ($seqfiles3) {chomp $seqfiles3;}

# Check whether paired ends or single end.
if ( (($seqfiles2)&&(length($seqfiles2) > 0)) || ($pairedEnds==1)) { 
  # Assume paired ends.
  $pairedEnds=1;
    &IgsbPerl::datePrint("Sequences are paired-end");
} elsif (($pairedEnds != 0) || ($pairedEnds == 0)) { 
    $pairedEnds=0;
    &IgsbPerl::datePrint("Sequences are single-end");
}

if (($runTophat)&& ($runTophat==1)){
  my $command;
  &IgsbPerl::postStatusReport($updateProgress,$readGroup,$pipeline,"Starting Tophat on $readGroup",$postStatus);
  my $headerparameters = "--rg-sample \"$sample\" --rg-id $readGroup";
  if ($runDate)          { $headerparameters .= " --rg-date \"$runDate\"";}
  if ($sequencingCenter) { $headerparameters .= " --rg-center \"$sequencingCenter\"";}
  if ($platform)         { $headerparameters .= " --rg-platform \"$platform\"";}
  if ($platformUnit)     { $headerparameters .= " --rg-platform-unit \"$platformUnit\"";}
  my $segment_length = "";
  if (($flavor eq "1x44") || ($flavor eq "44x1")){
      $segment_length = " --segment-length 20";
  }elsif (($flavor eq "1x36") || ($flavor eq "36x1")){
      $segment_length = " --segment-length 15";
  }
  $command = "$tophat $headerparameters";
  if ($Qscale) { $command .= " --$Qscale";}
  $command .= "$segment_length --mate-inner-dist $mateInnerDist --mate-std-dev $mateStdDev --num-threads $numThreads -o $path $bowtieIndex";
  if ($pairedEnds == 1){
      &IgsbPerl::datePrint("Starting $tophat on $seqfiles1 and $seqfiles2.");
      $command .= " $inputpath\/$seqfiles1 $inputpath\/$seqfiles2";
  } else {
      $command .= " $inputpath\/$seqfiles1";
      &IgsbPerl::datePrint("Starting $tophat on $seqfiles1.");
  }
  $command .= " >& $path\/$fname.clip.tophat.log";
  if (($runTesting)&&($runTesting==1)){
      print STDERR "\nTophat command:\n$command\n\n";
  }
  system($command) == 0 
      or die &IgsbPerl::datePrint("Tophat failed!");
  if (!($runTesting) || ($runTesting == 0)){
      `rm -r $path\/logs`;
      `rm -r $path\/$fname.clip.tophat.log`;
  }
  if (($seqfiles3) && ($seqfiles3 ne "")){
      `mv $path\/accepted_hits.bam $path\/$fname.clip.bam`;
      `mv $path\/deletions.bed $path\/$fname.clip.deletions.bed`;
      `mv $path\/insertions.bed $path\/$fname.clip.insertions.bed`;
      `mv $path\/junctions.bed $path\/$fname.clip.junctions.bed`;
      `mv $path\/left_kept_reads.info $path\/$fname.clip.left_kept_reads.info`;
      `mv $path\/right_kept_reads.info $path\/$fname.clip.right_kept_reads.info`;
      $command = "$tophat $headerparameters";
      if ($Qscale) { $command .= " --$Qscale";}
      $command .= "$segment_length --mate-inner-dist $mateInnerDist --mate-std-dev $mateStdDev --num-threads $numThreads -o $path $bowtieIndex";
      $command .= " $inputpath\/$seqfiles3 >& $path\/$fname.me.tophat.log";
      &IgsbPerl::datePrint("Starting $tophat on $seqfiles3.");
      if (($runTesting)&&($runTesting==1)){
	  print STDERR "\nTophat command for seqfile3 (merge file):\n$command\n\n";
      }
      system($command) == 0 
      or die &IgsbPerl::datePrint("Tophat failed on seqfile3!");
      `mv $path\/accepted_hits.bam $path\/$fname.me.bam`;
      `mv $path\/deletions.bed $path\/$fname.me.deletions.bed`;
      `mv $path\/insertions.bed $path\/$fname.me.insertions.bed`;
      `mv $path\/junctions.bed $path\/$fname.me.junctions.bed`;
      `mv $path\/left_kept_reads.info $path\/$fname.me.left_kept_reads.info`;
      `mv $path\/right_kept_reads.info $path\/$fname.me.right_kept_reads.info`;
      &IgsbPerl::datePrint("Merging $fname.clip.bam and $fname.me.bam to create $fname.bam");    
      $command = "java $javaMaxMemString -jar $picardpath\/MergeSamFiles.jar I=$path\/$fname.me.bam I=$path\/$fname.clip.bam O=$path\/$fname.bam $picardTmp AS=true USE_THREADING=TRUE >& $path\/$fname.merge.log";
      if (($runTesting) && ($runTesting == 1)){
	  print STDERR "\nMerge command is:\n$command\n\n";
      }
      system($command) == 0 || die &IgsbPerl::datePrint("Failed to merge $fname.clip.bam and $fname.me.bam");
      if (!($runTesting) || ($runTesting == 0)){
	  `rm -r $path\/logs`;
	  `rm -r $path\/$fname.me.tophat.log`;
      }
      
  } else {
      `mv $path\/accepted_hits.bam $path\/$fname.bam`;
      `mv $path\/deletions.bed $path\/$fname.deletions.bed`;
      `mv $path\/insertions.bed $path\/$fname.insertions.bed`;
      `mv $path\/junctions.bed $path\/$fname.junctions.bed`;
      `mv $path\/left_kept_reads.info $path\/$fname.left_kept_reads.info`;
      `mv $path\/right_kept_reads.info $path\/$fname.right_kept_reads.info`;
  }
}

# Gather Alignment Statistics
if ($runLaneStats)
{    
    &IgsbPerl::postStatusReport($updateProgress,$readGroup,$pipeline,"Gathering alignment statistics",$postStatus);
    foreach my $bam ("$fname.bam") {
	my $bamfile = &IgsbPerl::markDuplicates("$path\/$bam",$picardpath,$tmpDir,$javaMaxMemString,$runTesting,$samtoolspath);
	&IgsbPerl::datePrint("Gathering alignment statistics for $bamfile");
	&IgsbPerl::gatherAlignStats($oneAln2laneStats,"$bamfile",$samtoolspath,"$bamfile\_AlignStats.txt");
    }
}

# Delete tmp directory if no longer needed.
if (!($runTesting) || ($runTesting == 0)){
    `rm -r $tmpDir`;
}

&IgsbPerl::datePrint("Finished running $pipeline");
&IgsbPerl::postStatusReport($updateProgress,$readGroup,$pipeline,"Finished running $pipeline",$postStatus);

close (LOG);
`cp $log_file $path`;

