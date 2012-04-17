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
	for run in runs:
		ax1 = fig.add_subplot(len(runs),2,i)
		i+=1
		ax2 = fig.add_subplot(len(runs),2,i)
		i+=1
		x = []
		y = []
		z = []
		pitch = []
		roll = []
		yaw = []
		regressorfile = glob.glob(directory+run+'/rp_f*')
		with open(regressorfile[0],'r') as regressors:
			lines = regressors.readlines()
		lines = [line.strip() for line in lines]
		for line in lines:
			outs = re.split('  ',line)
			out = [float(num) for num in outs]
			x.extend([out[0]])
			y.extend([out[1]])
			z.extend([out[2]])
			pitch.extend([(180/math.pi)*out[3]])
			roll.extend([(180/math.pi)*out[4]])
			yaw.extend([(180/math.pi)*out[5]])
		ax1.plot(x,'-r')
		ax1.plot(y,'-g')
		ax1.plot(z,'-b')
		ax1.set_xlim(0,205)
		ax1.set_ylim(-3,3)
		ax2.plot(pitch,'-r')
		ax2.plot(roll,'-g')
		ax2.plot(yaw,'-b')
		ax2.set_xlim(0,205)
		ax2.set_ylim(-3,3)
	plt.savefig(subType+subject)
		
	
