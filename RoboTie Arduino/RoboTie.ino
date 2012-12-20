/*
  Software serial multple serial test
 
 Receives from the hardware serial, sends to software serial.
 Receives from software serial, sends to hardware serial.
 
 The circuit: 
 * RX is digital pin 2 (connect to TX of other device)
 * TX is digital pin 3 (connect to RX of other device)
 
 created back in the mists of time
 modified 9 Apr 2012
 by Tom Igoe
 based on Mikal Hart's example
 
 This example code is in the public domain.
 
 */
#include <SoftwareSerial.h>
#include <Servo.h> 

#define WFRX 2
#define WFTX 3
#define UNIVBAUD 9600
#define LED13 13
#define TIESERVO 6

Servo neckTie;

int tiePositions[] = {
  0,60,80,100,120};
int tieCurrent = 0;
char incomingByte = -1;
String incomingMessage = "";
boolean startMessage = false;

SoftwareSerial wiFlySerial(WFRX, WFTX); // RX, TX
void setup()  
{
  // Open serial communications and wait for port to open:
  //Serial.begin(UNIVBAUD);
  //Serial.println("[TIEREADY]");
  pinMode(LED13, OUTPUT);     
  // set the data rate for the SoftwareSerial port
  wiFlySerial.begin(UNIVBAUD);
  wiFlySerial.println("[TIEREADY]");
  // attach the servo
  neckTie.attach(TIESERVO);
  neckTie.write(tiePositions[tieCurrent]);
  // wait a while
}

void loop() // run over and over
{
  incomingByte = -1;
  /*
  if (wiFlySerial.available() > 0)
   Serial.write(wiFlySerial.read());
   */
  if (wiFlySerial.available() > 0) {
    // read the incoming byte:
    incomingByte = wiFlySerial.read();
    if(incomingByte == '[') {
      startMessage = true;
      incomingMessage = "";
    }
    incomingMessage.concat(incomingByte);
    if(incomingByte == ']') {
      startMessage = false;
      //Serial.println(incomingMessage);
      if(incomingMessage=="[UP]") {
        //digitalWrite(LED13, HIGH);
        tieCurrent++;
        if(tieCurrent >= 5) {
          tieCurrent=5;
        }
        neckTie.write(tiePositions[tieCurrent]);
        delay(2000);
        wiFlySerial.println("[TIEREADY]");
        //digitalWrite(LED13, LOW);
      }
      if(incomingMessage=="[RESET]") {
        tieCurrent = 0;
        //digitalWrite(LED13, HIGH);
        neckTie.write(tiePositions[tieCurrent]);
        delay(2000);
        wiFlySerial.println("[TIEREADY]");
        //digitalWrite(LED13, LOW);
      }
    }    
  }    
  /*
  if (Serial.available())
    wiFlySerial.write(Serial.read());
  */
}

