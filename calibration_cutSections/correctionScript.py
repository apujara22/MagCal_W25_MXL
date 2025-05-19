import numpy as np
import csv

#import magCalMeasure  #runs file to measure magnetic field vals as vehicle is rotated
import magCalParameter_copy  #runs parameter calculations, outputs to file
#import correctSensor_v6

# See accompanying documentation for how to use this code.
inputFileName = input("Name for raw magnetometer data storage file: ")
inputMagNorm = float(input("Reference normal magnetic field at test site (preferably check outdoors with IGRF/WMM): "))

parameters = magCalParameter_copy.main(inputFileName, inputMagNorm)
#parameters = np.array([ 0.948703, 0.980563, 0.962968, 21.23215, -16.85612, 22.48725, 0.0171833, 0.0191973, 0.0122694 ])

'''
# Load the data from the CSV file
data = np.genfromtxt(inputFileName, delimiter=',', names=True, dtype=None, encoding='utf-8')

# Extract the three columns as separate arrays
columns = data.dtype.names
bxhat = data[columns[0]]
byhat = data[columns[1]]
bzhat = data[columns[2]]

data = correctSensor_v6.correctSensor_v6(parameters, bxhat, byhat, bzhat)

dataTransp = data.T

output_file = (f"cali_{inputFileName}")
with open(output_file, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["cali_x", "cali_y", "cali_z"])
    writer.writerows(dataTransp)

'''