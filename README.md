VIKRANT – Autonomous Logistics Robot
VIKRANT is an indigenously developed smart logistics robot designed to automate parcel delivery and intralogistics. It combines intelligent navigation, a robotic arm, and app-based control to enable efficient, autonomous transportation in industrial and urban environments.

Overview
VIKRANT is a Smart Autonomous Mini AGV (Automated Guided Vehicle) built to optimize last-mile delivery and intra-facility logistics.
Using ESP32, IR sensors, and servo-based robotic arms, it navigates autonomously between stations to pick up and deliver packages with precision.
A mobile app allows users to assign pickup/drop points, monitor progress, and receive live updates.

System Architecture
Navigation: Line-following + Dijkstra’s algorithm for shortest path optimization
Manipulation: 4-servo robotic arm for autonomous pick, lift, move, and drop operations
Sensors: IR, Ultrasonic, Limit sensors
Control Unit: ESP32 microcontroller
Power: 12V Li-ion battery with power management system
App Interface: Flutter-based mobile app for real-time control and feedback

Features
Fully autonomous multi-station delivery
Real-time app monitoring and control
Route optimization for efficiency
Auto pickup and drop functionality
Modular, scalable, and low-cost design

Tech Stack
Hardware: ESP32 · IR Sensors · Ultrasonic Sensors · Servo Motors · Motor Drivers
Software: Arduino IDE · Flutter · Firebase
Algorithms: PID control · Dijkstra’s shortest path

