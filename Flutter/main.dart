import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ------------------- APP COLORS -------------------
const Color lightYellow = Color(0xFFFFF9C4);
const Color lightOrange = Color(0xFFFFE082);
const Color warmBeige = Color(0xFFFFF3E0);
const Color warmPeach = Color(0xFFFFE0B2);
const Color warmCream = Color(0xFFFFF8E1);

// ------------------- MAIN -------------------
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VIKRANT',
      theme: ThemeData(
        primaryColor: lightOrange,
        scaffoldBackgroundColor: lightYellow,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginPage(),
        '/main': (context) => const RobotControlPage(),
      },
    );
  }
}

// ------------------- SPLASH SCREEN -------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _scaleController.forward();
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [lightYellow, lightOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ------------------- LOGIN PAGE -------------------
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  String correctUser = "123";
  String correctPass = "123";

  void login() {
    if (userController.text == correctUser && passController.text == correctPass) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Username or Password")),
      );
    }
  }

  void googleLogin() {
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [lightYellow, lightOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("assets/logo.png"),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 40),

                // User TextField
                TextField(
                  controller: userController,
                  decoration: InputDecoration(
                    hintText: "Email id / Phone no.",
                    prefixIcon: const Icon(Icons.person, color: Colors.black87),
                    hintStyle: const TextStyle(color: Colors.black87),
                    filled: true,
                    fillColor: Colors.orange[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 15),

                // Password TextField
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock, color: Colors.black87),
                    hintStyle: const TextStyle(color: Colors.black87),
                    filled: true,
                    fillColor: Colors.orange[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1, color: Colors.black54)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR", style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(child: Divider(thickness: 1, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 20),

                // Google button
                OutlinedButton.icon(
                  onPressed: googleLogin,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black54),
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.orange[100],
                  ),
                  icon: Image.network(
                    'https://img.icons8.com/color/48/google-logo.png',
                    height: 24,
                    width: 24,
                  ),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================= OPERATION HISTORY MODEL =========================
class OperationHistory {
  final String id;
  final String taskType;
  final int pickStation;
  final int dropStation;
  final String date;
  final String time;
  final int batteryLevel;
  final int duration; // in seconds
  final String status;

  OperationHistory({
    required this.id,
    required this.taskType,
    required this.pickStation,
    required this.dropStation,
    required this.date,
    required this.time,
    required this.batteryLevel,
    required this.duration,
    required this.status,
  });
}

// ========================= ROBOT CONTROL PAGE =========================
class RobotControlPage extends StatefulWidget {
  const RobotControlPage({Key? key}) : super(key: key);

  @override
  State<RobotControlPage> createState() => _RobotControlPageState();
}

class _RobotControlPageState extends State<RobotControlPage> with TickerProviderStateMixin {
  // ESP32 IP Address - CHANGE THIS TO YOUR ESP32 IP
  String esp32IP = "10.251.19.79"; // Change to your ESP32 IP address

  String currentPage = 'home';
  String robotStatus = 'ready';
  double batteryLevel = 85.0;
  bool isRunning = false;
  String? currentTask;
  List<OperationHistory> operationHistory = [];
  int totalDistance = 1247;
  int uptime = 0;
  Timer? batteryTimer;
  Timer? uptimeTimer;
  Timer? clockTimer;
  Timer? statusTimer;
  String currentTime = '';

  // Robot mission state from ESP32
  bool missionActive = false;
  int pickStation = 0;
  int dropStation = 0;
  int currentStationCount = 0;
  bool pickComplete = false;
  bool dropComplete = false;

  // Mission tracking
  DateTime? missionStartTime;
  int missionStartBattery = 0;

  // Ultrasonic sensor data
  bool obstacleDetected = false;
  int obstacleDistance = 0;

  // Animation controller for battery circle
  late AnimationController _batteryAnimationController;
  late Animation<double> _batteryAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize battery animation controller
    _batteryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _batteryAnimation = Tween<double>(begin: 0.0, end: batteryLevel / 100).animate(
      CurvedAnimation(parent: _batteryAnimationController, curve: Curves.easeOutCubic),
    );

    // Start the animation
    _batteryAnimationController.forward();

    updateTime();
    clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => updateTime());
    // Fetch status from ESP32 every 2 seconds
    statusTimer = Timer.periodic(const Duration(seconds: 2), (_) => fetchRobotStatus());
  }

  @override
  void dispose() {
    batteryTimer?.cancel();
    uptimeTimer?.cancel();
    clockTimer?.cancel();
    statusTimer?.cancel();
    _batteryAnimationController.dispose();
    super.dispose();
  }

  void updateTime() {
    setState(() {
      currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    });
  }

  // Update battery animation when battery level changes
  void updateBatteryAnimation() {
    _batteryAnimation = Tween<double>(
      begin: _batteryAnimation.value,
      end: batteryLevel / 100,
    ).animate(
      CurvedAnimation(parent: _batteryAnimationController, curve: Curves.easeOutCubic),
    );
    _batteryAnimationController.reset();
    _batteryAnimationController.forward();
  }

  // ==================== ESP32 API CALLS ====================
  Future<void> fetchRobotStatus() async {
    try {
      final response = await http.get(Uri.parse('http://$esp32IP/status')).timeout(
        const Duration(seconds: 3),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          missionActive = data['missionActive'] ?? false;
          pickStation = data['pickStation'] ?? 0;
          dropStation = data['dropStation'] ?? 0;
          currentStationCount = data['stationCount'] ?? 0;
          pickComplete = data['pickComplete'] ?? false;
          dropComplete = data['dropComplete'] ?? false;

          // Ultrasonic sensor data
          obstacleDistance = data['obstacleDistance'] ?? 0;
          obstacleDetected = obstacleDistance > 0 && obstacleDistance < 30; // Threshold: 30cm

          if (missionActive) {
            robotStatus = 'moving';
            isRunning = true;
          } else if (pickComplete && dropComplete && isRunning) {
            robotStatus = 'completed';
            // Save to history when mission completes
            _saveMissionToHistory();
            isRunning = false;
          } else {
            robotStatus = 'ready';
          }
        });
      }
    } catch (e) {
      print('Error fetching status: $e');
    }
  }

  Future<void> setPickStation(int station) async {
    try {
      await http.get(Uri.parse('http://$esp32IP/setpick/$station')).timeout(
        const Duration(seconds: 3),
      );
      setState(() {
        pickStation = station;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pick Station $station selected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Could not connect to robot')),
      );
    }
  }

  Future<void> setDropStation(int station) async {
    try {
      await http.get(Uri.parse('http://$esp32IP/setdrop/$station')).timeout(
        const Duration(seconds: 3),
      );
      setState(() {
        dropStation = station;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Drop Station $station selected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Could not connect to robot')),
      );
    }
  }

  Future<void> startMission() async {
    if (pickStation == 0 || dropStation == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Pick and Drop stations first!')),
      );
      return;
    }

    if (pickStation == dropStation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick and Drop stations must be different!')),
      );
      return;
    }

    try {
      await http.get(Uri.parse('http://$esp32IP/start')).timeout(
        const Duration(seconds: 3),
      );
      setState(() {
        isRunning = true;
        missionActive = true;
        robotStatus = 'moving';
        uptime = 0;
        currentTask = 'Mission started - Moving to Station $pickStation';
        missionStartTime = DateTime.now();
        missionStartBattery = batteryLevel.toInt();
        pickComplete = false;
        dropComplete = false;
      });

      // Start battery and uptime timers
      batteryTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (batteryLevel > 0) {
          setState(() {
            batteryLevel = (batteryLevel - 0.08).clamp(0, 100);
            updateBatteryAnimation();
          });
        }
      });
      uptimeTimer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => uptime++));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mission Started!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Could not start mission')),
      );
    }
  }

  Future<void> stopMission() async {
    try {
      await http.get(Uri.parse('http://$esp32IP/stop')).timeout(
        const Duration(seconds: 3),
      );

      // Save mission to history before stopping
      if (missionStartTime != null) {
        _saveMissionToHistory();
      }

      setState(() {
        isRunning = false;
        missionActive = false;
        robotStatus = 'idle';
        currentTask = null;
      });
      batteryTimer?.cancel();
      uptimeTimer?.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mission Stopped!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Could not stop mission')),
      );
    }
  }

  void _saveMissionToHistory() {
    if (missionStartTime == null) return;

    final now = DateTime.now();
    final duration = now.difference(missionStartTime!).inSeconds;

    final history = OperationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskType: 'Pick & Drop',
      pickStation: pickStation,
      dropStation: dropStation,
      date: DateFormat('MMM dd, yyyy').format(now),
      time: DateFormat('hh:mm a').format(missionStartTime!),
      batteryLevel: missionStartBattery,
      duration: duration,
      status: pickComplete && dropComplete ? 'Completed' : 'Stopped',
    );

    setState(() {
      operationHistory.insert(0, history); // Add to beginning of list
    });

    // Reset mission tracking
    missionStartTime = null;
    missionStartBattery = 0;
  }

  Color getBatteryColor() {
    if (batteryLevel > 60) return Colors.green;
    if (batteryLevel > 30) return Colors.orange;
    return Colors.red;
  }

  Color getStatusColor() {
    switch (robotStatus) {
      case 'ready':
        return Colors.green;
      case 'moving':
        return Colors.blue;
      case 'picking':
        return Colors.purple;
      case 'placing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _getCurrentPage() {
    switch (currentPage) {
      case 'home':
        return _buildHomePage();
      case 'history':
        return HistoryPage(history: operationHistory);
      case 'profile':
        return const ProfilePage();
      default:
        return _buildHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFCC80),
        toolbarHeight: 60,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/logo.png'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 10),
            const Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.notifications, color: Colors.black87, size: 22),
          SizedBox(width: 10),
          Icon(Icons.settings, color: Colors.black87, size: 22),
          SizedBox(width: 10),
        ],
      ),
      body: _getCurrentPage(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ========================= HOME PAGE =========================
  Widget _buildHomePage() {
    String missionStatus = missionActive ? 'Running' : 'Idle';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // WELCOME BACK - Compact
          Row(
            children: const [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.orangeAccent,
                child: Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Welcome Back, Pankaj',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // STATUS CARD - Compact with Animation (FIXED: Same percentage)
          Card(
            color: warmBeige,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _batteryAnimation,
                    builder: (context, child) {
                      return CircularPercentIndicator(
                        radius: 35,
                        lineWidth: 5,
                        percent: batteryLevel / 100, // Fixed to use batteryLevel directly
                        center: Text('${batteryLevel.toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        progressColor: getBatteryColor(),
                        backgroundColor: Colors.grey.shade300,
                      );
                    },
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: Car 1',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Status: ${robotStatus.toUpperCase()}',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: getStatusColor())),
                        Text('Efficiency: ${batteryLevel.toInt()}%', // Fixed to match circle
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // CURRENT STATUS SECTION (Replacing Control)
          const Text("Current Status",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: warmPeach,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _compactStatusItem("Mission", missionStatus),
                    _compactStatusItem("Pick Station", pickStation == 0 ? "Not Set" : "$pickStation"),
                    _compactStatusItem("Drop Station", dropStation == 0 ? "Not Set" : "$dropStation"),
                  ],
                ),
                if (obstacleDetected) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade400, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "⚠ Obstacle Detected: ${obstacleDistance}cm",
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // PICK & DROP STATIONS SIDE BY SIDE
          const Text("Select Stations",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Row(
            children: [
              // PICK Station
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: warmCream,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text("📦 PICK",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...List.generate(
                        3,
                            (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: SizedBox(
                            width: double.infinity,
                            child: AnimatedButton(
                              onPressed: () => setPickStation(i + 1),
                              backgroundColor: pickStation == (i + 1)
                                  ? const Color(0xFFFFB74D) // Darker light orange
                                  : const Color(0xFFFFE0B2), // Light orange fade
                              child: Text('Station ${i + 1}',
                                  style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // DROP Station
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: warmCream,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text("📍 DROP",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...List.generate(
                        3,
                            (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: SizedBox(
                            width: double.infinity,
                            child: AnimatedButton(
                              onPressed: () => setDropStation(i + 1),
                              backgroundColor: dropStation == (i + 1)
                                  ? const Color(0xFFFFB74D) // Darker light orange
                                  : const Color(0xFFFFE0B2), // Light orange fade
                              child: Text('Station ${i + 1}',
                                  style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // START & STOP BUTTONS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: warmBeige,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedButton(
                    onPressed: startMission,
                    backgroundColor: Colors.green.shade600,
                    child: const Text("Start",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedButton(
                    onPressed: stopMission,
                    backgroundColor: Colors.red.shade600,
                    child: const Text("Stop",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Extra padding at bottom
        ],
      ),
    );
  }

  Widget _compactStatusItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  // ========================= BOTTOM NAVIGATION =========================
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: ['home', 'history', 'profile'].indexOf(currentPage),
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          currentPage = ['home', 'history', 'profile'][index];
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}

// ========================= ANIMATED BUTTON WIDGET =========================
class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color backgroundColor;

  const AnimatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(
          onPressed: null, // Disable default onPressed to use GestureDetector
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor,
            disabledBackgroundColor: widget.backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 3,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ========================= HISTORY PAGE =========================
class HistoryPage extends StatelessWidget {
  final List<OperationHistory> history;
  const HistoryPage({Key? key, required this.history}) : super(key: key);

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade600;
      case 'stopped':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'stopped':
        return Icons.stop_circle;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No Task History Yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Complete tasks to see them here",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final statusColor = _getStatusColor(item.status);
        final statusIcon = _getStatusIcon(item.status);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFE0B2), // Light orange
                const Color(0xFFFFF3E0), // Warm beige
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.taskType,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'ID: ${item.id.substring(item.id.length - 6)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            item.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  color: Colors.orange.shade200,
                ),
                const SizedBox(height: 12),

                // Station Info Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.upload,
                        label: 'Pick',
                        value: 'Station ${item.pickStation}',
                        color: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.download,
                        label: 'Drop',
                        value: 'Station ${item.dropStation}',
                        color: Colors.purple.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date, Time, Duration Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                      icon: Icons.calendar_today,
                      label: item.date,
                      color: Colors.orange.shade700,
                    ),
                    _buildDetailItem(
                      icon: Icons.access_time,
                      label: item.time,
                      color: Colors.orange.shade700,
                    ),
                    _buildDetailItem(
                      icon: Icons.timer,
                      label: _formatDuration(item.duration),
                      color: Colors.orange.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Battery Level
                Row(
                  children: [
                    Icon(Icons.battery_charging_full,
                        color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Battery: ${item.batteryLevel}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: item.batteryLevel / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item.batteryLevel > 60
                              ? Colors.green.shade600
                              : item.batteryLevel > 30
                              ? Colors.orange.shade600
                              : Colors.red.shade600,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

// ========================= PROFILE PAGE =========================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Profile Page\nComing Soon...",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey[800]),
      ),
    );
  }
}
