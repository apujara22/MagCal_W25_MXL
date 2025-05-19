import numpy as np
import csv
import os

inputFileName = "data_circles_offset_00.csv" # Name for raw magnetometer data storage file
biasType = "offset" # Type of bias to insert (scale, offset, or angle)
biasVector = np.array([-2, -5, -10, -20]) #Factors to modify data by

# Load the data from the CSV file
data = np.genfromtxt(inputFileName, delimiter=',', names=True, dtype=None, encoding='utf-8')
print(data)

# Extract the three columns as separate arrays
columns = data.dtype.names
bxhat = data[columns[0]]
byhat = data[columns[1]]
bzhat = data[columns[2]]

for biasAmount in biasVector:
    
    if biasType == "scale":
        bxhat1 = biasAmount * bxhat
        byhat1 = biasAmount * byhat
        bzhat1 = biasAmount * bzhat

    if biasType == "offset":
        bxhat1 = biasAmount + bxhat
        byhat1 = biasAmount + byhat
        bzhat1 = biasAmount + bzhat

    if biasType == "angle":
        #bxhat = biasAmount + bxhat
        #byhat = biasAmount + byhat
        bzhat1 = bzhat

    data1 = (np.array([bxhat1, byhat1, bzhat1])).T
    print(data1)

    output_folder = "calibration_circles"
    filename = os.path.join(output_folder, f"data_circles_{biasType}_{biasAmount}.csv")

    with open(filename, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["mag_x", "mag_y", "mag_z"])
        writer.writerows(data1)

