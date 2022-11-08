#https://www.tutorialspoint.com/how-to-plot-csv-data-using-matplotlib-and-pandas-in-python
import pandas as pd
import matplotlib.pyplot as plt

plt.rcParams["figure.figsize"] = [7.50, 3.50]
plt.rcParams["figure.autolayout"] = True

headers = ['Date', 'Pwr.kW', 'Pwr Max.kW', 'Energy.kWh', 'Ph I.A', 'Ph I Max.A']

df = pd.read_csv("C:\Users\fkomarek\AppData\Local\Temp\tmp78D4.tmp.csv", Date=headers)

df.set_index('Header').plot()

plt.show()