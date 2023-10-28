
byte c; 
byte b; 
bool a;

void setup() {
  // put your setup code here, to run once:
  Serial2.begin(9600);
  Serial.begin(9600);

  pinMode(LED_BUILTIN, OUTPUT);      // set LED pin as output
  digitalWrite(LED_BUILTIN, LOW);    // switch off LED pin
  a = 0;
}

void loop() {
  // put your main code here, to run repeatedly
  c = 0b10000000;   // 0b10000000
  b = 0b00000001;   // 0b00000001

  
  if (a == 1) {
    Serial2.write(c);
    Serial.write(c);
    digitalWrite(LED_BUILTIN, HIGH);    // switch off LED pin
  }
  else {
    Serial2.write(b);
    Serial.write(b);
    digitalWrite(LED_BUILTIN, LOW);    // switch off LED pin
  };

  delay(1000);
  a = !a;
}
