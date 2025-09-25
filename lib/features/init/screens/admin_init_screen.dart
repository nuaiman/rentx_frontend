import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../notifiers/admin_init_notifier.dart';

class AdminInitScreen extends ConsumerWidget {
  const AdminInitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(adminInitProvider);

    return initState.when(
      data: (_) {
        // All initial fetches done — can proceed to AdminScreen
        return const AdminDashboardScreen();
      },
      error: (e, st) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // retry
                  ref.invalidate(adminInitProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      loading: () => Skeletonizer(
        enabled: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text(
              'Admin Dashboard',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Align(
            alignment: AlignmentGeometry.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Cards
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: const [
                        DashboardCard(
                          title: 'Pending Posts',
                          value: '20',
                          icon: Icons.post_add,
                          iconColor: Colors.black,
                        ),
                        DashboardCard(
                          title: 'Categories',
                          value: '24',
                          icon: Icons.category_outlined,
                          iconColor: Colors.black,
                        ),
                        DashboardCard(
                          title: 'Users',
                          value: '17',
                          icon: Icons.person_outline,
                          iconColor: Colors.black,
                        ),
                        DashboardCard(
                          title: 'Reports',
                          value: '3',
                          icon: Icons.report,
                          iconColor: Colors.redAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: const [
                          DashboardTab(text: 'MEMBER FIRMS', isSelected: true),
                          DashboardTab(text: 'USERS'),
                          DashboardTab(text: 'CONTRACTORS'),
                          DashboardTab(text: 'ORGANISATIONS'),
                          DashboardTab(text: 'OTHER'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Table Content (Responsive)
                    Column(
                      children: const [
                        MemberRow(
                          companyName: 'Nanites',
                          companyStatus: 'Premium Company',
                          computingType: 'Cloud GPU',
                          computingStatus: 'Nvidia Cluster - \$90/mo',
                          utilization: 0.54,
                          lastSeen: 'Just Now',
                        ),
                        MemberRow(
                          companyName: 'YD Networks',
                          companyStatus: 'Regular Company',
                          computingType: 'Kubernetes',
                          computingStatus: 'Load Balancer - \$33/mo',
                          utilization: 0.89,
                          lastSeen: 'Today',
                        ),
                        MemberRow(
                          companyName: 'Qascade',
                          companyStatus: 'Premium Company',
                          computingType: 'Storage',
                          computingStatus: 'Network-Based Storage - \$25/mo',
                          utilization: 0.26,
                          lastSeen: 'Yesterday',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================= Reusable Widgets =======================
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final Color iconColor;
  final IconData icon;

  const DashboardCard({
    required this.title,
    required this.value,
    required this.iconColor,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final String text;
  final bool isSelected;

  const DashboardTab({required this.text, this.isSelected = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontSize: 12,
        ),
      ),
    );
  }
}

class MemberRow extends StatelessWidget {
  final String companyName;
  final String companyStatus;
  final String computingType;
  final String computingStatus;
  final double utilization;
  final String lastSeen;

  const MemberRow({
    required this.companyName,
    required this.companyStatus,
    required this.computingType,
    required this.computingStatus,
    required this.utilization,
    required this.lastSeen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  companyStatus,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  computingType,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  computingStatus,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: CustomProgressBar(utilization: utilization)),
          Expanded(
            flex: 1,
            child: Text(
              lastSeen,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomProgressBar extends StatelessWidget {
  final double utilization;
  const CustomProgressBar({required this.utilization, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: utilization,
        minHeight: 6,
        backgroundColor: Colors.grey[300],
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
      ),
    );
  }
}
