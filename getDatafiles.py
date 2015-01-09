import subprocess
import sys



fileobj = open(sys.argv[1],"r")
info = fileobj.readlines()

lines = info
# assuming 8 line pattern
bids = []
datafiles = []
for i in xrange(0,len(lines)-1,8):
	bids.append(lines[i+0].strip())
	prj=lines[i+2].strip()
   	datafiles.append(lines[i+6].strip())

print bids
print datafiles
print 'number of samples'
print len(bids)
print 'number of datafiles'
print len(datafiles)
print 'project'
print prj

# if run number is given start processing
num = sys.argv[2]
print num
if( int(num) > 0):
	# make dir in /glusterfs/users/pmakella/DARPA/Run<num>
	cmd=[]
	cmd.append('mkdir')
	cmd.append('/glusterfs/users/pmakella/DARPA/'+prj+'/Run'+num)
	proc=subprocess.Popen(cmd) 

