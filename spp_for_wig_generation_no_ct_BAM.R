###### passing auguments from command line
rm(list=ls())

args <- commandArgs()

baseDir <- sub('--baseDir=', '', args[grep('--baseDir=', args)])
outDir <- sub('--outDir=', '', args[grep('--outDir=', args)])
factor <- sub('--factor=', '', args[grep('--factor=', args)])
ipFileName <- sub('--ipFile=', '', args[grep('--ipFile=', args)])

ipFile <- paste (baseDir, ipFileName, sep = "/")

densityWigString <- paste (factor, "no_ct_density.wig", sep="")
densityFile <- paste (outDir, densityWigString, sep="/")   		
wigString <- paste (factor, ", smoothed, tag density", sep=" ")
CCString <- paste (factor, ".crosscorrelation.pdf",sep="")




###### START HERE ######
library(spp)

###### load alignment
chip.data <- read.bam.tags(ipFile);

###### get binding info from cross-correlation profile
###### noticeable auguments: srange, bin, remove.tag.anomalies)
#binding.characteristics <- get.binding.characteristics(chip.data,srange=c(50,500),bin=5);
binding.characteristics <- get.binding.characteristics(chip.data,srange=c(-500,500),bin=5,min.tag.count=10000);

###### print out binding peak separation distance
print(paste("binding peak separation distance =",binding.characteristics$peak$x))

###### plot cross-correlation profile
pdf(file=CCString,width=5,height=5)
par(mar = c(3.5,3.5,1.0,0.5), mgp = c(2,0.65,0), cex = 0.8);
plot(binding.characteristics$cross.correlation,type='l',xlab="strand shift",ylab="cross-correlation",main=factor);
abline(v=binding.characteristics$peak$x,lty=2,col=2)
dev.off();

###### accepting tag alignments passed "remove.tag.anomalies" augument in binding.characteristics()
chip.data <- select.informative.tags(chip.data,binding.characteristics);
###### accepting all of the tag alignments
#chip.data <- select.informative.tags(chip.data);





###### output smoothed tag density (subtracting re-scaled input) into a WIG file
###### note that the tags are shifted by half of the peak separation distance
tag.shift <- round(binding.characteristics$peak$x/2)
#smoothed.density <- get.smoothed.tag.density(chip.data,bandwidth=200,step=100,tag.shift=tag.shift);
smoothed.density <- get.smoothed.tag.density(chip.data,bandwidth=200,tag.shift=tag.shift);
writewig(smoothed.density, densityFile, wigString);
rm(smoothed.density);

