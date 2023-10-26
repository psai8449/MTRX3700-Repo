void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(3, INPUT);
//  pinMode(4, INPUT);

  pinMode(LED_BUILTIN, OUTPUT);      // set LED pin as output
  digitalWrite(LED_BUILTIN, LOW);    // switch off LED pin
}

void loop() {
  // put your main code here, to run repeatedly
  if (digitalRead(3) == HIGH) {
    Serial.write("1");
    digitalWrite(LED_BUILTIN, HIGH);    // switch off LED pin
  }
  else {
    Serial.write("0");
    digitalWrite(LED_BUILTIN, LOW);    // switch off LED pin
  };
}
