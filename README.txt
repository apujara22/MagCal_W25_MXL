Magnetometer calibration research work for MXL, Winter 2025 semester. Hosted by Ayush Pujara (ayushpuj@umich.edu).

Folders:
"ADSvehicle": ADS vehicle data analysis
"calibrated_magnetometer_params": calibration parameters output from calibration script
"calibration_circle_char": comparing different methods for perfect attitude spheres
"calibration_cutSections": removing different parts of the attitude sphere
"calibration_knownBiases": injecting different known biases into perfect data
"calibration_noisy": injecting radial noise into perfect attitude sphere
"calibration_sierra": calibrating data from Team Sierra's CFL flight
"calibration_test0": calibrating test data collected previously and found in MXL GDrive
"geomag70_windows": contains script to determine ambient magnetic field at specified date and time

Code Files:
"correctionScript": incorporates correctSensor_v6, magCalMeasure, and magCalParameter_copy into one script that finds the calibration parameters and calibrates the data according to those parameters. The calibrated dataset is saved to this folder, and the calibration parameters are saved to calibrated_magnetometer_params
"generateBiasedDatasets": used to create datasets with some offset or scaling bias

All other code files in this folder are described in the "Mag Calibration" folder in the MXL GDrive.
