# -*- coding: utf-8 -*-
"""
Created on Wed Oct 23 14:45:30 2019

@author: Libra
"""

import shlex
import subprocess
import os

# import time


def run(command):
    try:
        result = subprocess.check_output(shlex.split(command), stderr=subprocess.STDOUT)
        return 0, result
    except subprocess.CalledProcessError as e:
        return e.returncode, e.output


def runInDir(path, cleaned=False):
    os.chdir(path)
    #    status=1
    #    count=0
    #    while (status!=0):
    #        count+=1
    #        print(count)
    if cleaned:
        status, out = run(
            'matlab -noFigureWindows -batch "lwd=pwd();cleaned=true;run D:\code\zxSort.m"'
        )
    else:
        status, out = run(
            'matlab -noFigureWindows -batch "lwd=pwd();cleaned=false;run D:\code\zxSort.m"'
        )
    print(out)
    if status == 0:
        #            time.sleep(60)
        cwd = os.getcwd()
        if not cleaned:
            os.chdir(cwd + "_cleaned")
        import sys

        sys.path.insert(1, "D:/code/")
        import sync
        import zxPhy
        import parseDPAFR

        trials = sync.runsync()
        zxPhy.runPhy()
        parseDPAFR.runParse()
        return (out,trials)
        # return (out,[])
    else:
        return (out,[])
    os.chdir('d:/code/')



#
#
# if __name__=="__main__":
#    status, out=run('matlab -noFigureWindows -batch "lwd=pwd();run D:\code\zxSort.m"')
#    if status==0:
#        cwd=os.getcwd()
#        cleanDir=cwd+'_cleaned'
#        os.chdir(cleanDir)
#        import sys
#        sys.path.insert(1,'D:/code/')
#        import sync
#        import zxPhy
#        import parseDPAFR
#
#        sync.runsync()
#        zxPhy.runPhy()
#        parseDPAFR.runParse()
