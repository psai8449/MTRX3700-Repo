void setup() {
  pinMode(LED_BUILTIN, OUTPUT);      // set LED pin as output
  digitalWrite(LED_BUILTIN, LOW);    // switch off LED pin

  Serial1.begin(9600);            // initialize UART with baud rate of 9600
}

void loop() {
  while (Serial1.available() >= 0) {
    char receivedData = Serial1.read();   // read one byte from serial buffer and save to receivedData

    if (receivedData == 0b10000000) {
      digitalWrite(LED_BUILTIN, HIGH); // switch LED On0
    }
    else if (receivedData == 0b00000001) {
      digitalWrite(LED_BUILTIN, LOW);  // switch LED Off
    }
  }
}
