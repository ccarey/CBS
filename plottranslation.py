import re
import numpy as np
from collections import deque
import os
import glob
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math

directoryPre = '/ncf/snp/04/SCORE/'
subjectsFile = '/ncf/snp/04/SCORE/batch/subj_lists/temp.txt'
taskFolder = 'face_task/'
subType = 'SZ'
#directoryPre = input("Directory Prefix:")
#subjectsFile = input("Text file of subjects:")
#analFolder = input("Analysis folder:")
#subType = input("Subject type:")

with open(subjectsFile,"r") as subfile:
        subs = subfile.readlines()
subs = [sub.strip() for sub in subs]
subjects = re.split(' ', subs[0])
#finaloutliers = []
#finalkeys = []
for subject in subjects:
	directory = directoryPre+subType+'/'+subject+'/'+taskFolder
	runs = [d for d in os.listdir(directory) if os.path.isdir(directory+d)]
	fig = plt.figure()
	plt.suptitle(subject)
	i = 1
	for i,run in enumerate(runs):
		ax = fig.add_subplot(len(runs),1,i)
		delta = []
		regressorfile = glob.glob(directory+run+'/rp_f*')
		with open(regressorfile[0],'r') as regressors:
			lines = regressors.readlines()
		lines = [line.strip() for line in lines]
		for i in range(len(lines)-1):
			point1 = re.split('  ',lines[i])
			coordinates1 = [float(num) for num in point1]
			point2 = re.split('  ',lines[i+1])
                        coordinates2 = [float(num) for num in point2]
			mydelta = math.sqrt(((coordinates2[0]-coordinates1[0])**2)+((coordinates2[1]-coordinates1[1])**2)+((coordinates2[2]-coordinates1[2])**2))
			delta.extend([mydelta])
			
		ax.plot(delta,'-r')
		ax.set_xlim(0,204)
		ax.set_ylim(-3,3)
	plt.savefig(subType+subject)
	#plt.show()	
	
