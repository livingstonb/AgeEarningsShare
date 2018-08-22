import pandas as pd
import matplotlib.pyplot as plt
import os
import numpy as np

basedir = '/Users/brianlivingston/Documents/GitHub/AgeEarningsShare/ASEC/stats/output'
datadir = basedir + '/plot_data'
plotdir = basedir + '/pyplots'
if not os.path.exists(plotdir):
	os.makedirs(plotdir)

fig = plt.figure(figsize=(10,7))

genders = ['men','women']
dashlist = [(1,5),(3,3,1,3),(3,5),(8,4,1,4),(8,4),(1,0)]
for gender in genders:
	filepath = datadir + '/unadjusted_' + gender + '.csv'
	df = pd.read_csv(filepath,header=0,index_col=['agecat','year'])
	if gender=='men':
		ax = fig.add_subplot(121)
	elif gender=='women':
		ax = fig.add_subplot(122)
	
	j = 0
	for name, group in df.groupby('agecat'):
		group = group.reset_index()
		ax.plot(group['year'],group['uearnshare'],label=name,dashes=dashlist[j])
		j = j + 1
	ax.set_xlim(1976,2017)
	ax.set_xticks(np.arange(1976,2017,5))
	ax.set_ylim(0,0.4)
	ax.set_xlabel('Year')
		
ax.legend(bbox_to_anchor=(0.68,0),ncol=3)

plotpath = plotdir + '/unadjusted.png'
plt.savefig(plotpath)
plt.show()
