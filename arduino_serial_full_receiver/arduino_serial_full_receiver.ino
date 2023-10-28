// this code is designed to splice the incoming byte and use the individual
// bits to control different signals 

byte receivedData;

byte proximity;
byte sound;
byte state;

int proximity_num, sound_num, state_num;

int j, v;

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);      // set LED pin as output

  for (j = 2; j < 10; j++) {
    pinMode(j, OUTPUT);
  }
  
  for (v = 2; v < 10; v++) {
    digitalWrite(v, LOW);
  }  
  
  digitalWrite(LED_BUILTIN, LOW);    // switch off LED pin

  Serial.begin(9600);            // initialize UART with baud rate of 9600
}

void loop() {
  while (Serial.available()) {
    receivedData = Serial.read();   // read one byte from serial buffer and save to receivedData

    for (v = 2; v < 10; v++) {    // writes GPIO pins in response to the serial input
                                  // reads bits of incoming byte and set corresponding 
                                  // pins to high 
      digitalWrite( v, bitRead(receivedData, 7 - (v - 2) ) );
      
    }

    for (int i = 0; i  < 2; i++) {
      bitWrite(proximity, i , bitRead(receivedData, i));
    }

    for (int i = 2; i < 6; i++) {
      bitWrite(sound, i - 2, bitRead(receivedData, i));
    }

    for (int i = 6; i < 8; i++) {
      bitWrite(state, i - 6, bitRead(receivedData, i));
    }

    proximity_num = int(proximity);
    sound_num = int(sound);
    state_num = int(state);
    
  }

}
