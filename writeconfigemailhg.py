#usage : writeconfigemail.py <modENCODE_ChIPseqimportemailwith29cols.txt>
import subprocess
import sys
import re
import glob
import string

import os.path
from os.path import basename

fileobj = open(sys.argv[1],"r")
filename = fileobj.name
info = fileobj.readlines()

keys=['Bionimbus Id','Path','Reads','Platform','Project','Organism','Stage','Facility','Samples requested per lane','Cycles requested per lane','Refrence library to map output','Comments','Name','Strain','Tissue','Source','Replicate','Antibody','Target Symbol','Target ID','Flybase/Wormbase ID','Treatment','Prep Performed by','Library Prep Protocol','Barcode','Desired Multiplexing','Read Length','Read Type','desired minimum reads']

values=[]

#default indices
for i in range(len(keys)):
	values.append(i)

lndata=[]
# 1st row with column names, indices from email
lndata=(info[0].strip()).split('\t')

print 'first line- headers'
print lndata
#get indices for fields

for ind, item in enumerate(keys):
	try:
		print item
        	values[ind]=lndata.index(item)
        except ValueError:
                values[ind]=100 # no match, arbitrary index with some number

print 'keys'
print keys
print 'values'
print values

#print info[1]
lines = info
bids = []
seqfn =[]
organism=[]
strain=[]
tissue=[]
targetsymbol=[]
targetid=[]
stage=[]
src=[]
AbID=[]
rep = []
flybaseid=[]
libprep=[]
name=[]

print 'number of lines'
print len(lines)
for i in xrange(1,len(lines)):
        s=lines[i].strip()
        sl=s.split('\t')

	#remove spaces in text
	for i in xrange(len(sl)):
		sl[i]= sl[i].replace(' ','')
	
# 	print sl[values[0]].strip()

        bids.append(sl[values[0]].strip())
	seqfn.append(sl[values[1]].strip())
	organism.append(sl[values[5]].strip())
	stg=sl[values[6]].strip()
	if (stg == 'N/A'):
		stg = 'NA'
	
	stage.append(stg)
	name.append(sl[values[12]].strip())
	strain.append(sl[values[13]].strip())

	tissue.append(sl[values[14]].strip())

	tmp = sl[values[15]].strip()
	if 'INPUT' in tmp or 'Input' in tmp or 'input' in tmp:
                src.append('INPUT')
        else:
 		src.append('IP')
	
	try:
		rep.append(int(float(sl[values[16]].strip())))
	except ValueError:
		#replace , with -
		
		inp=(sl[values[16]].strip())
		#print inp
		inp=string.replace(inp,',','-')
		#print inp
		inp=string.replace(inp,'Rep','')
		rep.append(inp)
#	if 'INPUT' in tmp or 'Input' in tmp or 'input' in tmp:
#                AbID.append('INPUT')
#        else:
	
	AbID.append(sl[values[17]].strip())
	targetsymbol.append(sl[18].strip())
	targetid.append(sl[19].strip())
	flybaseid.append(sl[20].strip())
	libprep.append(sl[23].strip())


prj='/glusterfs/bionimbus/fAb_ChIP-seq/'

bidnf=[]
filename = filename + 'configfile.txt'
out = file(filename, 'w')

for i in xrange(len(bids)):
	file_path= prj + seqfn[i]
	#print file_path
	files = glob.glob(file_path)               
	if (len(files)<>1):
        	fn = 'err'
		bidnf.append(bids[i])
        else:
		
		#print basename("/a/b/c.txt")
		fn = basename(files[0])
		#print >> out, 'ChIP-seq' + '\t' + organism [i]+ '\t' + tissue[i] + '\t' + flybaseid[i]+ '\t'+ targetsymbol[i] + '\t'+targetid[i]+'\t'+stage[i]+'\t'+strain[i]+'\t'+src[i]+'\t'+str(rep[i])+'\t'+AbID[i] \
		print >> out, 'ChIP-seq' + '\t' + name[i]+'_'+strain [i]+ '\t' + tissue[i] + '\t' + stage[i]+ '\t'+ src[i] + '\t'+AbID[i]+'\t'+str(rep[i])+'\t' \
			+ seqfn[i]
out.close()
print 'config file ' + filename+ ' written'
if (len(bidnf))>0:
	print 'bids not found'
	print bidnf

