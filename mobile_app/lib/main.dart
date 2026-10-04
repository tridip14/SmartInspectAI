import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

const String backendUrl = 'http://127.0.0.1:8000';

void main() {
  runApp(const DosjeApp());
}

class DosjeApp extends StatelessWidget {
  const DosjeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DoSJE Smart Inspection System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DoSJE Smart Inspection System'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Centralized Monitoring &\nSurprise Inspection System',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Official Dashboard'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OfficialDashboard(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.assignment),
                  label: const Text('Inspector Dashboard'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InspectorDashboard(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// OFFICIAL DASHBOARD
// ============================================================

class OfficialDashboard extends StatefulWidget {
  const OfficialDashboard({super.key});

  @override
  State<OfficialDashboard> createState() => _OfficialDashboardState();
}

class _OfficialDashboardState extends State<OfficialDashboard> {
  List<dynamic> projects = [];
  List<dynamic> inspectors = [];
  List<dynamic> inspections = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final projectResponse =
          await http.get(Uri.parse('$backendUrl/projects'));

      final inspectorResponse =
          await http.get(Uri.parse('$backendUrl/inspectors'));

      final inspectionResponse =
          await http.get(Uri.parse('$backendUrl/inspections'));

      if (projectResponse.statusCode == 200 &&
          inspectorResponse.statusCode == 200 &&
          inspectionResponse.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          projects = jsonDecode(projectResponse.body);
          inspectors = jsonDecode(inspectorResponse.body);
          inspections = jsonDecode(inspectionResponse.body);
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> assignInspection() async {
    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No projects available'),
        ),
      );
      return;
    }

    final projectId = projects[0]['id'];

    try {
      final response = await http.post(
        Uri.parse(
          '$backendUrl/assign-inspection?project_id=$projectId',
        ),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['inspection_id'] != null) {
        await loadDashboard();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Inspection assigned to ${data['inspector']}',
            ),
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['error'] ?? 'Assignment failed',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
        ),
      );
    }
  }

  // ==========================================================
  // AI ALERT WIDGET
  // ==========================================================

  Widget buildAIAlert(dynamic inspection) {
    final aiResult =
        (inspection['anomaly_result'] ?? '').toString();

    final result = aiResult.toLowerCase();

    Color alertColor;
    IconData alertIcon;
    String alertText;

    if (result.contains('pending')) {
      alertColor = Colors.orange;
      alertIcon = Icons.pending;
      alertText = 'AI Analysis Pending';
    } else if (result.contains('anomaly')) {
      alertColor = Colors.red;
      alertIcon = Icons.warning;
      alertText = 'AI Anomaly Alert';
    } else {
      alertColor = Colors.green;
      alertIcon = Icons.check_circle;
      alertText = 'No Anomaly Detected';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          alertIcon,
          color: alertColor,
          size: 32,
        ),
        title: Text(
          alertText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: alertColor,
          ),
        ),
        subtitle: Text(
          'Inspection #${inspection['inspection_id']} • '
          '${inspection['project']}',
        ),
        trailing: Text(
          aiResult,
          style: TextStyle(
            color: alertColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = inspections
        .where(
          (item) => item['status'] == 'Completed',
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Official Monitoring Dashboard',
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadDashboard,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Real-Time Department Monitoring',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // STAT CARDS
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Projects',
                          value: projects.length.toString(),
                          icon: Icons.business,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'Inspectors',
                          value: inspectors.length.toString(),
                          icon: Icons.people,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Inspections',
                          value: inspections.length.toString(),
                          icon: Icons.assignment,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'Completed',
                          value: completed.toString(),
                          icon: Icons.check_circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // RANDOM INSPECTION
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shuffle),
                      label: const Text(
                        'Assign Random Inspection',
                      ),
                      onPressed: assignInspection,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // CCTV
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.videocam),
                      label: const Text(
                        'Open CCTV Monitoring',
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CctvMonitoringScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // VIDEO CONFERENCING
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.video_call),
                      label: const Text(
                        'Random Video Conferencing',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const VideoConferenceScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // AI MONITORING ALERTS
                  // ==================================================

                  const Text(
                    'AI Monitoring Alerts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (inspections.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No AI alerts available',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  ...inspections.map(
                    (inspection) {
                      return buildAIAlert(inspection);
                    },
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // INSPECTION MONITORING
                  // ==================================================

                  const Text(
                    'Inspection Monitoring',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (inspections.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No inspections available',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  ...inspections.map(
                    (inspection) {
                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inspection #${inspection['inspection_id']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Project: ${inspection['project']}',
                              ),
                              Text(
                                'Location: ${inspection['location']}',
                              ),
                              Text(
                                'Inspector: ${inspection['inspector']}',
                              ),
                              Text(
                                'District: ${inspection['district']}',
                              ),
                              Text(
                                'Status: ${inspection['status']}',
                              ),
                              Text(
                                'GPS: '
                                '${inspection['latitude'] ?? 'Not available'}, '
                                '${inspection['longitude'] ?? 'Not available'}',
                              ),
                              Text(
                                'AI Result: '
                                '${inspection['anomaly_result'] ?? 'Pending'}',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// VIDEO CONFERENCE SCREEN
// ============================================================

class VideoConferenceScreen extends StatefulWidget {
  const VideoConferenceScreen({super.key});

  @override
  State<VideoConferenceScreen> createState() =>
      _VideoConferenceScreenState();
}

class _VideoConferenceScreenState
    extends State<VideoConferenceScreen> {
  String? meetingUrl;
  String? meetingId;

  void generateRandomMeeting() {
    final random = Random();

    final randomNumber =
        100000 + random.nextInt(900000);

    final id =
        'DoSJE-SmartInspect-$randomNumber';

    setState(() {
      meetingId = id;
      meetingUrl = 'https://meet.jit.si/$id';
    });
  }

  Future<void> joinMeeting() async {
    if (meetingUrl == null) {
      generateRandomMeeting();
      return;
    }

    final uri = Uri.parse(meetingUrl!);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open video meeting',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Random Video Conferencing',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.video_call,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            const Text(
              'Project VC Connectivity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Connect with Project Incharge, Staff '
              'or Beneficiaries for real-time monitoring.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            if (meetingId != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Generated Meeting ID',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        meetingId!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.shuffle),
              label: const Text(
                'Generate Random VC Room',
              ),
              onPressed: generateRandomMeeting,
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(
                Icons.video_camera_front,
              ),
              label: const Text(
                'Join Video Meeting',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),
              onPressed: meetingUrl == null
                  ? null
                  : joinMeeting,
            ),

            const SizedBox(height: 20),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Demo flow:\n'
                  'Official → Generate Random VC Room → '
                  'Share Meeting ID → Project Staff/Beneficiary '
                  'joins the same room.',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INSPECTOR DASHBOARD
// ============================================================

class InspectorDashboard extends StatelessWidget {
  const InspectorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspector Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Inspection Module',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            icon: const Icon(Icons.location_on),
            label: const Text(
              'GPS & Evidence Capture',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EvidenceScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            icon: const Icon(Icons.checklist),
            label: const Text(
              'Inspection Checklist',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const InspectionChecklistScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            icon: const Icon(Icons.people),
            label: const Text('Attendance'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AttendanceScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text(
              'Submit Inspection',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SubmitInspectionScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            icon: const Icon(Icons.smart_toy),
            label: const Text('AI Analysis'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AIAnalysisScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EVIDENCE SCREEN
// ============================================================

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() =>
      _EvidenceScreenState();
}

class _EvidenceScreenState
    extends State<EvidenceScreen> {
  final ImagePicker picker = ImagePicker();

  XFile? selectedImage;
  Uint8List? imageBytes;

  String latitude = '';
  String longitude = '';

  Future<void> getLocation() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location service is disabled',
          ),
        ),
      );

      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      return;
    }

    final position =
        await Geolocator.getCurrentPosition();

    if (!mounted) return;

    setState(() {
      latitude =
          position.latitude.toString();
      longitude =
          position.longitude.toString();
    });
  }

  Future<void> captureImage() async {
    final image = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = image;
        imageBytes = bytes;
      });
    }
  }

  Future<void> selectFromGallery() async {
    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = image;
        imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS & Evidence'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.location_on),
            label: const Text(
              'Capture GPS Location',
            ),
            onPressed: getLocation,
          ),

          const SizedBox(height: 10),

          Text(
            'Latitude: '
            '${latitude.isEmpty ? 'Not captured' : latitude}',
          ),

          Text(
            'Longitude: '
            '${longitude.isEmpty ? 'Not captured' : longitude}',
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text(
              'Capture Evidence Photo',
            ),
            onPressed: captureImage,
          ),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            icon: const Icon(Icons.photo),
            label: const Text(
              'Select Evidence from Gallery',
            ),
            onPressed: selectFromGallery,
          ),

          const SizedBox(height: 20),

          if (imageBytes != null)
            Image.memory(
              imageBytes!,
              height: 300,
              fit: BoxFit.cover,
            ),

          if (selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
              ),
              child: Text(
                'Evidence: ${selectedImage!.name}',
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// LAPTOP CAMERA SCREEN
// ============================================================

class LaptopCameraScreen extends StatefulWidget {
  const LaptopCameraScreen({super.key});

  @override
  State<LaptopCameraScreen> createState() =>
      _LaptopCameraScreenState();
}

class _LaptopCameraScreenState
    extends State<LaptopCameraScreen> {
  CameraController? controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        return;
      }

      controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : controller == null ||
                  !controller!.value.isInitialized
              ? const Center(
                  child: Text(
                    'Camera unavailable',
                  ),
                )
              : CameraPreview(controller!),
    );
  }
}

// ============================================================
// INSPECTION CHECKLIST
// ============================================================

class InspectionChecklistScreen
    extends StatefulWidget {
  const InspectionChecklistScreen({super.key});

  @override
  State<InspectionChecklistScreen> createState() =>
      _InspectionChecklistScreenState();
}

class _InspectionChecklistScreenState
    extends State<InspectionChecklistScreen> {
  final List<String> questions = [
    'Project facilities are operational',
    'Beneficiary records are available',
    'Staff attendance records are maintained',
    'Project activities are being conducted',
    'Required infrastructure is available',
  ];

  final Map<int, String> answers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inspection Checklist',
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${questions[index]}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              answers[index] = 'Yes';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                answers[index] == 'Yes'
                                    ? Colors.green
                                    : null,
                            foregroundColor:
                                answers[index] == 'Yes'
                                    ? Colors.white
                                    : null,
                          ),
                          child: const Text('Yes'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              answers[index] = 'No';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                answers[index] == 'No'
                                    ? Colors.red
                                    : null,
                            foregroundColor:
                                answers[index] == 'No'
                                    ? Colors.white
                                    : null,
                          ),
                          child: const Text('No'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// ATTENDANCE
// ============================================================

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState
    extends State<AttendanceScreen> {
  final List<String> people = [
    'Project Incharge',
    'Staff Member 1',
    'Staff Member 2',
    'Beneficiary Representative',
  ];

  final Map<String, bool> attendance = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Mark Attendance',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...people.map(
            (person) {
              return Card(
                child: CheckboxListTile(
                  title: Text(person),
                  value:
                      attendance[person] ?? false,
                  onChanged: (value) {
                    setState(() {
                      attendance[person] =
                          value ?? false;
                    });
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text(
              'Save Attendance',
            ),
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Attendance saved successfully',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUBMIT INSPECTION
// ============================================================

class SubmitInspectionScreen
    extends StatefulWidget {
  const SubmitInspectionScreen({super.key});

  @override
  State<SubmitInspectionScreen> createState() =>
      _SubmitInspectionScreenState();
}

class _SubmitInspectionScreenState
    extends State<SubmitInspectionScreen> {
  final TextEditingController remarksController =
      TextEditingController();

  final TextEditingController latitudeController =
      TextEditingController(
    text: '22.5726',
  );

  final TextEditingController longitudeController =
      TextEditingController(
    text: '88.3639',
  );

  final TextEditingController evidenceController =
      TextEditingController(
    text: 'inspection_photo_001.jpg',
  );

  final TextEditingController anomalyController =
      TextEditingController(
    text: 'No anomaly detected',
  );

  final TextEditingController inspectionIdController =
      TextEditingController(
    text: '1',
  );

  bool submitting = false;

  Future<void> submitInspection() async {
    setState(() {
      submitting = true;
    });

    try {
      final id =
          inspectionIdController.text.trim();

      final uri = Uri.parse(
        '$backendUrl/inspections/$id',
      ).replace(
        queryParameters: {
          'remarks': remarksController.text,
          'latitude': latitudeController.text,
          'longitude': longitudeController.text,
          'evidence': evidenceController.text,
          'anomaly_result':
              anomalyController.text,
        },
      );

      final response =
          await http.put(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Inspection submitted successfully',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Inspection submission failed',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          submitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    remarksController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    evidenceController.dispose();
    anomalyController.dispose();
    inspectionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Submit Inspection',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: inspectionIdController,
            decoration: const InputDecoration(
              labelText: 'Inspection ID',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: remarksController,
            decoration: const InputDecoration(
              labelText: 'Remarks',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 12),

          TextField(
            controller: latitudeController,
            decoration: const InputDecoration(
              labelText: 'Latitude',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: longitudeController,
            decoration: const InputDecoration(
              labelText: 'Longitude',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: evidenceController,
            decoration: const InputDecoration(
              labelText: 'Evidence',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: anomalyController,
            decoration: const InputDecoration(
              labelText: 'AI Anomaly Result',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            icon: submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(
              submitting
                  ? 'Submitting...'
                  : 'Submit Inspection',
            ),
            onPressed:
                submitting
                    ? null
                    : submitInspection,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// AI ANALYSIS
// ============================================================

class AIAnalysisScreen
    extends StatelessWidget {
  const AIAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.smart_toy,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            const Text(
              'AI-Based Inspection Analysis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Current AI Result',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No anomaly detected',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(
                Icons.analytics,
              ),
              label: const Text(
                'Run AI Analysis',
              ),
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'AI analysis completed',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CCTV MONITORING
// ============================================================

class CctvMonitoringScreen
    extends StatefulWidget {
  const CctvMonitoringScreen({
    super.key,
  });

  @override
  State<CctvMonitoringScreen> createState() =>
      _CctvMonitoringScreenState();
}

class _CctvMonitoringScreenState
    extends State<CctvMonitoringScreen> {
  CameraController? controller;

  bool loading = true;
  bool monitoring = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras =
          await availableCameras();

      if (cameras.isEmpty) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        return;
      }

      controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  void startMonitoring() {
    setState(() {
      monitoring = true;
    });
  }

  void stopMonitoring() {
    setState(() {
      monitoring = false;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CCTV Monitoring',
        ),
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : controller == null ||
                  !controller!
                      .value
                      .isInitialized
              ? const Center(
                  child: Text(
                    'Camera unavailable',
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: CameraPreview(
                        controller!,
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Icon(
                                Icons.circle,
                                color: monitoring
                                    ? Colors.red
                                    : Colors.grey,
                                size: 14,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                monitoring
                                    ? 'CCTV Monitoring Active'
                                    : 'CCTV Monitoring Stopped',
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          SizedBox(
                            width:
                                double.infinity,
                            child:
                                ElevatedButton
                                    .icon(
                              icon: Icon(
                                monitoring
                                    ? Icons.stop
                                    : Icons.play_arrow,
                              ),
                              label: Text(
                                monitoring
                                    ? 'Stop CCTV Monitoring'
                                    : 'Start CCTV Monitoring',
                              ),
                              onPressed: monitoring
                                  ? stopMonitoring
                                  : startMonitoring,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}