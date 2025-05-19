import sys

sys.path.append('/home/pi/git/cflinstructors/CDHLab/SensorCheckout/pni_rm3100_driver/src/')
sys.path.append('/home/pi/git/cflinstructors/OtherHardware/')

import time
import smbus2 as smbus

import RV8803
import icm20948
import pni_rm3100
import qwiic_tmp102 
import bme680
from AD7998_instructor import AD7998
from Triclops import AD7994
from gpiozero import LED
from TCA9548A import TCA9548A

LED1 = LED(5); LED1_STAT = 0
LED2 = LED(26)

#Some variables
DATA_PATH = "/home/pi/Data/Telem/data"
GPS_PATH = "/home/pi/Data/GPS/NMEAs"
LOG_PATH = "/home/pi/Data/Logs/"
GPS_ADDR = 0x42

def toggleLED1():
    global LED1, LED1_STAT

    if LED1_STAT:
        LED1.off()
        LED1_STAT = 0
    else:
        LED1.on()
        LED1_STAT = 1

def getRTC(log_time):
    try:
        return RTC.getTime()
    except Exception as error:
        LED2.on()
        with open(f"{LOG_PATH}dataLog_{log_time}.txt", 'a') as f:
            f.write(f"* {time.time()}: RTC read failed: {error}\n")
        return f"\'{time.time()}"

def getIMU(log_time):
    try:
        ax, ay, az, gx, gy, gz = IMU.read_accelerometer_gyro_data()
        mx, my, mz = IMU.read_magnetometer_data()
        imuT = round(IMU.read_temperature(), 2)

        return [ax, ay, az, gx, gy, gz, mx, my, mz, imuT]
    except Exception as error:
        LED2.on()
        with open(f"{LOG_PATH}dataLog_{log_time}.txt", 'a') as f:
            f.write(f"* {time.time()}: IMU read failed: {error}\n")

        ### Need re-initialization here 
        return ["error"]*10

def getMag(log_time):
    try:
        return MAG.read_meas()
    except Exception as error:
        LED2.on()
        with open(f"{LOG_PATH}dataLog_{log_time}.txt", 'a') as f:
            f.write(f"* {time.time()}: RM3100 read failed: {error}\n")

        ### Need re-initialization here
        return ["error"]*3

def getTemp(log_time):
    try:
        return TEMP.read_temp_c()
    except Exception as error:
        LED2.on()
        with open(f"{LOG_PATH}dataLog_{log_time}.txt", 'a') as f:
            f.write(f"* {time.time()}: TMP102 read failed: {error}\n")
        return "error"

def getEnviro(log_time):
    try:
        ENVIRO.get_sensor_data()
        t = ENVIRO.data.temperature
        p = ENVIRO.data.pressure
        h = ENVIRO.data.humidity

        return [t, p, h]
    except Exception as error:
        LED2.on()
        with open(f"{LOG_PATH}dataLog_{log_time}.txt", 'a') as f:
            f.write(f"* {time.time()}: BME680 read failed: {error}\n")

        ### Need re-initialization here
        return ["error"]*3

def getSun(log_time):
    try:
        return SUN.get_data()
    except Exception as error:
        LED2.on()
        with open(f"{LOG_PATH}dataLog_{log_time}.txt", 'a') as f:
            f.write(f"* {time.time()}: PiBeanie read failed: {error}\n")
        return ["error"]*8

def getTriclops(log_time):
    try:
        return TRIC.get_data()[:3]
    except Exception as error:
        LED2.on()
        with open(f"{LOG_PATH}dataLog_{log_time}.txt", 'a') as f:
            f.write(f"* {time.time()}: Triclops read failed: {error}\n")
        return ["error"]*3

def getGPS(log_time):
    try:
        raw_bytes = i2cb.read_i2c_block_data(GPS_ADDR, 0xFD, 2)
        
        bytes_available = (raw_bytes[0]<<8) + (raw_bytes[1])
        if bytes_available > 20000: # Sometimes it retusn 2^15 available bytes for some reason
            return None
        
        if bytes_available:
            GPS_bytes = []
            try:
                curr_time = getRTC(log_time) # For sync-ing NMEA time to RTC time
            except Exception as error:
                curr_time = "\'" + str(time.time())
            
            num_bytes_read = 0
            num_GPS_bytes_read = 0
            
            while num_GPS_bytes_read < bytes_available:
                if num_bytes_read > 2*bytes_available: # Too many 0xFF bytes
                    break

                if (bytes_available - num_GPS_bytes_read) < 32: # Less than 32 bytes left
                    bytes_remaining = bytes_available - num_GPS_bytes_read
                    new_bytes = i2cb.read_i2c_block_data(GPS_ADDR, 0xFF, bytes_remaining)
                    num_bytes_read += bytes_remaining
                else:
                    new_bytes = i2cb.read_i2c_block_data(GPS_ADDR, 0xFF, 32)
                    num_bytes_read += 32

                for b in new_bytes:
                    if b == 0xFF: # Skip 0xFF bytes
                        continue
                    
                    GPS_bytes.append(b)
                    num_GPS_bytes_read += 1

            GPS_string = ''
            for b in GPS_bytes:
                GPS_string += chr(b) # Convert all bytes to characters

            if GPS_string:
                return f"{curr_time}, {bytes_available}\n{GPS_string}\n\n"
        
        return None
    except Exception as error:
        LED2.on()
        with open(f"{LOG_PATH}gpsLog_{log_time}.txt", 'a') as f:
            f.write(f"* {time.time()}: GPS read failed: {error}\n")
        return None

def main(initiate_time, new_file_interval):

    file_start = int(initiate_time)
    while True:
        ### Want a new file every {new_file_interval} seconds
        
        start = time.time()
        if (start - file_start) > new_file_interval:
            file_start = int(start)
        
        toggleLED1()

        """ # Descoping GPS
        GPS_data = getGPS(file_start)
        if GPS_data:
            with open(f"{GPS_PATH}_{file_start}.csv", 'a') as f:
                f.write(GPS_data)
        """

        for i in range(10):
            data_string = ""

            # Get all data
            try:
                sys_time = time.time()
            except:
                sys_time = "error"
            curr_time = getRTC(file_start)
            imu_data = getIMU(file_start)
            mag_data = getMag(file_start)
            temp_data = getTemp(file_start)
            enviro_data = getEnviro(file_start)
            pd_data = getSun(file_start)
            tric_data = getTriclops(file_start)

            # list -> str
            imu_data = ','.join(map(str, imu_data))
            mag_data = ','.join(map(str, mag_data))
            enviro_data = ','.join(map(str, enviro_data))
            pd_data = ','.join(map(str, pd_data))
            tric_data = ','.join(map(str, tric_data))

            # Construct and store data entry
            data_string = f"{sys_time},{curr_time},{imu_data},{mag_data},{temp_data},{enviro_data},{pd_data},{tric_data}\n" 
            with open(f"{DATA_PATH}_{file_start}.csv", 'a') as f:
                f.write(data_string)
        
        end = time.time()
        #print("GPS read time:\t\t", round(start1-start,3))
        #print("Telem read time:\t", round(end-start1,3), "\n")
        print("Telem read time:\t", round(end-start, 3))
        if (end-start) < 1:
            time.sleep(1-(end-start))
            end = time.time()
        
        LED2.off()

### Start
i2cb = smbus.SMBus(1)
i2c_mux = TCA9548A()
i2c_mux.change_address(0x70)
i2c_mux.allOn()
start_time = int(time.time())

### Initiate sensors
RTC = RV8803.RV_8803()  # Real-time clock
TEMP = qwiic_tmp102.QwiicTmp102Sensor(0x4b) # Temperature sensor
SUN = AD7998(0x23)  # Sun sensors
TRIC = AD7994(0x24) # Triclops

try:
    IMU = icm20948.ICM20948(0x69)   # Inertial measurement unit 
    IMU.set_accelerometer_full_scale(8)
    IMU.set_gyro_full_scale(1000)
except Exception as error:
    with open(f"{LOG_PATH}startLog_{start_time}.txt", 'a') as f:
        f.write(f"* {time.time()}: IMU init or config failed: {error}\n")

try:
    MAG = pni_rm3100.PniRm3100()    # RM3100 magnetometer
    MAG.assign_device_addr(0x22)
    MAG.write_config()
except Exception as error:
    with open(f"{LOG_PATH}startLog_{start_time}.txt", 'a') as f:
        f.write(f"* {time.time()}: RM3100 init or config failed: {error}\n")

try:
    TEMP = qwiic_tmp102.QwiicTmp102Sensor(0x4b) # Temperature sensor
    TEMP.begin()
except Exception as error:
    with open(f"{LOG_PATH}startLog_{start_time}.txt", 'a') as f:
        f.write(f"* {time.time()}: TMP102 config failed: {error}\n")

try:
    ENVIRO = bme680.BME680(0x77)    # Environmental sensor
except Exception as error:
    with open(f"{LOG_PATH}startLog_{start_time}.txt", 'a') as f:
        f.write(f"* {time.time()}: BME680 init failed: {error}\n")

### Start main thread
main(time.time(), 300)

