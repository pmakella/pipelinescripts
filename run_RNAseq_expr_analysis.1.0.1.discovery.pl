#!/usr/bin/perl -w
# modified by Padma Akella 02/2013 to detect novel transcripts - changed cufflinks parameter from --GTF  to --GTF-guide

# Parse the config file and analyze expression levels
# Elizabeth Bartom
# 02/2011

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

# Derive cistrackIDname if necessary and possible.
if (!$cistrackID){
    if ($path !~ /\//){ 
	$cistrackID = $path;
    } elsif ($path =~ /.*\/([\w\-]+)/){
	$cistrackID = $1;
	&IgsbPerl::datePrint("The cistrackID was undefined; being set to $cistrackID.");
    }
}


###############################
# Pipeline-specific variables
###############################

my $species = $PARAMETERS{'species'};
my $genomeAssembly = $PARAMETERS{'genomeAssembly'};
my $maxMem = $PARAMETERS{'maxMem'};
my $javaMaxMemString = $PARAMETERS{'javaMaxMemString'};
my $numThreads = $PARAMETERS{'numThreads'};
my $runWithGTF = $PARAMETERS{'runWithGTF'};
my $runWithoutGTF = $PARAMETERS{'runWithoutGTF'};
my $refgtf = $LIB{'refgtf'};
my $referenceSeq = $LIB{'referenceSeq'};
my $bamfiles = $IN{'bamfiles'};
my $samtoolspath = $SCRIPTS2{'samtoolspath'};
my $cuffcompare = $SCRIPTS2{'cuffcompare'};
my $cufflinks = $SCRIPTS2{'cufflinks'};
my $command = "";


my ($mergedbamfile);
my $date = `date --rfc-3339='ns'`;
if ($date =~ /(\d+\-\d+\-\d+)\s/){
    $mergedbamfile = "$path\/$cistrackID.$1\.merged.bam";
} else { 
    print STDERR "Failed to use date to name merged bam file.\n";
    $mergedbamfile =  "$path\/$cistrackID.merged.bam";
}

# Merge bam files if necessary
my @bamfiles = split(/\,/,$bamfiles);
if ($#bamfiles > 0){
    &IgsbPerl::datePrint("Merging @bamfiles to create $mergedbamfile.");
    my $command = "$samtoolspath merge $mergedbamfile @bamfiles";
    if (($runTesting)&&($runTesting==1)){
      print STDERR "\nmerge command:\n$command\n\n";
    }
    system($command) == 0
	or die "$samtoolspath merge failed to merge @bamfiles: ERR $?";
    $bamfiles = $mergedbamfile;
} else { 
    $mergedbamfile = $bamfiles;
}

# Run cufflinks.
if (($runWithGTF) && ($runWithGTF == 1)){
    &IgsbPerl::datePrint("Running cufflinks on $mergedbamfile with transcripts from $refgtf.");
    &IgsbPerl::postStatusReport($updateProgress,$cistrackID,$pipeline,"Running cufflinks on $mergedbamfile with transcripts from $refgtf",$postStatus);
    $command = "$cufflinks -p $numThreads --GTF-guide $refgtf -u -b $referenceSeq  --upper-quartile-norm \\
    $mergedbamfile -o $path >& $path\/$cistrackID.cufflinks.withGTF.log";
    print $command;
    if (($runTesting)&&($runTesting==1)){
	print STDERR "\nCufflinks command:\n$command\n\n";
    }
    system($command) == 0
	or die "Cufflinks failed on $mergedbamfile!\n";
    `mv $path\/genes.fpkm_tracking $path\/$cistrackID.withGTF.genes.fpkm_tracking`;
    `mv $path\/isoforms.fpkm_tracking $path\/$cistrackID.withGTF.isoforms.fpkm_tracking`;
    `mv $path\/transcripts.gtf $path\/$cistrackID.withGTF.transcripts.gtf`;
    `mv $path\/skipped.gtf $path\/$cistrackID.withGTF.skipped.gtf`;
}
if (($runWithoutGTF) && ($runWithoutGTF == 1)){
    &IgsbPerl::datePrint("Running cufflinks on $mergedbamfile without transcript file.");
    &IgsbPerl::postStatusReport($updateProgress,$cistrackID,$pipeline,"Running cufflinks on $mergedbamfile without transcript file",$postStatus);
    $command = "$cufflinks -p $numThreads -u -b $referenceSeq --upper-quartile-norm $mergedbamfile -o $path >& $path\/$cistrackID.cufflinks.withoutGTF.log";
    if (($runTesting)&&($runTesting==1)){
	print STDERR "\nCufflinks command:\n$command\n\n";
    }
    system($command) == 0
	or die "Cufflinks failed on $mergedbamfile!\n";
    `mv $path\/genes.fpkm_tracking $path\/$cistrackID.withoutGTF.genes.fpkm_tracking`;
    `mv $path\/isoforms.fpkm_tracking $path\/$cistrackID.withoutGTF.isoforms.fpkm_tracking`;
    `mv $path\/transcripts.gtf $path\/$cistrackID.withoutGTF.transcripts.gtf`;
    `mv $path\/skipped.gtf $path\/$cistrackID.withoutGTF.skipped.gtf`;
}

&IgsbPerl::datePrint("Finished running $pipeline");
&IgsbPerl::postStatusReport($updateProgress,$cistrackID,$pipeline,"Finished running $pipeline",$postStatus);

close (LOG);
`cp $log_file $path`;
