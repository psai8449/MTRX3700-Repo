# Bluetooth master

import serial

ser = serial.Serial("COM13", 9600, timeout = 1)

while (True):
    uInput = input("Retrieve data? ")
    if uInput == '1':
        ser.write(b'1')
    if uInput == '0': 
        ser.write(b'0')

ser.close()
