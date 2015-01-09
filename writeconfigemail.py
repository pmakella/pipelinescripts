#usage : writeconfigemail.py <modENCODE_ChIPseqimportemailwith29cols.txt>
import subprocess
import sys
import re
import glob
import string

import os.path
from os.path import basename

def getindices(keys,values,headers):
#default indices
	for i in range(len(keys)):
        	values.append(i)

#get indices for fields

	for ind, item in enumerate(keys):
        	try:
                #print item
                	values[ind]=headers.index(item)
        	except ValueError:
                	values[ind]=100 # no match, arbitrary index with some number

##########################

def getseqfile(searchstring):
#	print searchstring
	files = glob.glob(searchstring)               
        # files are in sorted order, files[-1] gives most recent file
	return basename(files[-1])

##########################

fileobj = open(sys.argv[1],"r")
filename = fileobj.name
info = fileobj.readlines()

#library log file
fileobjlib = open(sys.argv[2],"r")
datasetinfo = fileobjlib.readlines()

prj='/glusterfs/bionimbus/modENCODE_ChIP-seq/'

keys=['Bionimbus Id','Path','Reads','Platform','Project','Organism','Stage','Facility','Samples requested per lane','Cycles requested per lane','Refrence library to map output','Comments','Name','Strain','Tissue','Source','Replicate','Antibody','Target Symbol','Target ID','Flybase/Wormbase ID','Treatment','Prep Performed by','Library Prep Protocol','Barcode','Desired Multiplexing','Read Length','Read Type','desired minimum reads']

values=[]



lndata=[]
# 1st row with column names, indices from email
lndata=(info[0].strip()).split('\t')

getindices(keys,values,lndata)
#print 'first line- headers'
#print lndata
#get indices for fields
'''
for ind, item in enumerate(keys):
	try:
		#print item
        	values[ind]=lndata.index(item)
        except ValueError:
                values[ind]=100 # no match, arbitrary index with some number
'''
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

#print 'number of lines'
#print len(lines)
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
	stage.append(sl[values[6]].strip())
	name.append(sl[values[12]].strip())
	strain.append(sl[values[13]].strip())

	tissue.append(sl[values[14]].strip())

	tmp = sl[values[15]].strip()
	if 'INPUT' in tmp or 'Input' in tmp or 'input' in tmp:
                src.append('INPUT')
        else:
 		src.append('IP')
	
	try:
		# converting to int to get rid of numbers after decimal place, such as 1.0
		rep.append(str(int(float(sl[values[16]].strip()))))
	except ValueError:
		#replace , with -
		
		inp=(sl[values[16]].strip())
		#print inp
		inp=string.replace(inp,',','-')
		inp=string.replace(inp,'Rep','')
		#print inp
		rep.append(inp)
#	if 'INPUT' in tmp or 'Input' in tmp or 'input' in tmp:
#                AbID.append('INPUT')
#        else:
	
	AbID.append(sl[values[17]].strip())
	targetsymbol.append(sl[18].strip())
	targetid.append(sl[19].strip())
	flybaseid.append(sl[20].strip())
	libprep.append(sl[23].strip())

from collections import defaultdict
d = defaultdict(lambda: defaultdict(list))


for i in xrange(1,len(strain)):
	d[strain[i]][bids[i]]=[seqfn[i],stage[i],src[i],tissue[i],rep[i],AbID[i],organism[i]]

#print d
#print 'strain and bids'
#for s,b in d.iteritems():
#	print
#	print s,b


keyslib=['Off sequencer?','Bionimbus Key','Factor Name','Strain/OP#','Tissue','Stage','Source','Antibody ID','Replicate','FlyBase/WormBase ID']

valueslib=[]



headers=[]
# 1st row with column names, indices from library log google doc
headers=(datasetinfo[0].strip()).split('\t')

getindices(keyslib,valueslib,headers)

# make another data structure for library log element

dlib=defaultdict(lambda: defaultdict(list))

for i in xrange(1,len(datasetinfo)):
        s=datasetinfo[i].strip()
        sl=s.split('\t')

        #remove spaces in text
        for i in xrange(len(sl)):
                sl[i]= sl[i].replace(' ','')

	# if data is off sequencer, add to dlib
	if (sl[valueslib[0]]== 'Y') or (sl[valueslib[0]]=='y'):

		organism=''
		strain=sl[valueslib[3]]
		bid   =sl[valueslib[1]]
		fw    =sl[valueslib[9]]
		if ( 'FB' in fw):
			organism = 'Dmel'
		elif( 'WB' in fw):
			organism = 'Cele'
		stage =sl[valueslib[5]]
		tissue=sl[valueslib[4]]
		src   =sl[valueslib[6]]
		
		if(sl[valueslib[8]]=='INPUT' or sl[valueslib[8]]=='input' or  sl[valueslib[8]] == 'Input'):
			rep = '1'	
		else:
			rep = sl[valueslib[8]]
		abid  =sl[valueslib[7]]
	
		# null string for copying seqfile name
		dlib[strain][bid] =['',stage,src,tissue,rep,abid,organism] 


#print 'strain and bids from lib log'
#print
#for s,b in dlib.iteritems():
#        print
#	print s,b

#search for dataset info in dlib

for s in d.iterkeys():
	if ( s in dlib):
		# strain match
#		print 'checking for ' + s
#		print
		# add bid from dlib if not present in d
		for b in dlib[s].iterkeys():
			if b not in d[s]:
				d[s][b] = dlib[s][b]
				searchstring = prj+b+'*'
				d[s][b][0] = getseqfile(searchstring)
		

#print 'updated strain and bids'
#for s,b in d.iteritems():
#        print
#        print s,b




bidnf=[]
filename = filename + 'configfile.txt'
out = file(filename, 'w')

for s,b in d.iteritems():

	
	#print b
	for bid,v in b.iteritems():
		file_path= prj + v[0]
		#print file_path
		files = glob.glob(file_path)               
		# files are in sorted order, files[-1] gives most recent file
		if (len(files)<1):
       		 	fn = 'err'
			bidnf.append(b)
 		else:
		
			fn = basename(files[-1])
	#	v = b[0]
#		#print >> out, 'ChIP-seq' + '\t' + organism [i]+ '\t' + tissue[i] + '\t' + flybaseid[i]+ '\t'+ targetsymbol[i] + '\t'+targetid[i]+'\t'+stage[i]+'\t'+strain[i]+'\t'+src[i]+'\t'+str(rep[i])+'\t'+AbID[i] \
		#['2014-183_140127_SN1070_0156_BC35NCACXX_2_sequence.txt.gz', 'E0-24', 'INPUT', 'WA', '1', 'NA']
		outstr = 'ChIP-seq'+'\t'+s+'\t'+v[3]+'\t'+v[1]+'\t'+v[2]+'\t'+v[5]+'\t'+ v[4]+'\t'+v[0] +'\t' +v[6] 
		print >> out, outstr
			#print >> out, 'ChIP-seq' + '\t' + s+ '\t' + tissue[i] + '\t' + stage[i]+ '\t'+ src[i] + '\t'+AbID[i]+'\t'+str(rep[i])+'\t' \
			#	+ seqfn[i]
out.close()
print 'config file ' + filename+ ' written'
if (len(bidnf))>0:
	print 'bids not found'
	print bidnf
