import subprocess
import sys

cmd = ["/usr/local/tools/run-Tophat-alignment/run_Tophat_alignment.1.0.1.pl"]
cmd1 = " run_Tophat_alignment"
for line in open(sys.argv[1]):
    info = line.split("_")
    bid = info[0]
    cc = cmd1+"."+bid+".ini"
    cmd.append(cc)
    print "Running... "+cmd
    proc=subprocess.popen(cmd, stdout = subprocess.PIPE)
    res = proc.communicate()[0]
    cmd.pop()
    

