# usage: checkmultiplecopies.py filescleanup.log  checks files on /XRaid/share and sullivan
import subprocess
import sys
import re
import glob
import string

import os.path
from os.path import basename

DIR1='/glusterfs/bionimbus/LNCaP_NR_networks/'
DIR2='/XRaid/share/public//LNCaP_NR_networks/'



##########################

def getseqfile(searchstring):
        #print searchstring
        files = glob.glob(searchstring)
        # files are in sorted order, files[-1] gives most recent file
        if (len(files)<1):
                print searchstring + 'no file'
        else:
                return basename(files[-1])

##########################

fileobj = open(sys.argv[1],"r")
filename = fileobj.name
lines = fileobj.readlines()


for i in xrange(0,len(lines)):
        s=lines[i].strip()
        searchstring = DIR1+s
        a=getseqfile(searchstring)
        print a
#        searchstring = DIR2+s
#        b=getseqfile(searchstring)
#       print b

