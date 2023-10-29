#include <SoftwareSerial.h> 
#include "stdio.h"
SoftwareSerial btSerial(2,3);//rx,tx 
void setup(){ 
  Serial.begin(9600); // connect serial 
  btSerial.begin(38400); // connect bt
  //You may need to change the BAUD rate from 38400 to 9600, depending on the chip.
} 
 
#define ENA 5
#define ENB 6
#define IN1 7
#define IN2 8
#define IN3 9
#define IN4 4
 
 
char buf[50];
int lastPos=0;
long xIn, yIn;
long leftWheel;
long rightWheel;
bool leftForward;
bool rightForward;
 
#define MAX_TIMEOUT 1000
int messageTimeout = MAX_TIMEOUT; // Amount of time before we force the car to E-STOP.

void loop(){
    while (btSerial.available()){
        buf[lastPos]=btSerial.read() ;
        lastPos = lastPos + 1;
    }
 
    while (Serial.available()){
        buf[lastPos]=Serial.read() ;
        lastPos = lastPos + 1;
    }
 
    if (lastPos>0 && buf[lastPos-1]=='\n'){
        buf[lastPos]='\0';
        // Interpret the message
        sscanf(buf,"%d %d\n",&xIn, &yIn);
 
        leftWheel=((xIn-512) + (yIn-512))/4; // Rescale from 1024 to 255 
        rightWheel=((xIn-512) - (yIn-512))/4;
 
        Serial.println(leftWheel);
        Serial.println(rightWheel);
 
        leftForward=leftWheel>0;
        if (!leftForward)leftWheel=-leftWheel;
 
        rightForward=rightWheel>0;
        if (!rightForward)rightWheel=-rightWheel;
        messageTimeout=MAX_TIMEOUT;
        lastPos=0;
    }
    
    if (messageTimeout>0){
        //control speed 
        analogWrite(ENA, leftWheel);
        analogWrite(ENB, rightWheel); 
        //control direction 
        digitalWrite(IN1, leftForward);
        digitalWrite(IN2, !leftForward);
        digitalWrite(IN3, rightForward);
        digitalWrite(IN4, !rightForward);
        messageTimeout--;
    }else{
        //ESTOP
        //control speed 
        analogWrite(ENA, 0);
        analogWrite(ENB, 0); 
    }
}