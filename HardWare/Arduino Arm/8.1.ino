//********************************************
//* Robotic Arm
//* for robotic arm 0
//* By Duan Yuxin
//* Auguest 5 2019
//********************************************
#include <Servo.h>
#include <CurieBLE.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <pthread.h>

#define ROBOT_NAME "GC_ROBOT"

#define ELBOW_MIN   0
#define ELBOW_MAX 140
#define ELBOW_DEFAULT 15

#define SHOULDER_MIN 0
#define SHOULDER_MAX 165
#define SHOULDER_DEFAULT 100

#define WRIST_X_MIN  0
#define WRIST_X_MAX 180
#define WRIST_X_DEFAULT 90

#define WRIST_Y_MIN 0
#define WRIST_Y_MAX 85
#define WRIST_Y_DEFAULT 0

#define WRIST_Z_MIN 0
#define WRIST_Z_MAX 180
#define WRIST_Z_DEFAULT 0

#define BASE_MIN 0
#define BASE_MAX 180
#define BASE_DEFAULT 105

#define CRAW_MIN 0 //open
#define CRAW_MAX 58 //close
#define CRAW_DEFAULT 0


/*
 * control the robotic arm
 */

Servo myservoA;
Servo myservoB;
Servo myservoC;
Servo myservoD;//the craw
Servo myservoE;
Servo myservoF;
Servo myservoG;

int i,pos,speed,interval;
int sea,seb,sec,sed,see,sef,seg;

void getCurrentPos()
{
    sea=myservoA.read();
    seb=myservoB.read();
    sec=myservoC.read();
    sed=myservoD.read();
    see=myservoE.read();
    sef=myservoF.read();
    seg=myservoG.read();
}

void setSpeed(int s = 250)
{
    speed = s;
}

void setInterval(int i = 3)
{
    interval = i;
}

void rotate(int a = ELBOW_DEFAULT, int b = SHOULDER_DEFAULT, int c = WRIST_X_DEFAULT,
            int d = CRAW_DEFAULT, int e = WRIST_Z_DEFAULT, int f = BASE_DEFAULT, int g = WRIST_Y_DEFAULT)
{
    getCurrentPos();
    for(pos = 0 ; pos <= speed ; pos += 1)
    {
        myservoA.write(int(map(pos,1,speed,sea,a)));
        myservoB.write(int(map(pos,1,speed,seb,b)));
        myservoC.write(int(map(pos,1,speed,sec,c)));
        myservoD.write(int(map(pos,1,speed,sed,d)));
        myservoE.write(int(map(pos,1,speed,see,e)));
        myservoF.write(int(map(pos,1,speed,sef,f)));
        myservoG.write(int(map(pos,1,speed,seg,g)));
        delay(interval);
    }

}

void rotateSingle(Servo *servo, int degree)
{
    int set = servo->read();
    for(pos = 0 ; pos <= speed ; pos += 1)
    {
        servo->write(int(map(pos,1,speed,set,degree)));
        delay(interval);
    }
}

void resetPos()
{
    delay(1000);
    sed = myservoD.read();
    rotate(15,100,90,sed,0,105,0);
}

void initiate()
{
    setSpeed();
    setInterval();
    rotate();
}

float disOffset = 0.83, angleOffset = 0.86;
int A=12,B=14;
// "P x y z t"
void catchAndDrop(char *data)
{
    char *operation[4];
    char buf[50];
    char *token = strtok(data," ");
    int i = 0;
    while (token != NULL) {
        operation[i++] = token;
        token = strtok(NULL," ");
    }

    float x = atof(operation[0]), y = atof(operation[1]), z = atof(operation[2]);
    int t = atoi(operation[3]);
    sprintf(buf,"%f,%f,%f,%d",x,y,z,t);
    Serial.println(buf);

    if (x<=3)
      angleOffset = 0.9;
    else
      angleOffset = 0.86;
    float preDefinedHeight = 7.0;
    if (z < preDefinedHeight) z = preDefinedHeight;
    
    //  get to the position with height 5cm.
    {
        float a1 = 105.0f;
        if (x > 0.0f)
            a1 = 180.0f - atan((y + 8.8f) / x) * 180.0 / PI;
        else
            a1 = -atan((y + 8.8f) / x) * 180.0 / PI;

        float dis = x / cos((180.0f - a1) * PI / 180.0f) * disOffset;
        dis = sqrt(dis * dis + z * z);

        int a2 = static_cast<int>(acos((A * A + dis * dis - B * B) / (2.0 * A * dis)) * 180.0 / PI);
        int a3 = static_cast<int>(acos((-A * A + dis * dis + B * B) / (2.0 * dis * B)) * 180.0 / PI);
        int a4 = static_cast<int>(asin(z / dis) * 180.0 / PI);

        a2 += a4;
        a3 -= a4;

        rotateSingle(&myservoF, 105 - a1 * angleOffset);
        rotateSingle(&myservoG, a3 / 3.3);
        getCurrentPos();
        rotate(15 + a3, a2 - 10, sec, 0, see, sef, a3 / 4);
    }

    // get the real height
    z = atof(operation[2]);
    
    if (z <= 0.1f) {
        float a1 = 105.0f;
        if (x > 0.0f)
            a1 = 180.0f - atan((y + 8.8f) / x) * 180.0 / PI;
        else
            a1 = -atan((y + 8.8f) / x) * 180.0 / PI;

        float dis = x / cos((180.0f - a1) * PI / 180.0f) * disOffset;

        int a2 = static_cast<int>(acos((A * A + dis * dis - B * B) / (2.0 * A * dis)) * 180.0 / PI);
        int a3 = static_cast<int>(acos((-A * A + dis * dis + B * B) / (2.0 * dis * B)) * 180.0 / PI);

        getCurrentPos();
        rotate(15 + a3, a2 - 10, sec, 0, see, sef, a3 / 4);
    } else if(z < preDefinedHeight){
        float a1 = 105.0f;
        if (x > 0.0f)
            a1 = 180.0f - atan((y + 8.8f) / x) * 180.0 / PI;
        else
            a1 = -atan((y + 8.8f) / x) * 180.0 / PI;

        float dis = x / cos((180.0f - a1) * PI / 180.0f) * disOffset;
        dis = sqrt(dis * dis + z*z);

        int a2 = static_cast<int>(acos((A * A + dis * dis - B * B) / (2.0 * A * dis)) * 180.0 / PI);
        int a3 = static_cast<int>(acos((-A * A + dis * dis + B * B) / (2.0 * dis * B)) * 180.0 / PI);
        int a4 = static_cast<int>(asin(z/dis) * 180.0 / PI);

        a2 += a4;
        a3 -= a4;

        getCurrentPos();
        rotate(15 + a3, a2 - 10, sec, 0, see, sef, a3 / 4);
    }

    // picking up
    rotateSingle(&myservoD, 50);
    delay(500);
    getCurrentPos();
    for(pos = 0 ; pos <= speed ; pos += 1)
    {
        myservoA.write(int(map(pos,1,speed,sea,ELBOW_DEFAULT)));
        myservoG.write(int(map(pos,1,speed,seg,WRIST_Y_DEFAULT)));
        delay(interval);
    }

    // returning
   

    switch(t){
      case 1:
          resetPos();
          delay(500);
          rotateSingle(&myservoB,10);
          rotateSingle(&myservoD,0);
          break;
      case 2:
          sed = myservoD.read();
          rotate(15,10,90,sed,0,135,0);
          delay(1000);
          rotateSingle(&myservoD,0);
          break;
      case 3:
          rotate();
          rotateSingle(&myservoD,0);
          break;
      default :
          rotateSingle(&myservoD,0);
          break;
    }

    delay(1000);
    resetPos();
}

void excution(char data[20])
{

    if(strcmp(data,"RE")==0)
    {
        resetPos();
        return;
    }

    char* instruction[3];
    char* token = strtok(data, " ");
    int i = 0;
    while (token != NULL){
        instruction[i++] = token;
        token = strtok(NULL, " ");
    }

    int degree = 0;
    int this_max = 0;
    Servo *pointer = NULL;
    char buf[50];
    switch((int)*instruction[1]){
        case 65:
            pointer = &myservoA;
            this_max = ELBOW_MAX;
            break;
        case 66:
            pointer = &myservoB;
            this_max = SHOULDER_MAX;
            break;
        case 67:
            pointer = &myservoC;
            this_max = WRIST_X_MAX;
            break;
        case 68:
            pointer = &myservoD;
            this_max = CRAW_MAX;
            break;
        case 69:
            pointer = &myservoE;
            this_max = WRIST_Z_MAX;
            break;
        case 70:
            pointer = &myservoF;
            this_max = BASE_MAX;
            break;
        case 71:
            pointer = &myservoG;
            this_max = WRIST_Y_MAX;
            break;
        default:
        sprintf(buf, "%s", "Command ERROR!");
        Serial.println("Error");
            break;
    }

    if (strcmp(instruction[0], "SHOW") == 0){
        if (strcmp(instruction[1], "DEGREE") == 0){
            sprintf(buf, "%c %d %c %d %c %d %c %d %c %d %c %d %c %d %c", 'A', myservoA.read(),'B', myservoB.read(),'C', myservoC.read(),
                    'D', myservoD.read(),'E', myservoE.read(),'F', myservoF.read(),'G', myservoG.read(), '\0');
            Serial.println(buf);
        }

        return;
    }
    else if (strcmp(instruction[0], "SET") == 0){
        degree = atoi(instruction[2]);
    }
    else if (strcmp(instruction[0], "ADD") == 0){
        degree = atoi(instruction[2]) + pointer->read();
    }
    else if (strcmp(instruction[0], "MINUS") == 0){
        degree = pointer->read() - atoi(instruction[2]);
    }
    else{
        return;
    }

    if (degree < 0){
        degree = 0;
        sprintf(buf, "%c %s %c", '\t', "Error, degree should not below 0;", '\0');
        Serial.println(buf);
        return;
    }

    if (degree > this_max){
        degree = this_max;
        sprintf(buf, "%c %s %d %c", '\t', "Error, degree should not over ", this_max, '\0');
        Serial.println(buf);
        return;
    }
    sprintf(buf, "%c %s %s %c %s %d %c %s %d", '\t', "Operation on: ", instruction[1], '\t',
            "Original: ", pointer->read(), '\t', "Current: ", degree);
    Serial.println(buf);
    rotateSingle(pointer,degree);
}

/*
 * BLE Programming
 * UUID generated  from a host ID, sequence number, and the current time. 
 * 
 * 2ebba7df-b772-11e9-a297-0235d2b38928 F
 * 2ebba7de-b772-11e9-a297-0235d2b38928 E
 * 2ebba7dd-b772-11e9-a297-0235d2b38928 D
 * 2ebba7dc-b772-11e9-a297-0235d2b38928 C
 * 2ebba7db-b772-11e9-a297-0235d2b38928 B
 * 2ebba7da-b772-11e9-a297-0235d2b38928 A
 * 2ebba7d9-b772-11e9-a297-0235d2b38928 Reset
 * 2ebba7d8-b772-11e9-a297-0235d2b38928 G
 * 2ebba7d7-b772-11e9-a297-0235d2b38928
 * 2ebba7d6-b772-11e9-a297-0235d2b38928 Arm service
 */
BLEPeripheral blePeripheral;
BLEService GCService("2ebba7d6-b772-11e9-a297-0235d2b38928"); // BLE robotic arm service

// Servo degree characteristics
BLEUnsignedCharCharacteristic bleServoA("2ebba7da-b772-11e9-a297-0235d2b38928", BLERead | BLEWrite | BLENotify);
BLEUnsignedCharCharacteristic bleServoB("2ebba7db-b772-11e9-a297-0235d2b38928", BLERead | BLEWrite);
BLEUnsignedCharCharacteristic bleServoC("2ebba7dc-b772-11e9-a297-0235d2b38928", BLERead | BLEWrite);
BLEUnsignedCharCharacteristic bleServoD("2ebba7dd-b772-11e9-a297-0235d2b38928", BLERead | BLEWrite);
BLEUnsignedCharCharacteristic bleServoE("2ebba7de-b772-11e9-a297-0235d2b38928", BLERead | BLEWrite);
BLEUnsignedCharCharacteristic bleServoF("2ebba7df-b772-11e9-a297-0235d2b38928", BLERead | BLEWrite);
BLEUnsignedCharCharacteristic bleServoG("2ebba7d8-b772-11e9-a297-0235d2b38928", BLERead | BLEWrite);
BLEUnsignedCharCharacteristic bleReset("2ebba7d9-b772-11e9-a297-0235d2b38928", BLERead | BLEWrite);

void blePeripheralConnectHandler(BLECentral &central)
{
  Serial.print("Connected event, central: ");
  Serial.println(central.address());
}

void blePeripheralDisconnectHandler(BLECentral &central)
{
  Serial.print("Disconnected event, central: ");
  Serial.println(central.address());
  resetPos();
}

void ServoACharacteristicWritten(BLECentral &central, BLECharacteristic &characteristic)
{
  Serial.print("ServoA Control: ");
  myservoA.write((byte)bleServoA.value());
  Serial.println((byte)bleServoA.value(), DEC);
}

void ServoBCharacteristicWritten(BLECentral &central, BLECharacteristic &characteristic)
{
  Serial.print("ServoB Control: ");
  myservoB.write((byte)bleServoB.value());
  Serial.println((byte)bleServoB.value(), DEC);
}
void ServoCCharacteristicWritten(BLECentral &central, BLECharacteristic &characteristic)
{
  Serial.print("ServoC Control: ");
  myservoC.write((byte)bleServoC.value());
  Serial.println((byte)bleServoC.value(), DEC);
}
void ServoDCharacteristicWritten(BLECentral &central, BLECharacteristic &characteristic)
{
  Serial.print("ServoD Control: ");
  myservoD.write((byte)bleServoD.value());
  Serial.println((byte)bleServoD.value(), DEC);
}

void ServoECharacteristicWritten(BLECentral &central, BLECharacteristic &characteristic)
{
  Serial.print("ServoE Control: ");
  myservoE.write((byte)bleServoE.value());
  Serial.println((byte)bleServoE.value(), DEC);
}

void ServoFCharacteristicWritten(BLECentral &central, BLECharacteristic &characteristic)
{
  Serial.print("ServoF Control: ");
  myservoF.write((byte)bleServoF.value());
  Serial.println((byte)bleServoF.value(), DEC);
}

void ServoGCharacteristicWritten(BLECentral &central, BLECharacteristic &characteristic)
{
  Serial.print("ServoG Control: ");
  myservoG.write((byte)bleServoG.value());
  Serial.println((byte)bleServoG.value(), DEC);
}

void ResetCharacteristicWritten(BLECentral &central, BLECharacteristic &characteristic)
{
  Serial.println("Reset");
  resetPos();
}

/*
 * setup & loop
 */
int incomingByte = 0;
char instruction[20];
int start = 0;
char buffer[50];

void setup()
{
    Serial.begin(9600);
    //pinMode(13, OUTPUT);   LED control

    myservoA.attach(2);
    myservoB.attach(3);
    myservoC.attach(4);
    myservoD.attach(5); //the craw
    myservoE.attach(6);
    myservoF.attach(7);
    myservoG.attach(8);

    initiate(); // initiate the default degree for each servo

    blePeripheral.setLocalName(ROBOT_NAME);
    blePeripheral.setAdvertisedServiceUuid(GCService.uuid());

    // Add service and characteristic
    blePeripheral.addAttribute(GCService);
    blePeripheral.addAttribute(bleServoA);
    blePeripheral.addAttribute(bleServoB);
    blePeripheral.addAttribute(bleServoC);
    blePeripheral.addAttribute(bleServoD);
    blePeripheral.addAttribute(bleServoE);
    blePeripheral.addAttribute(bleServoF);
    blePeripheral.addAttribute(bleServoG);
    blePeripheral.addAttribute(bleReset);
    // Assign event handlers for connected, disconnected to peripheral
    blePeripheral.setEventHandler(BLEConnected, blePeripheralConnectHandler);
    blePeripheral.setEventHandler(BLEDisconnected, blePeripheralDisconnectHandler);

    // Assign event handlers for characteristic
    bleServoA.setEventHandler(BLEWritten, ServoACharacteristicWritten);
    bleServoB.setEventHandler(BLEWritten, ServoBCharacteristicWritten);
    bleServoC.setEventHandler(BLEWritten, ServoCCharacteristicWritten);
    bleServoD.setEventHandler(BLEWritten, ServoDCharacteristicWritten);
    bleServoE.setEventHandler(BLEWritten, ServoECharacteristicWritten);
    bleServoF.setEventHandler(BLEWritten, ServoFCharacteristicWritten);
    bleServoG.setEventHandler(BLEWritten, ServoGCharacteristicWritten);
    bleReset.setEventHandler(BLEWritten, ResetCharacteristicWritten);

    // Set an initial value for the characteristic

    bleServoA.setValue(ELBOW_DEFAULT);
    bleServoB.setValue(SHOULDER_DEFAULT);
    bleServoC.setValue(WRIST_X_DEFAULT);
    bleServoD.setValue(CRAW_DEFAULT);
    bleServoE.setValue(WRIST_Z_DEFAULT);
    bleServoF.setValue(BASE_DEFAULT);
    bleServoG.setValue(WRIST_Y_DEFAULT);

    blePeripheral.begin();
    blePeripheral.poll();
    
    // advertise the service
    Serial.println(("Bluetooth device active, waiting for connections..."));
    Serial.print("Initialized");
}

void loop() {
    // Try to get the data from serial port
    if (Serial.available() > 0) {
        //Serial.println("1");
        int index = 0;
        delay(100);
        int numChar = Serial.available();
        char c;
        //Serial.println("2");
        memset(buffer, '\0', sizeof(buffer));
        Serial.println("3");
        while (numChar--) {
            c = Serial.read();
            if (c != char(10)){
                buffer[index++] = c;
            }
        }

        Serial.println(buffer);
        if((buffer[0] <= '9' && buffer[0] >= '0' )|| buffer[0] == '-')
        {
            catchAndDrop(buffer);
        }else {
            excution(buffer);
        }
        Serial.flush();
        Serial.println("finish");
    }
}
