import pandas as pd
import matplotlib.pyplot as plt
import sys
from config import options

#this part is created by https://github.com/VIPTrollik

def graph_data(input_file_name, output_file_name, size = (20, 10), dpi=80, smoothing=20, secondary_smoothing=0, title = None, font_size=20, normalize=True):
    print("loading data")
    data = pd.read_csv(input_file_name, sep=';', index_col=False, parse_dates=['Date'])
    plt.rcParams.update({'font.size': font_size})
    print("plotting")
    if normalize:
        for ind in data.columns:
            col = data[ind]
            if ind != 'Date':
                data[ind]=((col-col.mean())/col.std())
    if smoothing != 0:
        for ind in data.columns:
            col = data[ind]
            if ind != 'Date':
                data[ind]=col.rolling(smoothing).mean()
    if secondary_smoothing != 0:
        for ind in data.columns:
            col = data[ind]
            if ind != 'Date':
                data[ind]=col.rolling(smoothing).mean()
    fig, axs = plt.subplots(2, dpi=dpi, figsize=size)
    #plot data
    axs[0].plot(data['Date'], data["Pwr Max.kW"], label="Pwr Max.kW")
    axs[0].plot(data['Date'], data["Pwr.kW"], label="Pwr.kW")
    axs[1].plot(data['Date'], data["Ph I Max.A"], label="Ph I Max.A")
    axs[1].plot(data['Date'], data["Ph I.A"], label="Ph I.A")
    #show legend / labels
    axs[0].legend()
    axs[1].legend()

    axs[0].set_ylabel("kW")
    axs[1].set_ylabel("Amps")
    if title:
        plt.title = title
    #data.plot(y=["Pwr.kW", "Pwr Max.kW", "Ph I.A", "Ph I Max.A"], x="Date", figsize=size)

    print("saving image")
    #save file
    plt.savefig(output_file_name, dpi=dpi)

if __name__ == '__main__':
    try:
        args = sys.argv[1:]
        input = args[0]
        output = args[1]

        graph_data(input, output, **options) # <-- options here


    except Exception as e:
        print("Usage: python3 grafovani.py input_file_name output_file_name \n Config options are in config.py")
        print(e)
