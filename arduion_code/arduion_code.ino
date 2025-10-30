#include <WiFi.h>
#include <WebServer.h>
#include <ESP32Servo.h>

// ------------------ Servo Setup ------------------
Servo baseServo;
Servo verticalServo;
Servo gripperServo1;
Servo gripperServo2;

const int VERTICAL_CENTER = 90;
const int VERTICAL_DOWN = 0;
const int VERTICAL_UP = 90;

const int GRIPPER_OPEN = 0;
const int GRIPPER_CLOSE = 90;

// -------------------- Motor Driver Pins --------------------
#define ENA 25
#define ENB 26
#define IN1 27
#define IN2 14
#define IN3 12
#define IN4 13

// PWM channels & settings
const int ENA_CHANNEL = 0;
const int ENB_CHANNEL = 1;
const int PWM_FREQ = 1000;
const int PWM_RESOLUTION = 8; // 0-255

// -------------------- IR Sensor Pins --------------------
#define IR1 4
#define IR2 16
#define IR3 17
#define IR4 18
#define IR5 19

// -------------------- Ultrasonic Sensor Pins --------------------
#define TRIG 33
#define ECHO 32

// -------------------- Wi-Fi Credentials --------------------
const char* ssid = "Hotspot";
const char* password = "12345678";

// -------------------- Global Variables --------------------
WebServer server(80);
bool missionActive = false;
int pickStation = 0;  // Station to pick from (1-3)
int dropStation = 0;  // Station to drop at (1-3)
int stationCount = 0; // Count stations encountered
bool pickComplete = false;
bool dropComplete = false;
unsigned long operationStartTime = 0;

// -------------------- Prototypes --------------------
int getDistance();
void moveForward(int speed);
void moveBackward(int speed);
void turnLeft(int speed);
void turnRight(int speed);
void stopMotors();
bool isAtStation();
void handleStationLogic();

// Servo functions
void moveServoSmoothly(Servo &servo, int targetAngle, int delayTime = 15);
void openGripper();
void closeGripper();
void pickSequence();
void dropSequence();

void setup() {
  Serial.begin(115200);

  // ------------------ Servo Initialization ------------------
  baseServo.attach(2);
  verticalServo.attach(15);
  gripperServo1.attach(22);
  gripperServo2.attach(23);

  // Set servos to starting position
  verticalServo.write(VERTICAL_CENTER);
  openGripper();
  delay(500);

  // Motor pins
  pinMode(ENA, OUTPUT);
  pinMode(ENB, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  // Setup PWM (LEDC)
  ledcAttach(ENA, PWM_FREQ, PWM_RESOLUTION);
  ledcAttach(ENB, PWM_FREQ, PWM_RESOLUTION);

  // IR sensor pins
  pinMode(IR1, INPUT);
  pinMode(IR2, INPUT);
  pinMode(IR3, INPUT);
  pinMode(IR4, INPUT);
  pinMode(IR5, INPUT);

  // Ultrasonic sensor pins
  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT);

  Serial.println("Motor, IR sensors, Ultrasonic, and Servos initialized!");

  // -------------------- Connect to Wi-Fi --------------------
  Serial.print("Connecting to Wi-Fi");
  WiFi.begin(ssid, password);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi Connected!");
    Serial.print("ESP32 IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\nWiFi Connection Failed! Please check SSID/Password.");
  }

  // -------------------- Web server routes --------------------
  server.on("/", []() {
    String html = "<!DOCTYPE html><html><head>";
    html += "<meta name='viewport' content='width=device-width, initial-scale=1'>";
    html += "<style>";
    html += "body { font-family: Arial; text-align: center; padding: 20px; }";
    html += "h1 { color: #333; }";
    html += ".status { background: #f0f0f0; padding: 15px; margin: 20px 0; border-radius: 8px; }";
    html += ".section { margin: 20px 0; padding: 15px; border: 2px solid #ddd; border-radius: 8px; }";
    html += "button { padding: 12px 24px; margin: 5px; font-size: 16px; cursor: pointer; border-radius: 5px; border: none; }";
    html += ".btn-station { background: #2196F3; color: white; }";
    html += ".btn-station.selected { background: #0d47a1; }";
    html += ".btn-start { background: #4CAF50; color: white; font-size: 20px; padding: 15px 40px; }";
    html += ".btn-stop { background: #f44336; color: white; font-size: 20px; padding: 15px 40px; }";
    html += "</style></head><body>";
    
    html += "<h1>🤖 Pick & Place Robot Control</h1>";
    
    // Status Display
    html += "<div class='status'>";
    html += "<h3>Current Status</h3>";
    html += "<p><strong>Mission:</strong> " + String(missionActive ? "ACTIVE" : "STOPPED") + "</p>";
    html += "<p><strong>Pick Station:</strong> " + String(pickStation == 0 ? "Not Set" : String(pickStation)) + "</p>";
    html += "<p><strong>Drop Station:</strong> " + String(dropStation == 0 ? "Not Set" : String(dropStation)) + "</p>";
    html += "<p><strong>Current Station Count:</strong> " + String(stationCount) + "</p>";
    html += "<p><strong>Pick Complete:</strong> " + String(pickComplete ? "YES" : "NO") + "</p>";
    html += "<p><strong>Drop Complete:</strong> " + String(dropComplete ? "YES" : "NO") + "</p>";
    html += "</div>";
    
    // Pick Station Selection
    html += "<div class='section'>";
    html += "<h3>📦 Select PICK Station</h3>";
    html += "<a href='/setpick/1'><button class='btn-station" + String(pickStation == 1 ? " selected" : "") + "'>Station 1</button></a>";
    html += "<a href='/setpick/2'><button class='btn-station" + String(pickStation == 2 ? " selected" : "") + "'>Station 2</button></a>";
    html += "<a href='/setpick/3'><button class='btn-station" + String(pickStation == 3 ? " selected" : "") + "'>Station 3</button></a>";
    html += "</div>";
    
    // Drop Station Selection
    html += "<div class='section'>";
    html += "<h3>📍 Select DROP Station</h3>";
    html += "<a href='/setdrop/1'><button class='btn-station" + String(dropStation == 1 ? " selected" : "") + "'>Station 1</button></a>";
    html += "<a href='/setdrop/2'><button class='btn-station" + String(dropStation == 2 ? " selected" : "") + "'>Station 2</button></a>";
    html += "<a href='/setdrop/3'><button class='btn-station" + String(dropStation == 3 ? " selected" : "") + "'>Station 3</button></a>";
    html += "</div>";
    
    // Start/Stop Control
    html += "<div class='section'>";
    html += "<h3>🎮 Mission Control</h3>";
    html += "<a href='/start'><button class='btn-start'>▶️ START MISSION</button></a><br><br>";
    html += "<a href='/stop'><button class='btn-stop'>⏹️ STOP</button></a>";
    html += "</div>";
    
    html += "</body></html>";
    server.send(200, "text/html", html);
  });

  // Set Pick Station
  server.on("/setpick/1", []() { pickStation = 1; server.sendHeader("Location", "/"); server.send(303); });
  server.on("/setpick/2", []() { pickStation = 2; server.sendHeader("Location", "/"); server.send(303); });
  server.on("/setpick/3", []() { pickStation = 3; server.sendHeader("Location", "/"); server.send(303); });

  // Set Drop Station
  server.on("/setdrop/1", []() { dropStation = 1; server.sendHeader("Location", "/"); server.send(303); });
  server.on("/setdrop/2", []() { dropStation = 2; server.sendHeader("Location", "/"); server.send(303); });
  server.on("/setdrop/3", []() { dropStation = 3; server.sendHeader("Location", "/"); server.send(303); });

  // Start Mission
  server.on("/start", []() {
    if (pickStation > 0 && dropStation > 0 && pickStation != dropStation) {
      missionActive = true;
      stationCount = 0;
      pickComplete = false;
      dropComplete = false;
      Serial.println("Mission Started! Pick from Station " + String(pickStation) + ", Drop at Station " + String(dropStation));
      server.sendHeader("Location", "/");
      server.send(303);
    } else {
      String html = "<h2>❌ ERROR</h2>";
      html += "<p>Please select different stations for Pick and Drop!</p>";
      html += "<a href='/'><button>Back</button></a>";
      server.send(200, "text/html", html);
    }
  });

  // Stop Mission
  server.on("/stop", []() {
    missionActive = false;
    stationCount = 0;
    pickComplete = false;
    dropComplete = false;
    stopMotors();
    Serial.println("Mission Stopped!");
    server.sendHeader("Location", "/");
    server.send(303);
  });

  // Status API
  server.on("/status", []() {
    String json = "{";
    json += "\"missionActive\": " + String(missionActive ? "true" : "false") + ",";
    json += "\"pickStation\": " + String(pickStation) + ",";
    json += "\"dropStation\": " + String(dropStation) + ",";
    json += "\"stationCount\": " + String(stationCount) + ",";
    json += "\"pickComplete\": " + String(pickComplete ? "true" : "false") + ",";
    json += "\"dropComplete\": " + String(dropComplete ? "true" : "false");
    json += "}";
    server.send(200, "application/json", json);
  });

  server.begin();
  Serial.println("Web Server Started!");
}

void loop() {
  server.handleClient();

  // Debug: Print IR sensor values
  int ir1 = digitalRead(IR1);
  int ir2 = digitalRead(IR2);
  int ir3 = digitalRead(IR3);
  int ir4 = digitalRead(IR4);
  int ir5 = digitalRead(IR5);
  
  // Ultrasonic check
  int distance = getDistance();
  
  // If obstacle is too close, stop motors
  if (distance > 0 && distance < 15 && missionActive) {
    Serial.println("Obstacle detected! Stopping...");
    stopMotors();
    delay(200);
    return;
  }

  // Run mission logic only if active
  if (missionActive) {
    handleStationLogic();
    
    // Check if mission is complete
    if (pickComplete && dropComplete) {
      Serial.println("✅ Mission Complete! Robot stopped at drop station.");
      missionActive = false;
      stopMotors();
      return;
    }

    // Regular line following
    if (ir3 == LOW) {
      moveForward(200);
    } 
    else if (ir1 == LOW || ir2 == LOW) {
      turnLeft(180);
    } 
    else if (ir4 == LOW || ir5 == LOW) {
      turnRight(180);
    } 
    else {
      moveForward(100); // Slow forward to find line
    }
  } else {
    stopMotors();
  }

  delay(100);
}

bool isAtStation() {
  // Station detected when all 5 IR sensors detect black (LOW)
  return (digitalRead(IR1) == LOW && 
          digitalRead(IR2) == LOW && 
          digitalRead(IR3) == LOW && 
          digitalRead(IR4) == LOW && 
          digitalRead(IR5) == LOW);
}

void handleStationLogic() {
  static bool lastStationState = false;
  bool currentStationState = isAtStation();
  
  // Detect when entering a station (edge detection)
  if (currentStationState && !lastStationState) {
    stationCount++;
    Serial.println("📍 Station " + String(stationCount) + " detected");
    
    // Stop at station
    stopMotors();
    delay(500);
    
    // Check if this is pick station
    if (stationCount == pickStation && !pickComplete) {
      Serial.println("📦 Performing PICK operation...");
      pickSequence();
      pickComplete = true;
      Serial.println("✅ Pick Complete!");
      delay(1000); // Brief pause before continuing
    }
    // Check if this is drop station
    else if (stationCount == dropStation && pickComplete && !dropComplete) {
      Serial.println("📍 Performing DROP operation...");
      dropSequence();
      dropComplete = true;
      Serial.println("✅ Drop Complete!");
    }
    // Continue to next station
    else {
      Serial.println("⏭️ Not target station, continuing...");
      delay(500);
    }
  }
  
  lastStationState = currentStationState;
}

// Ultrasonic reading (cm)
int getDistance() {
  digitalWrite(TRIG, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG, LOW);

  long duration = pulseIn(ECHO, HIGH, 30000);
  if (duration == 0) return 0;
  int distance = duration * 0.034 / 2;
  return distance;
}

// Motor control using ledcWrite
void moveForward(int speed) {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
  ledcWrite(ENA, speed);
  ledcWrite(ENB, speed);
}

void moveBackward(int speed) {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
  ledcWrite(ENA, speed);
  ledcWrite(ENB, speed);
}

void turnLeft(int speed) {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
  ledcWrite(ENA, speed);
  ledcWrite(ENB, speed);
}

void turnRight(int speed) {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
  ledcWrite(ENA, speed);
  ledcWrite(ENB, speed);
}

void stopMotors() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
  ledcWrite(ENA, 0);
  ledcWrite(ENB, 0);
}

// ------------------ Servo Functions ------------------
void moveServoSmoothly(Servo &servo, int targetAngle, int delayTime) {
  int currentAngle = servo.read();
  if (currentAngle < targetAngle) {
    for (int angle = currentAngle; angle <= targetAngle; angle++) {
      servo.write(angle);
      delay(delayTime);
    }
  } else {
    for (int angle = currentAngle; angle >= targetAngle; angle--) {
      servo.write(angle);
      delay(delayTime);
    }
  }
}

void openGripper() {
  gripperServo1.write(GRIPPER_OPEN);
  gripperServo2.write(180);
}

void closeGripper() {
  gripperServo1.write(GRIPPER_CLOSE);
  gripperServo2.write(90);
}

// ------------------ Pick & Drop Sequence ------------------
void pickSequence() {
  // Forward
  baseServo.writeMicroseconds(1300);
  delay(1000);
  baseServo.writeMicroseconds(1500);
  delay(500);

  // Down
  moveServoSmoothly(verticalServo, VERTICAL_DOWN, 10);
  delay(500);

  // Grip
  closeGripper();
  delay(500);

  // Up
  moveServoSmoothly(verticalServo, VERTICAL_UP, 10);
  delay(500);

  // Back
  baseServo.writeMicroseconds(1700);
  delay(1000);
  baseServo.writeMicroseconds(1500);
}

void dropSequence() {
  // Forward
  baseServo.writeMicroseconds(1300);
  delay(1000);
  baseServo.writeMicroseconds(1500);
  delay(500);

  // Down
  moveServoSmoothly(verticalServo, VERTICAL_DOWN, 10);
  delay(500);

  // Release
  openGripper();
  delay(500);

  // Up
  moveServoSmoothly(verticalServo, VERTICAL_UP, 10);
  delay(500);

  // Back
  baseServo.writeMicroseconds(1700);
  delay(1000);
  baseServo.writeMicroseconds(1500);
}