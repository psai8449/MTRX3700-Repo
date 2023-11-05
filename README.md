# MTRX3700-Repo
A repository to upload all group assignment files

[[https://1drv.ms/w/s!Am_farsU0-mkgqxSx22SVp1s4h2BbA?e=mvAuyJ](https://1drv.ms/w/s!Am_farsU0-mkgqxS2RDZbW59sHZawQ?e=kTSG8P)https://1drv.ms/w/s!Am_farsU0-mkgqxS2RDZbW59sHZawQ?e=kTSG8P](https://1drv.ms/w/s!Am_farsU0-mkgqxSNhareMY0SiDbpA?e=ovzwac)https://1drv.ms/w/s!Am_farsU0-mkgqxSNhareMY0SiDbpA?e=ovzwac

We have several versions of our robot code: 
-  robot: which is the most basic version which we can gaurantee will work if given the opportunity to demonstrate
-  advance robot: which is similar to robot but also integrates the bluetooth module, can gaurantee that it works
-  hopeful robot: A step up from advanced robot, integrates microphone module, can't garauntee it works

OUR FINAL PROJECT FOLDER IS THE HOPEFUL ROBOT

In IR - Proximity - IOT demo video we demonstrate the robot basically fully integrated and functioning, demonstrates how IOT, proximity sensor and IR remote all working in harmony.

Unfortunately, video of the bluetooth module working was not taken although we can gaurantee it works.

Video of the motors working is available but not in harmony with the fully integrate module. Video of the motors working with the IR remote is available although has not been provided because canvas only allows us to upload one video. The video we've submitted does actually have the functioning motor control code integrated into it, it just wasn't demonstrated in this video, we can gaurantee that this works if given the opporunity to demonstrate.

Video of the microphone code working individually is available but we did not get the opportunity to integrate and test, the hopeful robot project file is our final code and it does have the microphone code integrated into it and should work in theory as the microphone code functions quite simply.


OUR DISCORD CHANNEL: https://discord.gg/hqdzHPeA

arduino_serial_full_receiver: used to demonstrate that FPGA and arduinos are transmitting via UART correctly, display data on serial monitor

arduino_serial_transmitter_full: used to emulate HM_10 or FPGA to test bluetooth and IOT function

arduino_serial_receiver_iot: Code on the ESP8266, receives and interpets the data it receives via UART from the FPGA

proximity_sensor: standalone project used to demonstrate the proximity sensor function

microphone Code Final: standalone with microphone configured to project requirements used demonstrate and prepared to integrate

DE2_115_IR: Provided standalone IR remote project, demonstrates IR remote function
