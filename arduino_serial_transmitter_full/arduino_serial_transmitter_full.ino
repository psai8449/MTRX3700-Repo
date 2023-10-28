

int i, j;
bool p;

void setup() {
  // put your setup code here, to run once:
  Serial2.begin(9600);
  Serial.begin(9600);

  pinMode(LED_BUILTIN, OUTPUT);      // set LED pin as output
  digitalWrite(LED_BUILTIN, LOW);    // switch off LED pin
  
  p = 0;
  
  byte a [8]; 
  for (j = 0; j < 8; j++){
    a[j] = 1 << j;
  }
  
}`

void loop() {
  // put your main code here, to run repeatedly
  if ( p == 1) {
    digitalWrite(LED_BUILTIN, HIGH);
    
    if ( i == 8 ){
      i = 0;
    }
    
    Serial2.write(a[i]);
    Serial.write(a[i]);
    i++;
  }
  else {
    digitalWrite(LED_BUILTIN, LOW);
  }
  
  delay(1000);
  p = !p;
  
}
