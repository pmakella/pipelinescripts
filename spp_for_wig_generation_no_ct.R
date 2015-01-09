rm(list=ls())

args <- commandArgs()

baseDir <- sub('--baseDir=', '', args[grep('--baseDir=', args)])
outDir <- sub('--outDir=', '', args[grep('--outDir=', args)])
factor <- sub('--factor=', '', args[grep('--factor=', args)])
ipFileName <- sub('--ipFile=', '', args[grep('--ipFile=', args)])

ipFile <- paste (baseDir, ipFileName, sep = "/")

densityWigString <- paste (factor, "_density.wig", sep="")
densityFile <- paste (outDir, densityWigString, sep="/")   		
wigString <- paste (factor, ", smoothed, background-subtracted tag density", sep=" ")

# ##

library(spp)

chip.data <- read.eland.tags(ipFile);

binding.characteristics <- get.binding.characteristics(chip.data,srange=c(50,500),bin=5);

chip.data <- select.informative.tags(chip.data,binding.characteristics);

tag.shift <- round(binding.characteristics$peak$x/2)
smoothed.density <- get.smoothed.tag.density(chip.data,bandwidth=200,step=100,tag.shift=tag.shift);

writewig(smoothed.density, densityFile, wigString);
rm(smoothed.density);

