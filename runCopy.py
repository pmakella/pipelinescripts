import subprocess
import sys

#mkdir ./../../DARPA/droFatBody/Run188/2012-1549/wholegenome/
#pmakella@kg12-compute-1:/glusterfs/users/pmakella/wholegenome/droFatBody$ mv 2012-1549/*.fpkm* ./../../DARPA/droFatBody/Run188/2012-1549/wholegenome/.

d=sys.argv[1]
s = '/glusterfs/users/pmakella/DARPA/droFatBody/'+d+'/'
print s
#cmd = ["/usr/local/tools/run-RNAseq-expr-analysis/run_RNAseq_expr_analysis.1.0.1.pl"]
#cmd1 = " run_Tophat_alignment"
#cmd1 = "run_RNAseq_expr_analysis"
#cmd=[]
#cmd1=[]
procList = []
for line in open(sys.argv[2]):
	cmd=[]
	cmd1=[]
	info = line.split("_")
	bid = info[0].strip()
        str1= s+bid+'/wholegenome'
        cmd.append('mkdir')	
        cmd.append(str1)

#        cmd1.append('mv -iv')
#        cmd1.append('-iv')
        str2 = 'cp -iv' +'  /glusterfs/users/pmakella/wholegenome/droFatBody/'+bid+'/'+'*.fpkm_tracking'
        #str2="a.txt"
	#cmd1.append(str2)
        str3 = str2 + ' ' + str1+'/'
        #str3="b.txt"
	cmd1.append(str3)

        print "Running... "
        print cmd
	print cmd1
	print len(procList)
        proc=subprocess.Popen(cmd, stdout = subprocess.PIPE)
        procList.append(proc)
        proc1=subprocess.Popen(cmd1, shell=True)
        procList.append(proc1)
	if(len(procList)> 7):
		for p in procList:
			p.wait()
		procList = []	
    	#res = proc.communicate()[0]
    	cmd.pop()
        cmd1.pop()

