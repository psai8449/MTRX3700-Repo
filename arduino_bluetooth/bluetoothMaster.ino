#include <SoftwareSerial.h> 
#include "stdio.h"
SoftwareSerial btSerial(2,3);//rx,tx 

void setup(){ 
  Serial.begin(9600); // connect serial 
  btSerial.begin(38400); // connect bt
  //You may need to change the BAUD rate from 9600 to 38400, depending on the chip.
  pinMode(10,INPUT);
} 

char buf[50];
int xIn;
int yIn;

void loop(){
  //Check if throttle is held
  if (digitalRead(10) == HIGH){
    //Get the X and Y positions of the joystick.
    xIn = analogRead(0);
    yIn = analogRead(1);
    sprintf(buf,"%d %d\n", xIn,yIn);
    Serial.write(buf);
    btSerial.write(buf);
    delay(50); // throttle so bluetooth can keep up
  }
}