import pandas as pd
import matplotlib.pyplot as plt
import os
import numpy as np

basedir = '/Users/brianlivingston/Documents/GitHub/AgeEarningsShare/ASEC/stats/output'
datadir = basedir + '/plot_data'
plotdir = basedir + '/pyplots'
if not os.path.exists(plotdir):
	os.makedirs(plotdir)
	
genders = ['men','women']

########################################################################
# Unadjusted shares plots
dashlist = [(1,5),(3,3,1,3),(3,5),(8,4,1,4),(8,4),(1,0)]
for gender in genders:
	filepath = datadir + '/unadjusted_' + gender + '.csv'
	df = pd.read_csv(filepath,header=0,index_col=['agecat','year'])
	fig, ax = plt.subplots(figsize=(5,5.5))
	
	j = 0
	for name, group in df.groupby('agecat'):
		group = group.reset_index()
		ax.plot(group['year'],group['uearnshare'],label=name,dashes=dashlist[j])
		j = j + 1
	ax.set_xlim(1976,2017)
	ax.set_xticks(np.arange(1976,2017,5))
	ax.set_ylim(0,0.35)
	ax.set_xlabel('Year')
	ax.legend(bbox_to_anchor=(0.94,-0.13),ncol=2,handlelength=3)
		
	plt.subplots_adjust(bottom=0.25,top=0.95,right=0.95)

	plotpath = plotdir + '/unadjusted_' + gender +'.png'
	plt.savefig(plotpath)
	
########################################################################
# Population shares decomposition
dashlist = [(1,5),(3,5),(1,0)]

for gender in genders:
	filepath = datadir + '/agedecomp_' + gender + '.csv'
	df = pd.read_csv(filepath,header=0,index_col=['agecat','year'])
	df = df.reset_index()
	for agegrp in [25,55]:
		if agegrp == 25:
			df_age = df[df['agecat'] == '25-34 year olds']
		elif agegrp == 55:
			df_age = df[df['agecat'] == '55-64 year olds']

		fig, ax = plt.subplots(figsize=(5,5.5))
		
		components = ['age_effect','earnings_effect','zeroed_uearnshare']
		labels = ['Population Share Component','Mean Earnings Component','Unadjusted Earnings Share']
		for j,var in enumerate(components):
			ax.plot(df_age['year'],df_age[var],label=labels[j],dashes=dashlist[j])

		ax.set_xlim(1976,2017)
		ax.set_xticks(np.arange(1976,2017,5))
		ax.set_xlabel('Year')
		ax.legend(bbox_to_anchor=(0.8,-0.13),ncol=1,handlelength=3)
	
		plt.subplots_adjust(bottom=0.25,top=0.95,right=0.95)

		plotpath = plotdir + '/agedecomp_' + gender + str(agegrp) +'.png'
		plt.savefig(plotpath)
			
########################################################################
# Education decomposition
dashlist = [(1,5),(3,3,1,3),(3,5),(1,0)]

for gender in genders:
	filepath = datadir + '/alt_college_' + gender + '.csv'
	df = pd.read_csv(filepath,header=0,index_col=['agecat','year'])
	df = df.reset_index()
	for agegrp in [25,55]:
		if agegrp == 25:
			df_age = df[df['agecat'] == '25-34 year olds']
		elif agegrp == 55:
			df_age = df[df['agecat'] == '55-64 year olds']

		fig, ax = plt.subplots(figsize=(5,5.5))
		
		components = ['age_effect','college_effect','earnings_effect','zeroed_uearnshare']
		labels = ['Population Share Component','Education Component','Mean Earnings Component','Unadjusted Earnings Share']
		for j,var in enumerate(components):
			ax.plot(df_age['year'],df_age[var],label=labels[j],dashes=dashlist[j])

		ax.set_xlim(1976,2017)
		ax.set_xticks(np.arange(1976,2017,5))
		ax.set_xlabel('Year')
		ax.legend(bbox_to_anchor=(0.8,-0.13),ncol=1,handlelength=3)
	
		plt.subplots_adjust(bottom=0.28,top=0.95,right=0.95)

		plotpath = plotdir + '/alt_college_' + gender + str(agegrp) +'.png'
		plt.savefig(plotpath)
	
plt.show()
