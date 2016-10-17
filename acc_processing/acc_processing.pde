// Need G4P library
import g4p_controls.*;
import processing.serial.*;

Serial  myPort;
float   value;
int     angle = 0;
char    speed = 0;
int     speed2 = 0;
char    circularBuffer[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
final int buffLen = 20;
float   mobileAverageTab[] = {0.0, 0.0, 0.0, 0.0, 0.0};
final int tabLen = 5;
float   mobileAverage = 0.0;
int   indexAverageTab  = 0;
int     index = 0;
byte[]  inData = new byte[4];
float   targetValueX = 0.0;

public void setup(){
  size(480, 320, JAVA2D);
  createGUI();
  customGUI();
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  setTextTargetX();
  
}

public void draw(){
  background(230);
  
  writeOutputAngle();
  readAllInput();
  getCircularBufferValues();
/*
  addValueToMobileAverageTab();
  calculMobileAverage();
  */
  mobileAverage = value;
  printBuffer();
  
  setTextX();
  setTextSpeed();
  delay(100);
}

public void readAllInput() {
 while (0 < myPort.available()) {
   index = ((index + 1) % buffLen);
   circularBuffer[index] = myPort.readChar();
 }
}

void calculMobileAverage() {
  int i = 0;
  float tmp = 0.0;
  while (i < tabLen) {
    tmp += mobileAverageTab[i];
    i++;
  }
  mobileAverage = tmp / (float)tabLen;
}

void addValueToMobileAverageTab(){
  if (value != 0.0) {
    mobileAverageTab[indexAverageTab] = value;
    indexAverageTab = (indexAverageTab + 1) % tabLen;
  }
}

public void getCircularBufferValues() {
 int goback = 0;
 int i = index;
 while (goback < 6) {
 if (i != 0)
   i = i - 1;
 else
   i = buffLen - 1;
 goback++;
 }

 int tmpindex = i;
 int j = 0;
 int count = 0;
 while (count < buffLen - 6 && !(circularBuffer[i] == 'f' && circularBuffer[(i + 1) % buffLen] == '|' && circularBuffer[(i + 2) % buffLen] == '|')) {
   if (i != 0)
     i = i - 1;
   else
     i = buffLen - 1;
   count++;
 }
 if (count < buffLen - 6) {
   i = (i + 3) % buffLen;
   while (j < 4) {
     inData[j] = (byte)circularBuffer[i];
     j++;
     i = (i + 1) % buffLen;
   }

   int intbit = 0;
   intbit = (inData[3] << 24) | ((inData[2] & 0xff) << 16) | ((inData[1] & 0xff) << 8) | (inData[0] & 0xff);
   float f = Float.intBitsToFloat(intbit);
   value = f;  
 }

 i = tmpindex;
 j = 0;
 count = 0;
 while (count < buffLen - 6 &&  !(circularBuffer[i] == 's' && circularBuffer[(i + 1) % buffLen] == '|' && circularBuffer[(i + 2) % buffLen] == '|')) {
   if (i != 0)
     i = i - 1;
   else
     i = buffLen - 1;
   count++;
 }
 if (count < buffLen - 6) {
   i = (i + 3) % buffLen;
   while (j < 4) {
     inData[j] = (byte)circularBuffer[i];
     j++;
     i = (i + 1) % buffLen;
   }
   int intbit = 0;
   intbit = (inData[3] << 24) | ((inData[2] & 0xff) << 16) | ((inData[1] & 0xff) << 8) | (inData[0] & 0xff);
   speed2 = intbit;  
 }
}

public void printInData(){
  int i = 0;
  println("Debut Data");
  while(i < 4) {
    println((char)inData[i] + "-");
    i++;
  }
  println("Fin data");
  
}

public void printBuffer() {
 int i = 0;
 while (i < buffLen) {
  println(circularBuffer[i] + "-");
  i++;
 }
 println("EndOfBuffer");
}
static int cpt = 0;
public void setTextSpeed(){
      int tmpspeed = speed2 * 100 / 254;
      if (speed2 > 254) {
          tmpspeed = 100;
          cpt++;
        }
      if (cpt > 15){
        editTextError.setText("NOT ENOUGH POWER !");
        cpt = 0;
    }
     speedValue.setText(str(tmpspeed));
     slider1.setValue((float)tmpspeed / 100);
}

public void setTextX() {
//     xValue.setText(str(value));
       xValue.setText(String.format("%.2f", mobileAverage));
}

public void setTextTargetX() {
    valueTargetX.setText(str(targetValueX));  
}

public void writeOutputAngle(){
    myPort.write('a');
    myPort.write('|');
    myPort.write('|');
    myPort.write(angle);
}

public void readInputX() {
 if (0 < myPort.available()) {
    char inByte = myPort.readChar();
    if(inByte == 'f') {
      // we expect data with this format fXXXX
      byte [] inData = new byte[6];
      myPort.readBytes(inData);
      
      int intbit = 0;
      intbit = (inData[3] << 24) | ((inData[2] & 0xff) << 16) | ((inData[1] & 0xff) << 8) | (inData[0] & 0xff);
      
      float f = Float.intBitsToFloat(intbit);
      value = f;
     }
   }
}

public void readInputSpeed() {
 if (0 < myPort.available()) {
    char inByte = myPort.readChar();
    if(inByte == 's') {
      // we expect data with this format fXXXX
      byte [] inData = new byte[6];
      myPort.readBytes(inData);
      
      speed2 = (inData[3] << 24) | ((inData[2] & 0xff) << 16) | ((inData[1] & 0xff) << 8) | (inData[0] & 0xff);
     // println(f);
    }
 }
}

// Use this method to add additional statements
// to customise the GUI controls
public void customGUI(){

}