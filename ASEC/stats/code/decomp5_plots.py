import pandas as pd
import matplotlib.pyplot as plt
import os
import numpy as np
import sys

## Plots decomposition data from output/plot_data

basedir = '/Users/brianlivingston/Documents/GitHub/AgeEarningsShare/ASEC/stats/output'
# Directory of csv's
datadir = basedir + '/plot_data'
# Output directory for p lots
plotdir = basedir + '/pyplots'
if not os.path.exists(plotdir):
	os.makedirs(plotdir)
	
genders = ['men','women']

########################################################################
# Unadjusted shares plots
dashlist = [(1,5),(3,3,1,3),(3,5),(8,4,1,4),(8,4),(1,0)]
subplotlist = [121,122]
titles = ['Men','Women']
fig = plt.figure(figsize=(8,5))
for count,gender in enumerate(genders):
	filepath = datadir + '/unadjusted_' + gender + '.csv'
	df = pd.read_csv(filepath,header=0,index_col=['agecat','year'])
	ax = fig.add_subplot(subplotlist[count])
	
	j = 0
	for name, group in df.groupby('agecat'):
		group = group.reset_index()
		ax.plot(group['year'],group['uearnshare'],label=name,dashes=dashlist[j])
		j = j + 1
	ax.set_xlim(1976,2017)
	ax.set_xticks(np.arange(1976,2017,10))
	ax.set_yticks([0,0.1,0.2,0.3])
	ax.set_ylim(0,0.35)
	ax.set_xlabel('Year')
	ax.set_title(titles[count])
	
ax.legend(bbox_to_anchor=(0.48,-0.13),ncol=2,handlelength=3)	
plt.subplots_adjust(bottom=0.26,top=0.95,right=0.97,wspace=0.3,left=0.05)

plotpath = plotdir + '/unadjusted.png'
plt.savefig(plotpath)

########################################################################
# Population shares decomposition
dashlist = [(1,5),(3,3,1,3),(3,5),(1,0)]
subplotlist = [221,223,222,224]
lcolorlist = ['b','y','g','r']
fig = plt.figure(figsize=(8,6.5))

components = ['age_effect','earnings_effect','interact_effect','zeroed_uearnshare']
labels = ['Population Share Component','Mean Earnings Component','Interaction','Unadjusted Earnings Share']
titles = ['Men 25-34','Men 55-64','Women 25-34','Women 55-64']
	
count = 0
for gender in genders:
	filepath = datadir + '/age_' + gender + '.csv'
	df = pd.read_csv(filepath,header=0,index_col=['agecat','year'])
	df = df.reset_index()
	for agegrp in [25,55]:
		if agegrp == 25:
			df_age = df[df['agecat'] == '25-34 year olds']
		elif agegrp == 55:
			df_age = df[df['agecat'] == '55-64 year olds']

		ax = fig.add_subplot(subplotlist[count])
		
		for j,var in enumerate(components):
			ax.plot(df_age['year'],df_age[var],label=labels[j],dashes=dashlist[j],color=lcolorlist[j])

		ax.set_xlim(1976,2017)
		ax.set_xticks(np.arange(1976,2017,10))
		# ax.set_xlabel('Year')
		ax.set_title(titles[count])
		count += 1
		
ax.legend(bbox_to_anchor=(0.34,-0.22),ncol=1,handlelength=3)

plt.subplots_adjust(bottom=0.22,top=0.95,left=0.09,right=0.97,hspace=0.4)

plotpath = plotdir + '/agedecomp.png'
plt.savefig(plotpath)
########################################################################
# Education decomposition
dashlist = [(1,5),(3,5),(8,4,1,4),(1,0)]
subplotlist = [221,223,222,224]
lcolorlist = ['b','k','g','r']
fig = plt.figure(figsize=(8,6.5))

components = ['composition_effect','struct_effect','interact_effect','zeroed_uearnshare']
labels = ['Compositional Effect','Structural Effect','Interaction','Unadjusted Earnings Share']
titles = ['Men 25-34','Men 55-64','Women 25-34','Women 55-64']

count = 0
for gender in genders:
	filepath = datadir + '/college_' + gender + '.csv'
	df = pd.read_csv(filepath,header=0,index_col=['agecat','year'])
	df = df.reset_index()
	for agegrp in [25,55]:
		if agegrp == 25:
			df_age = df[df['agecat'] == '25-34 year olds']
		elif agegrp == 55:
			df_age = df[df['agecat'] == '55-64 year olds']

		ax = fig.add_subplot(subplotlist[count])
		

		for j,var in enumerate(components):
			ax.plot(df_age['year'],df_age[var],label=labels[j],dashes=dashlist[j],color=lcolorlist[j])

		ax.set_xlim(1976,2017)
		ax.set_xticks(np.arange(1976,2017,10))
		ax.set_title(titles[count])
		# ax.set_xlabel('Year')
		count += 1

ax.legend(bbox_to_anchor=(0.34,-0.22),ncol=1,handlelength=3)

plt.subplots_adjust(bottom=0.25,top=0.95,left=0.09,right=0.97,hspace=0.4)

plotpath = plotdir + '/college.png'
plt.savefig(plotpath)
		
########################################################################
# Hours decomposition
dashlist = [(1,5),(3,5),(8,4,1,4),(1,0)]
subplotlist = [221,223,222,224]
lcolorlist = ['b','k','g','r']
fig = plt.figure(figsize=(8,6.5))

components = ['composition_effect','struct_effect','interact_effect','zeroed_uearnshare']
labels = ['Compositional Effect','Structural Effect','Interaction','Unadjusted Earnings Share']
titles = ['Men 25-34','Men 55-64','Women 25-34','Women 55-64']

count = 0
for gender in genders:
	filepath = datadir + '/hours_' + gender + '.csv'
	df = pd.read_csv(filepath,header=0,index_col=['agecat','year'])
	df = df.reset_index() 
	for agegrp in [25,55]:
		if agegrp == 25:
			df_age = df[df['agecat'] == '25-34 year olds']
		elif agegrp == 55:
			df_age = df[df['agecat'] == '55-64 year olds']

		ax = fig.add_subplot(subplotlist[count])
		

		for j,var in enumerate(components):
			ax.plot(df_age['year'],df_age[var],label=labels[j],dashes=dashlist[j],color=lcolorlist[j])

		ax.set_xlim(1976,2017)
		ax.set_xticks(np.arange(1976,2017,10))
		ax.set_title(titles[count])
		# ax.set_xlabel('Year')
		count += 1

ax.legend(bbox_to_anchor=(0.34,-0.22),ncol=1,handlelength=3)

plt.subplots_adjust(bottom=0.25,top=0.95,left=0.09,right=0.97,hspace=0.4)

plotpath = plotdir + '/hours.png'
plt.savefig(plotpath)
		
########################################################################
# EMS (educ/married/services) decomposition
dashlist = [(1,5),(3,5),(8,4,1,4),(1,0)]
subplotlist = [221,223,222,224]
lcolorlist = ['b','k','g','r']
fig = plt.figure(figsize=(8,6.5))

components = ['composition_effect','struct_effect','interact_effect','zeroed_uearnshare']
labels = ['Compositional Effect','Structural Effect','Interaction','Unadjusted Earnings Share']
titles = ['Men 25-34','Men 55-64','Women 25-34','Women 55-64']

count = 0
for gender in genders:
	filepath = datadir + '/ems_' + gender + '.csv'
	df = pd.read_csv(filepath,header=0,index_col=['agecat','year'])
	df = df.reset_index()
	for agegrp in [25,55]:
		if agegrp == 25:
			df_age = df[df['agecat'] == '25-34 year olds']
		elif agegrp == 55:
			df_age = df[df['agecat'] == '55-64 year olds']

		ax = fig.add_subplot(subplotlist[count])
		
		for j,var in enumerate(components):
			ax.plot(df_age['year'],df_age[var],label=labels[j],dashes=dashlist[j],color=lcolorlist[j])

		ax.set_xlim(1976,2017)
		ax.set_xticks(np.arange(1976,2017,10))
		ax.set_title(titles[count])
		# ax.set_xlabel('Year')
		count += 1

ax.legend(bbox_to_anchor=(0.34,-0.22),ncol=1,handlelength=3)

plt.subplots_adjust(bottom=0.25,top=0.95,left=0.09,right=0.97,hspace=0.4)

plotpath = plotdir + '/ems.png'
plt.savefig(plotpath)
	
plt.show()
