import pandas as pd

basedir = '/Users/Brian/Documents/GitHub/ASEC/stats/output/plot_data'

genders = ['men','women']
for gender in genders:
	filepath = basedir + '/unadjusted_' + gender + '.csv'
	df = pd.read_csv(filepath,header=0,index_col=['year','agecat'])
