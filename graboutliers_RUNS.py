import re
import numpy as np
from collections import deque
import scipy.io
import glob
import os

directoryPre = '/ncf/snp/04/SCORE/'
subjectsFile = '/ncf/snp/04/SCORE/batch/subj_lists/temp.txt'
taskFolder = 'msit_iaps/'
#analFolder = 'msit_iaps_analysis/standard_space_canonical_art/'
subType = 'SZ'
outfile = 'sziaps_temp.csv'
#directoryPre = input("Directory Prefix:")
#subjectsFile = input("Text file of subjects:")
#analFolder = input("Analysis folder:")
#subType = input("Subject type:")

with open(subjectsFile,"r") as subfile:
        subs = subfile.readlines()
subs = [sub.strip() for sub in subs]
subjects = re.split(' ', subs[0])
finallist = []

for j, subject in enumerate(subjects):
	directory = directoryPre+subType+'/'+subject+'/'+taskFolder
	runs = [d for d in os.listdir(directory) if os.path.isdir(directory+d)]
	i = 1
	if j == 0:
		outlierfront = []
		outlierfront.append('Subject')
		outlierfront.append('Total')
		for i in range(len(runs)):
			outlierfront.append('Run'+str(i+1))
		finallist.append(outlierfront)
	outliersub = []
	outliersub.append(subject)
	runoutliers = []
	for i,run in enumerate(runs):
		d = {}		
		regressorfile = glob.glob(directory+run+'/art_regression_outliers_and_movement_swrf*')
		scipy.io.loadmat(regressorfile[0], d)
		regress = d["R"]
		regress2 =regress.reshape(-1,len(regress))
		runoutliers.append(len(regress2)-6)
	outliersub.append(sum(runoutliers))
	outliersub.extend(runoutliers)
	finallist.append(outliersub)

with open(outfile,"w") as outfile:
	for list in finallist:
		for outlier in list:
			outfile.write(str(outlier)+',')
		outfile.write('\n')
