// The intention of this code is to simulate the signals the fpga would receive and then 
// transmit as an 8-bit value

// 8-bit value is produced here using GPIO pins which is then transmitted via serial

int i, j, v;
bool p;
byte a; 

void setup() {
  // put your setup code here, to run once:
  Serial2.begin(9600);
  Serial.begin(9600);

  pinMode(LED_BUILTIN, OUTPUT);      // set LED pin as output
  digitalWrite(LED_BUILTIN, LOW);    // switch off LED pin
  
  p = 0;
  
  for (j = 2; j < 10; j++) {  // initialises all of input GPIO pins
    pinMode(j, OUTPUT);
  }
  
}

void loop() {

  if ( p == 1) {
    digitalWrite(LED_BUILTIN, HIGH);  // communicates that the board should be transmitting

    for (v = 2; v < 10; v++) {    // writes individual bits of the byte: "a" using bitWrite
      bitWrite(a, v - 2 ,digitalRead(v));
    }
    
    Serial2.write(char(a));
    Serial.write(char(a));    // to display on serial monitor
  }
  else {
    digitalWrite(LED_BUILTIN, LOW);
  }
  
  delay(200);
  p = !p;
  
}
