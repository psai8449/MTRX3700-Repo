#include <SoftwareSerial.h> 
#include "stdio.h"


SoftwareSerial HM10(2,3);//rx,tx 

void setup(){ 
  HM10.begin(9600);
  Serial.begin(9600); // connect bt
  //You may need to change the BAUD rate from 38400 to 9600, depending on the chip.
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);

  delay(1500);
} 
 
byte buf;

void loop(){
    HM10.listen();
    while (HM10.available()){
        buf = HM10.read() ;

        if (buf == '1'){
          digitalWrite(LED_BUILTIN, HIGH);
        }
        else if (buf == '0'){
          digitalWrite(LED_BUILTIN, LOW);
        }
    }

}
