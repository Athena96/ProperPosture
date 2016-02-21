// Author:    Jared Franzone
// File:      Arduino_ProperPosture
// Version:   1.0
// Purpose:   Hackillinois
// History:
//            1.0 initial version

#include "StopWatch.h"
#include <SoftwareSerial.h>

// My Timer object
StopWatch timer(StopWatch::SECONDS);
// My Bluetooth object
SoftwareSerial bluetooth(4,5);   // (RX -> D4 & TX /> D5)


// Flex Sensor Pin
int posturePin = A0;

// Flex Sensor Reading
int postureReading = 0;
// Adjusted Value
int posture = 0;

// Elapsed time of the timer
unsigned long durationOfGoodPosture = 0;

// Initial input values
const int TYP_MIN = 540;         // NEED TO FIND
const int TYP_MAX = 705;         // NEED TO FIND

// Range for Good Posture
const int maxAcceptable = 105;   // NEED TO FIND
const int minAcceptable = 98;   // NEED TO FIND

// Delay messages
const int WAIT = 1000;

void setup() {
  
  // Begin Serial Communication
  bluetooth.begin(9600);

} // end setup

void loop() {
  
  // Get Posture Reading
  postureReading = analogRead(posturePin);
  posture = map(postureReading, TYP_MIN, TYP_MAX, 0, 100);
  
  // If the Value is in the good range
  bool goodPosture = (posture >= minAcceptable) && (posture <= maxAcceptable);
  if (goodPosture) {
    
    // If timer hasn't been started
    bool timerNotStarted = (timer.isRunning() == false);
    if (timerNotStarted) {
      timer.start();
    }
    
  } else {
    timer.stop();
    bluetooth.print("-------");
  }
  
    delay(WAIT);
  
    durationOfGoodPosture = timer.elapsed();
    String temp = "0000";
    temp.concat(String(durationOfGoodPosture, DEC));
      
    bluetooth.print(temp); // DOES THIS NEED TO BE A STRING
    delay(100);
  

  
} // end loop()
