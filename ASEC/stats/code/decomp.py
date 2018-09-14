import pandas as pd
import matplotlib.pyplot as plt
import os
import numpy as np
import sys

def weightedsum(grp):
	return np.sum(grp['asecwt']*grp['incwage'])


## Plots decomposition data from output/plot_data

datadir = '/Users/Brian/Documents/GitHub/AgeEarningsShare/ASEC/build/output/ASEC.csv'
df = pd.read_csv(datadir,header=0)
df.drop(5111662,axis=0,inplace=True)
#df = df.loc[df['industry']==1]

## Adjust by education
# Important statistics
year_group = df.groupby('year')
df['popt'] = year_group['asecwt'].transform(np.sum)
agg_earnt = year_group.apply(weightedsum)
df = df.merge(agg_earnt.to_frame(name='earnt'),left_on='year',right_index=True)

age_year_group = df.groupby(['year','agecat'])
df['popjt'] = age_year_group['asecwt'].transform(np.sum)
agg_earnjt = age_year_group.apply(weightedsum).to_frame(name='earnjt')
df = df.merge(agg_earnjt,how='outer',left_on=['year','agecat'],right_index=True)

df['uearnsharejt'] = df['earnjt']/df['earnt']
df['popsharejt'] = df['popjt']/df['popt']


year_group_1976 = df.groupby('year').get_group(1976)
earnshare_1976 = (year_group_1976
	.groupby('agecat')[['agecat','uearnsharejt']]
	.agg(lambda x: x.iloc[0])
	.rename(columns={'uearnsharejt':'earnshare_1976'}))
df = df.merge(earnshare_1976,how='outer',on='agecat')

## Decomposition
# Unique index
Zvars = ['college','nonwhite','services']
#Zvars = ['college']
uniques = df[Zvars].drop_duplicates()
uniques['Z'] = uniques.reset_index(drop=True).index
df = df.merge(uniques,how='outer',on=Zvars)

# Shares of Z and age groups:
Z_year_group = df.groupby(['Z','agecat','year'])
df['popjkt'] = Z_year_group['asecwt'].transform(np.sum)
agg_earnjkt = Z_year_group.apply(weightedsum)
df = df.merge(agg_earnjkt.to_frame(name='earnjkt'),how='left',left_on=['Z','agecat','year'],right_index=True)
df['popsharejkt'] = df['popjkt']/df['popt']
df['mearnjkt'] = df['earnjkt']/df['popjkt']

# Drop duplicates
df.drop_duplicates(['year','agecat','Z'],inplace=True)

# Compute lagged variables
variables_to_lag = ['earnjkt','popsharejkt','mearnjkt']
for lvar in variables_to_lag:
	lagname = 'L_' + lvar
	df[lagname]=df.sort_values('year').groupby(['Z','agecat'])[lvar].shift(1)

# Compute lagged earnings share to check error
df['num_terms'] = df['L_popsharejkt']*df['L_mearnjkt']
df['numerator'] = df.groupby(['year','agecat'])['num_terms'].transform(np.sum)
df['denominator'] = df.groupby(['year','Z'])['numerator'].transform(np.sum)
df['est_L_uearnshare'] = df['numerator']/df['denominator']
#df.drop(['num_terms','numerator','denominator'],axis=1,inplace=True)

df.sort_values(['agecat','Z','year',],inplace=True)
print(df[['agecat','Z','year','uearnsharejt','est_L_uearnshare','numerator','denominator','mearnjkt','popsharejkt']])
print(df.groupby(['agecat','Z']).size())

