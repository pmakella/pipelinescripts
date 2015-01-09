import subprocess
import sys


#cmd = ["/usr/local/tools/run-Tophat-alignment/run_Tophat_alignment.1.0.1.pl"]
cmd = ["/usr/local/tools/run-RNAseq-expr-analysis/run_RNAseq_expr_analysis.1.0.1.pl"]
#cmd1 = " run_Tophat_alignment"
cmd1 = "run_RNAseq_expr_analysis"
procList = []
for line in open(sys.argv[1]):
	info = line.split("_")
	bid = info[0].strip()
        cc = cmd1+"."+bid+".ini"
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
    

