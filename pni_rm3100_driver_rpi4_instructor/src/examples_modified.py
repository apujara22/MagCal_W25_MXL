import math
import time
import numpy as np
import pandas as pd

import pni_rm3100
###############################################################################
###Setup: 
## Instantiate Objects
pni_rm3100_device = pni_rm3100.PniRm3100()

## Choose (not assigning yet) a PNI Device Address (using PniRm3100() sub-classes), 
## uncomment one of the below lines:
# device_address = pni_rm3100_device.DeviceAddress.I2C_ADDR_LL #0x20
device_address = pni_rm3100_device.DeviceAddress.I2C_ADDR_HL #0x21
# device_address = pni_rm3100_device.DeviceAddress.I2C_ADDR_LH #0x22
# device_address = pni_rm3100_device.DeviceAddress.I2C_ADDR_HH #0x23

## Choose which test case/option you would like to run:
## uncomment one of the below lines:
# test_execution = 1 #execute_self_test()
# test_execution = 2 #execute_continuous_measurements_with_assigned_settings()
# test_execution = 3 #execute_continuous_measurements_with_default_config
test_execution = 4 #continuous_measurement_collection
###############################################################################

"""
execute_self_test
    Example of running a BIST (Built In Selt Test) to check the 
    status of the three magnetic field sensors.
"""
def execute_self_test():
    # Set Print Settings
    pni_rm3100_device.print_status_statements = True
    pni_rm3100_device.print_debug_statements = True

    # Set PNI Device Address
    pni_rm3100_device.assign_device_addr(device_address)

    # Select which axes to test during the Built-In Self Test (BIST)
    pni_rm3100_device.assign_poll_byte(poll_x = True, poll_y = True, poll_z = True)

    # Select the Timeout and LRP for the BIST. Then Enable Self-Test mode
    pni_rm3100_device.assign_bist_timeout(pni_rm3100_device.BistRegister.BIST_TO_120us)
    pni_rm3100_device.assign_bist_lrp(pni_rm3100_device.BistRegister.BIST_LRP_4)
    pni_rm3100_device.assign_bist_ste(True)

    # Run the Self Test
    pni_rm3100_device.self_test()

###############################################################################

def continuous_measurement_collection(numMeasurements = 10, dt_seconds = (1/37)):
    # Instantiate Objects
    pni_rm3100_device = pni_rm3100.PniRm3100()

    # Assign PNI Device Address
    pni_rm3100_device.assign_device_addr(device_address)
    
    # Initialize Data Array of Size (numMeasurements x 3)
    data_array = np.zeros((numMeasurements, 3));

    # Now that we've enabled CMM (Continous Measurement Mode), let's read some magnetometer values!
    print("Reading measurements: [starting measurement loop]")
    for i in range(numMeasurements):
        # Print measurement loop progress
        #print("\n\n\t{} of {} in moving avg window".format(i, moving_avg_window))

        # Read magnetic field data (microtesla/uT output)
        magnetometer_readings = pni_rm3100_device.read_meas()

        x_mag = magnetometer_readings[0]
        y_mag = magnetometer_readings[1]
        z_mag = magnetometer_readings[2]
        data_array[i, :] = magnetometer_readings        
        #print(f"Magnetic Field (x, y, z) (uT): {x_mag}, {y_mag}, {z_mag}")

        # Sleep and incremenet iterator
        time.sleep(dt_seconds)

    print(data_array)
    
    df = pd.DataFrame(data_array, columns=["CalibratedX", "CalibratedY", "CalibratedZ"])
    df.to_csv("git/pni_rm3100_driver/src//magCalLab_calibrated", index=False)


###############################################################

# This is the code that will execute when you type "python3 smbus_pni_rm3100_examples" in the terminal
# Please only un-comment one of these at a time.
if __name__=="__main__":
    if test_execution == 1:
        execute_self_test()                                      # Perform a BIST (built-in self test) on the RM3100
    elif test_execution == 2:
        execute_continuous_measurements_with_assigned_settings() # Read data form RM3100 in continuous mode
    elif test_execution == 3:
        execute_continuous_measurements_with_default_config()    # Read data form RM3100 in continuous mode
    elif test_execution == 4:
        continuous_measurement_collection()
    else:
        print("UNDEFINED TEST CASE SELECTED")
