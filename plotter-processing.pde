/*
  Processing code converting svg file to gcode; parsing generated gcode-File to Arduino (or similar) based Plotter
*/

import processing.serial.*;  //for serial communication
import geomerative.*;        //for g code generation

RShape grp;
RPoint[][] pointPaths;

boolean connection = false;
int read;
int c = 0;

String fileName = "gcodeFile"; // Name of the file you want to convert, as to be in the same directory
String penUp= "M03 S0 \n"; // Command to control the pen, it change beetween differents firmware
String penDown = "M03 S20 \n";
float[] xcoord = { -108, -195};// These variables define the minimum and maximum position of each axis for your output GCode
float[] ycoord = { -108, -195};// These settings also change between your configuration


String gcodecommand ="G0 F16000 \n G0"+ penUp; // String to store the Gcode we wil save later

float xmag, ymag, newYmag, newXmag = 0;
float z = 0;

boolean ignoringStyles = false;
int filesaved = 0;

boolean gcodeReady = false;

Serial port;

public void settings() {
  size(600, 600, "processing.opengl.PGraphics3D");
}

void setup() {
  //list all available serial ports
  //println(Serial.list());

  //open serial port that serial device is connected to
  port = new Serial(this, "/dev/tty.usbmodem144201", 9600);
  convertToGcode();
}

void draw() {
  if(port.available() > 0) {
    read = port.read();
    //println(read);
    if (read == 'r') {
      println("recieved r!");
      answer('r'); //answer to signal from serial device; then waiting for command request 'c'
    }
    if (read == 'c') {
      println("requesting command");
      sendCommand(c);
      c ++;
    }
  }

}

void answer(char value) {
 port.write(value);
}

void sendCommand(int d) {
  String[] lines = loadStrings("gcodeFile.txt");
  //println("there are " + lines.length + " lines");
  //for (int i = 0 ; i < lines.length; i++) {
    //println(c);
    //println(lines[c]);
    port.write(lines[d]);
    println(lines[d]);
  //}
}

void convertToGcode() {
  size(600, 600, P3D);
  // VERY IMPORTANT: Allways initialize the library before using it
  RG.init(this);
  RG.ignoreStyles(ignoringStyles);

  RG.setPolygonizer(RG.ADAPTATIVE);

  grp = RG.loadShape(fileName +".svg");
  grp.centerIn(g, 100, 1, 1);

  pointPaths = grp.getPointsInPaths();

  translate(width/2, height/2);

  newXmag = mouseX/float(width) * TWO_PI;
  newYmag = mouseY/float(height) * TWO_PI;

  float diff = xmag-newXmag;
  if (abs(diff) >  0.01) {
    xmag -= diff/4.0;
  }

  diff = ymag-newYmag;
  if (abs(diff) >  0.01) {
    ymag -= diff/4.0;
  }

  rotateX(-ymag);
  rotateY(-xmag);

  background(0);
  stroke(255);
  noFill();

  if ( filesaved == 0) {
    for (int i = 0; i<pointPaths.length; i++) {
      if (pointPaths[i] != null) {
        beginShape();
        for (int j = 0; j<pointPaths[i].length; j++) {
          vertex(pointPaths[i][j].x, pointPaths[i][j].y);

          float xmaped = map(pointPaths[i][j].x, -200, 200, xcoord[1], xcoord[0]);
          float ymaped = map(pointPaths[i][j].y, -200, 200, ycoord[0], ycoord[1]);
          if (j == 1) {
            gcodecommand = gcodecommand + penDown;
          }
          gcodecommand = gcodecommand + "G1 X"+ str(xmaped)+" Y"+str(ymaped) +"\n";
        }
        endShape();
      }
      gcodecommand = gcodecommand + penUp;

      if (i == pointPaths.length-1) {
        String[] gcodecommandlist = split(gcodecommand, '\n');
        saveStrings(fileName+".txt", gcodecommandlist);
        filesaved = 1;
        println("file saved");
        gcodeReady = true;
      }
    }
  }
}

void mousePressed() {
  ignoringStyles = !ignoringStyles;
  RG.ignoreStyles(ignoringStyles);
}
