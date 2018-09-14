import pandas as pd
import matplotlib.pyplot as plt
import os
import numpy as np
import sys

def weightedsum(grp):
	return np.sum(grp['asecwt']*grp['incwage'])


## Plots decomposition data from output/plot_data

datadir = '/Users/brianlivingston/Documents/GitHub/AgeEarningsShare/ASEC/build/output/ASEC.csv'
df = pd.read_csv(datadir,header=0)

## Adjust by education
# Important statistics
year_group = df.groupby('year')
df['popt'] = year_group['asecwt'].transform(np.sum)
agg_earnt = year_group.apply(weightedsum)
df = df.merge(agg_earnt.to_frame(name='earnt'),left_on='year',right_index=True)

age_year_group = df.groupby(['year','agecat'])
df['popjt'] = age_year_group['asecwt'].transform(np.sum)
agg_earnjt = age_year_group.apply(weightedsum).to_frame(name='earnjt')
df = df.merge(agg_earnjt,how='outer',on=['year','agecat'])

df['uearnsharejt'] = df['earnjt']/df['earnt']
df['popsharejt'] = df['popjt']/df['popt']


year_group_1976 = df.groupby('year').get_group(1976)
earnshare_1976 = year_group_1976.groupby('agecat')['uearnsharejt'].agg(lambda x: x.iloc[0])
df = df.merge(earnshare_1976.to_frame(name='earnshare_1976'),how='outer',on='agecat')
