import subprocess
import sys
import re
from concurrent import futures


def run_QC(bid):
	print bid
	dirname='/glusterfs/users/pmakella/DARPA/'+prj+'/Run'+num

 	cmd = ["/usr/local/tools/run-Illumina-QC/run_Illumina_QC.1.0.1.pl"]
        cmd1 = "run_Illumina_QC"
        
	cc = dirname+'/'+cmd1+'.'+bid+'.ini'
        cmd.append(cc)
        print "Running... "
        print cmd
        proc=subprocess.Popen(cmd, stdout = subprocess.PIPE)
	proc.wait()
	return proc


def run_Aln(bid):
	print bid
	dirname='/glusterfs/users/pmakella/DARPA/'+prj+'/Run'+num

        cmd = ["/usr/local/tools/run-Tophat-alignment/run_Tophat_alignment.1.0.1.pl"]
	cmd1 = "run_Tophat_alignment"
        
	cc = dirname+'/'+cmd1+'.'+bid+'.ini'
        cmd.append(cc)
        print "Running... "
        print cmd
        proc=subprocess.Popen(cmd, stdout = subprocess.PIPE)
	proc.wait()
	return proc




prjn = sys.argv[2]
if (prjn == 'dro'):
        prj = 'Drosophila Fat Body RNAseq'
elif(prjn == 'neu'):
        prj = 'Neuronal_RNAseq'
elif(prjn == 'tp'):
        prj = 'Translatome Profiling'
fileobj = open(sys.argv[1],"r")
info = fileobj.readlines()

lines = info
# assuming 8 line pattern
bids = []
datafiles = []
for i in xrange(len(lines)):
	s=lines[i].strip()
	sl=s.split('_')
        bids.append(sl[0].strip())
#       prj=lines[i+2].strip()
        #re.sub(r'\s', '', prj)
#       prj.replace(' ', '')
	seqfn=s.split(' ')
        datafiles.append(seqfn[0])

print bids
print datafiles
print 'number of samples'
print len(bids)
print 'number of datafiles'
print len(datafiles)
print 'project'
print prj
mntprj=prj.replace(' ', '_')
prj=prj.replace(' ', '')
print prj
print mntprj
# if run number is given start processing
num = sys.argv[3]
print num

if( int(num) > 0):
	dirname='/glusterfs/users/pmakella/DARPA/'+prj+'/Run'+num

counts =0 
#with futures.ProcessPoolExecutor(max_workers=8) as executor:
#    for ( count) in executor.map(run_QC, bids):
#        counts=counts+1
	

#print 'processed QC for ' + str(counts) + ' files'

counts=0
with futures.ProcessPoolExecutor(max_workers=8) as executor:
    for ( count) in executor.map(run_Aln, bids):
        counts=counts+1

print 'processed Aln for ' + str(counts) + ' files'

'''cmd =[]	
	cmd = ["/usr/local/tools/run-Illumina-QC/run_Illumina_QC.1.0.1.pl"]
	cmd1 = "run_Illumina_QC"
	procList = []
	for b in bids:
        	cc = inidirname+'/'+cmd1+'.'+b+'.ini'
        	cmd.append(cc)
        	print "Running... "
        	print cmd
		print len(procList)
        	proc=subprocess.Popen(cmd, stdout = subprocess.PIPE)
       		procList.append(proc)
		if(len(procList)> 7):
			for p in procList:
				p.wait()
			procList = []	
    	#res = proc.communicate()[0]
    		cmd.pop()

	

	print 'running Top hat'
	cmd =[]
        cmd = ["/usr/local/tools/run-Tophat-alignment/run_Tophat_alignment.1.0.1.pl"]
	cmd1 = "run_Tophat_alignment"
        procList = []
        for b in bids:
                cc = inidirname+'/'+cmd1+'.'+b+'.ini'
                cmd.append(cc)
                print "Running... "
                print cmd
                print len(procList)
                proc=subprocess.Popen(cmd, stdout = subprocess.PIPE)
                procList.append(proc)
                if(len(procList)> 7):
                        for p in procList:
                                p.wait()
                        procList = []
        #res = proc.communicate()[0]
                cmd.pop()
	   print 'writing data file names'
        fn=dirname+'/fileRun'+ num+'.txt'
        print fn
        f = open(fn, 'w')
        for item in datafiles:
                f.write("%s\n" % item)

        print 'writing ini  files'
        cmd =[]
        cmd.append('bash')
        cmd.append('/glusterfs/users/pmakella/scripts/makeConfigfiles.sh')

        cmd.append(fn)
        cmd.append(inidirname)
        print cmd
        proc=subprocess.Popen(cmd)
'''
