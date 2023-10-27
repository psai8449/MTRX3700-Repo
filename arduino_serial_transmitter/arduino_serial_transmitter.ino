
uint8_t c; 
uint8_t b; 

void setup() {
  // put your setup code here, to run once:
  Serial2.begin(9600);
  Serial1.begin(9600);
  pinMode(3, INPUT);
//  pinMode(4, INPUT);
  pinMode(LED_BUILTIN, OUTPUT);      // set LED pin as output
  digitalWrite(LED_BUILTIN, LOW);    // switch off LED pin
}

void loop() {
  // put your main code here, to run repeatedly
  c = 0b01100001;   // 0b10000000
  b = 0b01100010;   // 0b00000001

  Serial.print(a);
  
  if (digitalRead(3) == HIGH) {
    Serial2.write(c);
    Serial.write(c);
    digitalWrite(LED_BUILTIN, HIGH);    // switch off LED pin
  }
  else {
    Serial2.write(b);
    Serial.write(b);
    digitalWrite(LED_BUILTIN, LOW);    // switch off LED pin
  };
}
