/*
 * Arduino-Code for two arm plotter, recieving commands via serial port from processing script
 */
#include <math.h>
#include <Servo.h>

String readString;
String a;

boolean connection = false;

Servo servo1;
Servo servo2;
Servo servo3;

void setup() {
  Serial.begin(9600);
  Serial.println('r'); // sending ready-signal to serial device

  servo1.attach(9);   //pin for Servo 1
  servo2.attach(10);  //pin for Servo 2
  servo3.attach(11);  //pin for Servo 3
}

void loop() {
  if (Serial.available())  {
    char c = Serial.read();  //gets one byte from serial buffer
    if (c == 'r') { //if there is a ready-signal from serial
      Serial.println('c'); //sending command request
      connection = true;
    }
    if (c == 'G') {  //if incoming string is a gcode string
      a = Serial.readString(); //store incoming G-Code command in String
      int iX = a.indexOf('X'); //get sting-index of X-coordinate
      int iY = a.indexOf('Y'); //get string-index of Y-coordinate

      String cX = a.substring(iX + 1, iY); //get X-Coordinate by seperating incoming string (without anything else, just the numbers!)
      String cY = a.substring(iY + 1, a.length()); //get Y-Coordinate by seperating incoming string (without anything else, just the numbers!)

      Serial.println(a); //prints string to serial port  (for debugging)
      //Serial.println(cX); //prints string to serial port  (for debugging)
      //Serial.println(cY); //prints string to serial port  (for debugging)

      plotter(cX, cY); //send commands to plotter function, executing the command

      readString=""; //clears variable for new input
     }
     else if (c == 'M') {  //if incoming string is a gcode string
      a = Serial.readString(); //store incoming G-Code command in String
      int iX = a.indexOf('X'); //get sting-index of X-coordinate
      int iY = a.indexOf('Y'); //get string-index of Y-coordinate

      String cX = a.substring(iX + 1, iY); //get X-Coordinate by seperating incoming string (without anything else, just the numbers!)
      String cY = a.substring(iY + 1, a.length()); //get Y-Coordinate by seperating incoming string (without anything else, just the numbers!)

      Serial.println(a); //prints string to serial port  (for debugging)
      //Serial.println(cX); //prints string to serial port  (for debugging)
      //Serial.println(cY); //prints string to serial port  (for debugging)

      plotter(cX, cY); //send commands to plotter function, executing the command

      readString=""; //clears variable for new input
     }
    else {
      readString += c; //makes the string readString
    }
  }
}

void plotter(String cmdX, String cmdY) {
     Serial.println(cmdX); //prints string to serial port  (for debugging)
     Serial.println(cmdY); //prints string to serial port  (for debugging)

     float newX = cmdX.toFloat();
     float newY = cmdY.toFloat();

     Serial.println(newX); //prints string to serial port  (for debugging)
     Serial.println(newY); //prints string to serial port  (for debugging)

     float angleAlpha;
     float angleBeta;
     float angleGamma;

     float idealline;

     float axis = 200.00; //length of axis in mm

     idealline = sqrt(sq(newX) + sq(newY));

     //calculate position
     angleAlpha = acos((sq(axis) - sq(axis) - sq(idealline)) / (-2 * axis * idealline));
     angleBeta = acos((sq(axis) - sq(axis) - sq(idealline)) / (-2 * axis * idealline));
     angleGamma = 180 - angleAlpha - angleBeta;

     //move pen up or down
     if (readString == 'M03 S0') {
      servo3.write(100); //move pen up
     } else if (readString == 'M03 S20') {
      servo3.write(-100);  //move pen down
     }

     Serial.println(idealline); //prints string to serial port  (for debugging)
     Serial.println(angleAlpha); //prints string to serial port  (for debugging)
     Serial.println(angleBeta); //prints string to serial port  (for debugging)
     Serial.println(angleGamma); //prints string to serial port  (for debugging)

     //move the servos to calculated position
     servo1.write(angleAlpha);
     servo2.write(angleGamma);

     delay(100); //wait for the servors to move;
     Serial.println('c'); //sending new command request

}
