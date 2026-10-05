import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

// ============================================================
// SMARTINSPECTAI DESIGN SYSTEM
// UI-only layer: business logic, APIs and workflows remain intact.
// ============================================================

class AppDesign {
  static const primary = Color(0xFF3657E8);
  static const primaryDark = Color(0xFF2339A6);
  static const accent = Color(0xFF06B6D4);
  static const ink = Color(0xFF101828);
  static const muted = Color(0xFF667085);
  static const canvas = Color(0xFFF6F8FC);
  static const surface = Color(0xFFFFFFFF);
  static const success = Color(0xFF12B76A);
  static const warning = Color(0xFFF79009);
  static const danger = Color(0xFFF04438);

  static ThemeData theme() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          onPrimary: Colors.white,
          secondary: accent,
          onSecondary: Colors.white,
          surface: surface,
          onSurface: ink,
          error: danger,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Color(0x180F172A),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE7EAF1)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        labelStyle: const TextStyle(color: muted, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
        prefixIconColor: primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, 50),
          side: const BorderSide(color: Color(0xFFD0D5DD)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8EDFF),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: TextStyle(
          color: primary,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: muted,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF2F4F7),
        selectedColor: const Color(0xFFE8EDFF),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: ink,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE7EAF1),
        thickness: 1,
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(color: AppDesign.muted, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final bool positive;
  final bool warning;
  const StatusPill({
    super.key,
    required this.label,
    this.positive = false,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive
        ? AppDesign.success
        : warning
        ? AppDesign.warning
        : AppDesign.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ============================================================
// APP CONFIGURATION
// ============================================================

class AppConfig {
  // Android Emulator
  static const String apiBaseUrl = 'http://10.0.2.2:8000';

  // For Flutter Web/Desktop use:
  // static const String apiBaseUrl = 'http://127.0.0.1:8000';

  // For a physical Android phone, use your computer's LAN IP:
  // static const String apiBaseUrl = 'http://192.168.x.x:8000';
}

// ============================================================
// DATA MODELS
// ============================================================

class Project {
  final int id;
  final String name;
  final String location;
  final String status;
  final String inspector;

  Project({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.inspector,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Project',
      location: json['location'] ?? 'Unknown Location',
      status: json['status'] ?? 'Pending',
      inspector: json['inspector'] ?? 'Not Assigned',
    );
  }
}

class InspectionReport {
  final String projectName;
  final String location;
  final String inspectionDate;
  final bool gpsVerified;
  final bool evidenceCaptured;
  final bool cctvVerified;
  final bool staffVerified;
  final int attendance;
  final String aiResult;
  final String compliance;
  final String outcome;

  InspectionReport({
    required this.projectName,
    required this.location,
    required this.inspectionDate,
    required this.gpsVerified,
    required this.evidenceCaptured,
    required this.cctvVerified,
    required this.staffVerified,
    required this.attendance,
    required this.aiResult,
    required this.compliance,
    required this.outcome,
  });
}

class AlertItem {
  final String title;
  final String message;
  final String severity;
  final String time;

  AlertItem({
    required this.title,
    required this.message,
    required this.severity,
    required this.time,
  });
}

// ============================================================
// GLOBAL APP STATE
// ============================================================

class AppState {
  static List<Project> projects = [
    Project(
      id: 1,
      name: 'Sunrise Welfare Institute',
      location: 'Kolkata',
      status: 'Active',
      inspector: 'Inspector A',
    ),
    Project(
      id: 2,
      name: 'Hope Development Centre',
      location: 'Kolkata',
      status: 'Active',
      inspector: 'Inspector B',
    ),
    Project(
      id: 3,
      name: 'Social Welfare Foundation',
      location: 'Howrah',
      status: 'Pending',
      inspector: 'Inspector C',
    ),
    Project(
      id: 4,
      name: 'Community Support Centre',
      location: 'Siliguri',
      status: 'Active',
      inspector: 'Inspector D',
    ),
  ];

  static List<InspectionReport> reports = [
    InspectionReport(
      projectName: 'Sunrise Welfare Institute',
      location: 'Kolkata',
      inspectionDate: '05 Oct 2026',
      gpsVerified: true,
      evidenceCaptured: true,
      cctvVerified: true,
      staffVerified: true,
      attendance: 94,
      aiResult: 'No major anomaly detected',
      compliance: 'Compliant',
      outcome: 'Inspection completed successfully',
    ),
    InspectionReport(
      projectName: 'Hope Development Centre',
      location: 'Kolkata',
      inspectionDate: '04 Oct 2026',
      gpsVerified: true,
      evidenceCaptured: true,
      cctvVerified: true,
      staffVerified: true,
      attendance: 88,
      aiResult: 'Minor attendance variation detected',
      compliance: 'Under Review',
      outcome: 'Follow-up recommended',
    ),
  ];

  static List<AlertItem> alerts = [
    AlertItem(
      title: 'Attendance Alert',
      message: 'Attendance below expected threshold.',
      severity: 'High',
      time: '10 min ago',
    ),
    AlertItem(
      title: 'Inspection Due',
      message: 'Surprise inspection pending.',
      severity: 'Medium',
      time: '25 min ago',
    ),
    AlertItem(
      title: 'CCTV Status',
      message: 'CCTV connection requires verification.',
      severity: 'Medium',
      time: '1 hour ago',
    ),
    AlertItem(
      title: 'AI Analysis',
      message: 'Inspection analysis completed.',
      severity: 'Low',
      time: '2 hours ago',
    ),
  ];
}

// ============================================================
// MAIN
// ============================================================

void main() {
  runApp(const SmartInspectAI());
}

// ============================================================
// ROOT APP
// ============================================================

class SmartInspectAI extends StatelessWidget {
  const SmartInspectAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoSJE SmartInspectAI',
      debugShowCheckedModeBanner: false,
      theme: AppDesign.theme(),
      home: const LoginScreen(),
    );
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool loading = false;

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final userId = userController.text.trim();
    final password = passwordController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter User ID and Password')),
      );
      return;
    }

    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => loading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  Widget _brandPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppDesign.primaryDark, AppDesign.primary, AppDesign.accent],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .24),
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'SmartInspectAI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Government smart monitoring, field inspection and AI-assisted analytics.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .84),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 34),
              const _LoginFeature(
                icon: Icons.location_on_rounded,
                text: 'GPS verified field inspections',
              ),
              const _LoginFeature(
                icon: Icons.auto_awesome_rounded,
                text: 'AI-powered anomaly analysis',
              ),
              const _LoginFeature(
                icon: Icons.videocam_rounded,
                text: 'CCTV & stakeholder connectivity',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final form = Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(wide ? 48 : 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8EDFF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.account_balance_rounded,
                                color: AppDesign.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Secure Officer Login',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Access your SmartInspectAI monitoring workspace.',
                          style: TextStyle(color: AppDesign.muted, height: 1.4),
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          controller: userController,
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                              onPressed: () => setState(
                                () => obscurePassword = !obscurePassword,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: loading ? null : login,
                            icon: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login_rounded),
                            label: Text(
                              loading ? 'AUTHENTICATING...' : 'SIGN IN',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'Demo Login • Secure monitoring workspace',
                            style: TextStyle(
                              color: AppDesign.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          if (!wide) return form;
          return Row(
            children: [
              Expanded(flex: 5, child: _brandPanel()),
              Expanded(flex: 6, child: form),
            ],
          );
        },
      ),
    );
  }
}

class _LoginFeature extends StatelessWidget {
  final IconData icon;
  final String text;
  const _LoginFeature({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 19),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// MAIN NAVIGATION
// ============================================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    DashboardScreen(),
    ProjectsScreen(),
    InspectionsScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  static const destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.business_outlined),
      selectedIcon: Icon(Icons.business_rounded),
      label: 'Projects',
    ),
    NavigationDestination(
      icon: Icon(Icons.fact_check_outlined),
      selectedIcon: Icon(Icons.fact_check_rounded),
      label: 'Inspections',
    ),
    NavigationDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications_rounded),
      label: 'Alerts',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  static const railDestinations = <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.business_outlined),
      selectedIcon: Icon(Icons.business_rounded),
      label: Text('Projects'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.fact_check_outlined),
      selectedIcon: Icon(Icons.fact_check_rounded),
      label: Text('Inspections'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications_rounded),
      label: Text('Alerts'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: Text('Profile'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        if (!wide) {
          return Scaffold(
            body: screens[selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => selectedIndex = index),
              destinations: destinations,
            ),
          );
        }
        return Scaffold(
          body: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(right: BorderSide(color: Color(0xFFE7EAF1))),
                ),
                child: NavigationRail(
                  extended: constraints.maxWidth >= 1180,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => selectedIndex = index),
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 28),
                    child: Column(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EDFF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: AppDesign.primary,
                          ),
                        ),
                        if (constraints.maxWidth >= 1180) ...[
                          const SizedBox(height: 10),
                          const Text(
                            'SmartInspect',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  destinations: railDestinations,
                ),
              ),
              Expanded(child: screens[selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool loadingProjects = false;

  int get activeProjects {
    return AppState.projects
        .where((project) => project.status == 'Active')
        .length;
  }

  int get pendingProjects {
    return AppState.projects
        .where((project) => project.status == 'Pending')
        .length;
  }

  Future<void> loadProjects() async {
    setState(() {
      loadingProjects = true;
    });

    try {
      final response = await http
          .get(Uri.parse('${AppConfig.apiBaseUrl}/projects'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          final backendProjects = data
              .map((item) => Project.fromJson(Map<String, dynamic>.from(item)))
              .toList();

          if (backendProjects.isNotEmpty) {
            AppState.projects = backendProjects;
          }
        }

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projects synchronized with backend')),
        );
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backend unavailable. Showing local project data.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loadingProjects = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartInspectAI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loadingProjects ? null : loadProjects,
            icon: loadingProjects
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadProjects,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Government Smart Monitoring Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: 'Projects',
                    value: '${AppState.projects.length}',
                    icon: Icons.business,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    title: 'Active',
                    value: '$activeProjects',
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: 'Pending',
                    value: '$pendingProjects',
                    icon: Icons.pending_actions,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    title: 'Reports',
                    value: '${AppState.reports.length}',
                    icon: Icons.description,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ActionCard(
              title: 'Random Inspection',
              subtitle: 'Automatically assign a surprise inspection',
              icon: Icons.shuffle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RandomInspectionScreen(),
                  ),
                );
              },
            ),

            ActionCard(
              title: 'Start Inspection',
              subtitle: 'Perform a field inspection',
              icon: Icons.fact_check,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InspectionDetailsScreen(),
                  ),
                );
              },
            ),

            ActionCard(
              title: 'CCTV Monitoring',
              subtitle: 'Check project CCTV connection',
              icon: Icons.videocam,
              onTap: () {
                if (AppState.projects.isEmpty) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CctvScreen(project: AppState.projects.first),
                  ),
                );
              },
            ),

            ActionCard(
              title: 'Video Conference',
              subtitle: 'Connect with staff and beneficiaries',
              icon: Icons.video_call,
              onTap: () {
                if (AppState.projects.isEmpty) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VideoConferenceScreen(project: AppState.projects.first),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ...AppState.alerts
                .take(4)
                .map(
                  (alert) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text(alert.title),
                      subtitle: Text(alert.message),
                      trailing: Text(
                        alert.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
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
// DASHBOARD STAT CARD
// ============================================================

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppDesign.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppDesign.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, color: AppDesign.muted, size: 19),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ACTION CARD
// ============================================================

class ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8EDFF), Color(0xFFE6F9FC)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppDesign.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppDesign.muted,
                        fontSize: 12.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.arrow_forward_rounded, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PROJECTS SCREEN
// ============================================================

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String searchText = '';

  List<Project> get filteredProjects {
    if (searchText.isEmpty) {
      return AppState.projects;
    }

    final query = searchText.toLowerCase();

    return AppState.projects.where((project) {
      return project.name.toLowerCase().contains(query) ||
          project.location.toLowerCase().contains(query) ||
          project.status.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          Expanded(
            child: filteredProjects.isEmpty
                ? const Center(child: Text('No projects found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${project.id}')),
                          title: Text(
                            project.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${project.location}\nInspector: ${project.inspector}',
                          ),
                          isThreeLine: true,
                          trailing: Chip(label: Text(project.status)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProjectDetailsScreen(project: project),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROJECT DETAILS
// ============================================================

class ProjectDetailsScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DetailRow(
                    icon: Icons.location_on,
                    title: 'Location',
                    value: project.location,
                  ),
                  DetailRow(
                    icon: Icons.person,
                    title: 'Inspector',
                    value: project.inspector,
                  ),
                  DetailRow(
                    icon: Icons.info,
                    title: 'Status',
                    value: project.status,
                  ),
                  const DetailRow(
                    icon: Icons.groups,
                    title: 'Stakeholders',
                    value: 'Project Incharge / Staff / Beneficiaries',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          ActionCard(
            title: 'CCTV Monitoring',
            subtitle: 'View CCTV monitoring interface',
            icon: Icons.videocam,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CctvScreen(project: project)),
              );
            },
          ),

          ActionCard(
            title: 'Video Conference',
            subtitle: 'Connect with project stakeholders',
            icon: Icons.video_call,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoConferenceScreen(project: project),
                ),
              );
            },
          ),

          ActionCard(
            title: 'Start Inspection',
            subtitle: 'Perform field inspection',
            icon: Icons.fact_check,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InspectionDetailsScreen(),
                ),
              );
            },
          ),

          ActionCard(
            title: 'Inspection Reports',
            subtitle: 'View completed inspection reports',
            icon: Icons.description,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DETAIL ROW
// ============================================================

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const DetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: AppDesign.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppDesign.muted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INSPECTIONS SCREEN
// ============================================================

class InspectionsScreen extends StatelessWidget {
  const InspectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspections')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ActionCard(
            title: 'Random Inspection',
            subtitle: 'Automatically select a project',
            icon: Icons.shuffle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RandomInspectionScreen(),
                ),
              );
            },
          ),

          ActionCard(
            title: 'Mobile Inspection',
            subtitle: 'GPS + evidence + AI analysis',
            icon: Icons.phone_android,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InspectionDetailsScreen(),
                ),
              );
            },
          ),

          ActionCard(
            title: 'Completed Reports',
            subtitle: 'View inspection reports',
            icon: Icons.description,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RANDOM INSPECTION
// ============================================================

class RandomInspectionScreen extends StatefulWidget {
  const RandomInspectionScreen({super.key});

  @override
  State<RandomInspectionScreen> createState() => _RandomInspectionScreenState();
}

class _RandomInspectionScreenState extends State<RandomInspectionScreen> {
  Project? selectedProject;
  bool assigning = true;

  @override
  void initState() {
    super.initState();
    assignInspection();
  }

  Future<void> assignInspection() async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    if (AppState.projects.isEmpty) {
      setState(() {
        assigning = false;
      });
      return;
    }

    final random = Random();

    final project = AppState.projects[random.nextInt(AppState.projects.length)];

    setState(() {
      selectedProject = project;
      assigning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Random Inspection')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: assigning
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Selecting inspection randomly...',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                )
              : selectedProject == null
              ? const Text('No project available')
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shuffle, size: 80),
                    const SizedBox(height: 20),
                    const Text(
                      'Inspection Assigned',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              selectedProject!.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(selectedProject!.location),
                            Text('Inspector: ${selectedProject!.inspector}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InspectionDetailsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('START INSPECTION'),
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
// INSPECTION DETAILS
// ============================================================

class InspectionDetailsScreen extends StatefulWidget {
  const InspectionDetailsScreen({super.key});

  @override
  State<InspectionDetailsScreen> createState() =>
      _InspectionDetailsScreenState();
}

class _InspectionDetailsScreenState extends State<InspectionDetailsScreen> {
  final ImagePicker picker = ImagePicker();

  Position? currentPosition;
  XFile? evidenceImage;

  bool gpsVerified = false;
  bool cctvVerified = false;
  bool staffVerified = false;
  bool attendanceChecked = false;

  bool gettingGps = false;
  bool takingPhoto = false;
  bool aiRunning = false;
  bool submitting = false;

  int attendance = 0;

  String aiResult = 'Not analyzed';

  Future<void> getLocation() async {
    setState(() {
      gettingGps = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        currentPosition = position;
        gpsVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS location captured successfully')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('GPS error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          gettingGps = false;
        });
      }
    }
  }

  Future<void> captureEvidence() async {
    setState(() {
      takingPhoto = true;
    });

    try {
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (!mounted) {
        return;
      }

      if (image != null) {
        setState(() {
          evidenceImage = image;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inspection evidence captured')),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Camera error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          takingPhoto = false;
        });
      }
    }
  }

  Future<void> runAI() async {
    if (evidenceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capture inspection evidence first')),
      );
      return;
    }

    setState(() {
      aiRunning = true;
      aiResult = 'AI analysis running...';
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    final random = Random();
    final anomalyDetected = random.nextBool();

    setState(() {
      aiRunning = false;

      if (anomalyDetected) {
        aiResult = 'Potential anomaly detected';
        attendance = 68;
      } else {
        aiResult = 'No major anomaly detected';
        attendance = 94;
      }

      attendanceChecked = true;
    });
  }

  Future<void> submitInspection() async {
    if (!gpsVerified) {
      showMessage('Please capture GPS location first.');
      return;
    }

    if (evidenceImage == null) {
      showMessage('Please capture inspection evidence.');
      return;
    }

    if (!cctvVerified) {
      showMessage('Please verify CCTV status.');
      return;
    }

    if (!staffVerified) {
      showMessage('Please verify staff/stakeholder presence.');
      return;
    }

    if (!attendanceChecked) {
      showMessage('Please run attendance/AI analysis.');
      return;
    }

    setState(() {
      submitting = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    final compliance = attendance >= 80 ? 'Compliant' : 'Under Review';

    final outcome = attendance >= 80
        ? 'Inspection completed successfully'
        : 'Follow-up recommended';

    final report = InspectionReport(
      projectName: 'Sunrise Welfare Institute',
      location: currentPosition == null
          ? 'Unknown'
          : '${currentPosition!.latitude.toStringAsFixed(5)}, '
                '${currentPosition!.longitude.toStringAsFixed(5)}',
      inspectionDate: '05 Oct 2026',
      gpsVerified: gpsVerified,
      evidenceCaptured: evidenceImage != null,
      cctvVerified: cctvVerified,
      staffVerified: staffVerified,
      attendance: attendance,
      aiResult: aiResult,
      compliance: compliance,
      outcome: outcome,
    );

    AppState.reports.insert(0, report);

    setState(() {
      submitting = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => InspectionReportScreen(report: report)),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Field Inspection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Inspection Verification',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          InspectionCheckCard(
            title: 'GPS Verification',
            subtitle: gpsVerified
                ? currentPosition == null
                      ? 'Location verified'
                      : '${currentPosition!.latitude.toStringAsFixed(5)}, '
                            '${currentPosition!.longitude.toStringAsFixed(5)}'
                : 'Capture current inspection location',
            icon: Icons.location_on,
            completed: gpsVerified,
            buttonText: gettingGps ? 'Getting GPS...' : 'Capture GPS',
            onPressed: gettingGps ? null : getLocation,
          ),

          InspectionCheckCard(
            title: 'Evidence Capture',
            subtitle: evidenceImage == null
                ? 'Take inspection evidence photograph'
                : 'Evidence photo captured',
            icon: Icons.camera_alt,
            completed: evidenceImage != null,
            buttonText: takingPhoto ? 'Opening Camera...' : 'Capture Evidence',
            onPressed: takingPhoto ? null : captureEvidence,
          ),

          InspectionCheckCard(
            title: 'CCTV Verification',
            subtitle: cctvVerified
                ? 'CCTV connection verified'
                : 'Verify project CCTV availability',
            icon: Icons.videocam,
            completed: cctvVerified,
            buttonText: cctvVerified ? 'Verified' : 'Verify CCTV',
            onPressed: () {
              setState(() {
                cctvVerified = !cctvVerified;
              });
            },
          ),

          InspectionCheckCard(
            title: 'Staff Verification',
            subtitle: staffVerified
                ? 'Staff/stakeholder presence verified'
                : 'Verify staff or project incharge',
            icon: Icons.groups,
            completed: staffVerified,
            buttonText: staffVerified ? 'Verified' : 'Verify Staff',
            onPressed: () {
              setState(() {
                staffVerified = !staffVerified;
              });
            },
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology),
                      SizedBox(width: 10),
                      Text(
                        'AI Analysis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(aiResult, style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: aiRunning ? null : runAI,
                      icon: aiRunning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        aiRunning ? 'Analyzing...' : 'Run AI Analysis',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          AttendanceCard(attendance: attendance, checked: attendanceChecked),

          const SizedBox(height: 20),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: submitting ? null : submitInspection,
              icon: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(submitting ? 'Submitting...' : 'SUBMIT INSPECTION'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INSPECTION CHECK CARD
// ============================================================

class InspectionCheckCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool completed;
  final String buttonText;
  final VoidCallback? onPressed;

  const InspectionCheckCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.completed,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: completed
                    ? const Color(0xFFE7F8EF)
                    : const Color(0xFFE8EDFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                completed ? Icons.check_rounded : icon,
                color: completed ? AppDesign.success : AppDesign.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppDesign.muted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            completed
                ? const StatusPill(label: 'VERIFIED', positive: true)
                : FilledButton(onPressed: onPressed, child: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ATTENDANCE CARD
// ============================================================

class AttendanceCard extends StatelessWidget {
  final int attendance;
  final bool checked;

  const AttendanceCard({
    super.key,
    required this.attendance,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    final lowAttendance = checked && attendance < 80;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDFF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: AppDesign.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Attendance Analytics',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                if (checked)
                  StatusPill(
                    label: '$attendance%',
                    positive: !lowAttendance,
                    warning: lowAttendance,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              checked
                  ? '$attendance% attendance detected'
                  : 'Attendance analysis not completed',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (checked) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 9,
                  value: attendance / 100,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                lowAttendance
                    ? 'Alert: Attendance is below 80%'
                    : 'Attendance is within acceptable range',
                style: TextStyle(
                  color: lowAttendance ? AppDesign.danger : AppDesign.success,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INSPECTION REPORT
// ============================================================

class InspectionReportScreen extends StatelessWidget {
  final InspectionReport report;

  const InspectionReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.verified, size: 70),
                  const SizedBox(height: 12),
                  const Text(
                    'Inspection Completed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(report.outcome),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          ReportRow(title: 'Project', value: report.projectName),

          ReportRow(title: 'Location', value: report.location),

          ReportRow(title: 'Date', value: report.inspectionDate),

          ReportRow(
            title: 'GPS',
            value: report.gpsVerified ? 'Verified' : 'Not Verified',
          ),

          ReportRow(
            title: 'Evidence',
            value: report.evidenceCaptured ? 'Captured' : 'Missing',
          ),

          ReportRow(
            title: 'CCTV',
            value: report.cctvVerified ? 'Verified' : 'Not Verified',
          ),

          ReportRow(
            title: 'Staff',
            value: report.staffVerified ? 'Verified' : 'Not Verified',
          ),

          ReportRow(title: 'Attendance', value: '${report.attendance}%'),

          ReportRow(title: 'AI Result', value: report.aiResult),

          ReportRow(title: 'Compliance', value: report.compliance),

          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('BACK'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REPORT ROW
// ============================================================

class ReportRow extends StatelessWidget {
  final String title;
  final String value;

  const ReportRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppDesign.muted,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CCTV SCREEN
// ============================================================
class CctvScreen extends StatefulWidget {
  final Project project;

  const CctvScreen({super.key, required this.project});

  @override
  State<CctvScreen> createState() => _CctvScreenState();
}

class _CctvScreenState extends State<CctvScreen> {
  VideoPlayerController? _videoController;

  bool connected = false;
  bool loading = false;

  // ----------------------------------------------------------
  // DEMO CCTV VIDEO
  // ----------------------------------------------------------
  //
  // This is a test video.
  //
  // Later we can replace this with your authorized CCTV stream.
  //
  static const String demoVideoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  // ----------------------------------------------------------
  // CONNECT CCTV
  // ----------------------------------------------------------

  Future<void> connectCctv() async {
    setState(() {
      loading = true;
    });

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(demoVideoUrl),
      );

      await controller.initialize();

      await controller.setLooping(true);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        connected = true;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        connected = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('CCTV connection failed: $e')));
    }
  }

  // ----------------------------------------------------------
  // DISCONNECT CCTV
  // ----------------------------------------------------------

  Future<void> disconnectCctv() async {
    await _videoController?.pause();
    await _videoController?.dispose();

    if (!mounted) return;

    setState(() {
      _videoController = null;
      connected = false;
    });
  }

  // ----------------------------------------------------------
  // CLEAN UP
  // ----------------------------------------------------------

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;

    return Scaffold(
      appBar: AppBar(title: const Text('CCTV Monitoring'), centerTitle: true),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================================================
          // PROJECT INFORMATION
          // ==================================================

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.project.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 5),
                      Text(widget.project.location),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ==================================================
          // CCTV VIDEO
          // ==================================================
          Card(
            clipBehavior: Clip.antiAlias,
            child: Container(
              width: double.infinity,
              height: 230,
              color: Colors.black,

              child:
                  !connected ||
                      controller == null ||
                      !controller.value.isInitialized
                  // ------------------------------------------
                  // DISCONNECTED SCREEN
                  // ------------------------------------------
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          loading ? Icons.sync : Icons.videocam_off,
                          color: Colors.white,
                          size: 55,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          loading
                              ? 'CONNECTING TO CCTV...'
                              : 'CCTV DISCONNECTED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  // ------------------------------------------
                  // VIDEO SCREEN
                  // ------------------------------------------
                  : Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Center(
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                        ),

                        // LIVE INDICATOR
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.white,
                                  size: 9,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // VIDEO CONTROLS
                        VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                          padding: const EdgeInsets.all(8),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 15),

          // ==================================================
          // CCTV STATUS
          // ==================================================
          Card(
            child: ListTile(
              leading: Icon(
                connected ? Icons.check_circle : Icons.error_outline,
              ),

              title: Text(
                connected ? 'CCTV Connected' : 'CCTV Disconnected',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Text(
                connected
                    ? 'Live monitoring stream is active'
                    : 'No CCTV stream connected',
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ==================================================
          // CONNECT / DISCONNECT BUTTON
          // ==================================================
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: loading
                  ? null
                  : connected
                  ? disconnectCctv
                  : connectCctv,

              icon: Icon(connected ? Icons.stop_circle : Icons.play_circle),

              label: Text(
                connected
                    ? 'DISCONNECT CCTV'
                    : loading
                    ? 'CONNECTING...'
                    : 'CONNECT CCTV',
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ==================================================
          // CCTV INFORMATION
          // ==================================================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CCTV Monitoring',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  const Text('Current mode: Demonstration CCTV stream'),

                  const SizedBox(height: 12),

                  const Text(
                    'Production architecture:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'CCTV Camera → DVR/NVR → Secure Streaming Gateway → FastAPI → Flutter',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// VIDEO CONFERENCE
// ============================================================

class VideoConferenceScreen extends StatefulWidget {
  final Project project;

  const VideoConferenceScreen({super.key, required this.project});

  @override
  State<VideoConferenceScreen> createState() => _VideoConferenceScreenState();
}

class _VideoConferenceScreenState extends State<VideoConferenceScreen> {
  bool connected = false;
  String participant = '';

  Future<void> connect() async {
    setState(() {
      connected = true;
      participant = 'Project Incharge';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connecting to stakeholder...')),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Video conference connected')));
  }

  void disconnect() {
    setState(() {
      connected = false;
      participant = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Conference')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Container(
                width: double.infinity,
                height: 300,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      connected ? Icons.video_call : Icons.video_call_outlined,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      connected ? 'CONNECTED' : 'NOT CONNECTED',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (connected) ...[
                      const SizedBox(height: 10),
                      Text(participant, style: const TextStyle(fontSize: 17)),
                    ],
                    const SizedBox(height: 8),
                    Text(widget.project.name),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: connected ? disconnect : connect,
                icon: Icon(connected ? Icons.call_end : Icons.video_call),
                label: Text(connected ? 'END CALL' : 'START VIDEO CALL'),
              ),
            ),

            const SizedBox(height: 20),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Production deployment can integrate WebRTC, '
                  'Jitsi or an approved government video '
                  'conference infrastructure.',
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
// ALERTS SCREEN
// ============================================================

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: AppState.alerts.isEmpty
          ? const Center(child: Text('No alerts'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: AppState.alerts.length,
              itemBuilder: (context, index) {
                final alert = AppState.alerts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.warning)),
                    title: Text(
                      alert.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${alert.message}\n${alert.time}'),
                    isThreeLine: true,
                    trailing: Chip(label: Text(alert.severity)),
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================
// REPORTS SCREEN
// ============================================================

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection Reports')),
      body: AppState.reports.isEmpty
          ? const Center(child: Text('No inspection reports'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: AppState.reports.length,
              itemBuilder: (context, index) {
                final report = AppState.reports[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.description)),
                    title: Text(
                      report.projectName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${report.inspectionDate}\n'
                      'Attendance: ${report.attendance}%\n'
                      '${report.compliance}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              InspectionReportScreen(report: report),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(radius: 45, child: Icon(Icons.person, size: 50)),
                  SizedBox(height: 16),
                  Text(
                    'Inspection Officer',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text('DoSJE SmartInspectAI'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.account_balance),
                  title: Text('Department'),
                  subtitle: Text('Department of Social Justice & Empowerment'),
                ),
                ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Role'),
                  subtitle: Text('Inspection Officer'),
                ),
                ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Platform'),
                  subtitle: Text('Smart Monitoring and AI Analytics'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT'),
            ),
          ),
        ],
      ),
    );
  }
}
