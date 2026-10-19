import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/breakdown_card.dart';
import '../widgets/breakdown_summary_card.dart';
import 'machine_details.dart';

class AllBreakdownsScreen extends StatefulWidget {
  final String? severityFilter;

  const AllBreakdownsScreen({super.key, this.severityFilter});

  @override
  State<AllBreakdownsScreen> createState() => _AllBreakdownsScreenState();
}

class _AllBreakdownsScreenState extends State<AllBreakdownsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _currentSeverity;

  @override
  void initState() {
    super.initState();
    _currentSeverity = widget.severityFilter ?? 'All';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setSeverity(String sev) {
    setState(() {
      _currentSeverity = sev;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Breakdowns & Alerts'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('breakdowns')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load breakdowns: ${snapshot.error}',
                style: const TextStyle(color: AppColors.breakdown),
              ),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          // Counts
          final totalCount = allDocs.length;
          final criticalCount = allDocs.where((d) => (d.data()['severity'] ?? '') == 'Critical').length;
          final highCount = allDocs.where((d) => (d.data()['severity'] ?? '') == 'High').length;
          final mediumCount = allDocs.where((d) => (d.data()['severity'] ?? '') == 'Medium').length;
          final lowCount = allDocs.where((d) => (d.data()['severity'] ?? '') == 'Low').length;

          // Filter by severity
          var filteredList = allDocs.where((d) {
            if (_currentSeverity == 'All') return true;
            return (d.data()['severity'] ?? '') == _currentSeverity;
          }).toList();

          // Filter by search query
          if (_searchQuery.isNotEmpty) {
            filteredList = filteredList.where((d) {
              final data = d.data();
              final machine = (data['machineName'] ?? '').toString().toLowerCase();
              final id = (data['machineId'] ?? '').toString().toLowerCase();
              final line = (data['lineName'] ?? '').toString().toLowerCase();
              final desc = (data['description'] ?? '').toString().toLowerCase();
              final reporter = (data['reportedBy'] ?? '').toString().toLowerCase();
              return machine.contains(_searchQuery) ||
                  id.contains(_searchQuery) ||
                  line.contains(_searchQuery) ||
                  desc.contains(_searchQuery) ||
                  reporter.contains(_searchQuery);
            }).toList();
          }

          return SingleChildScrollView(
            padding: Responsive.pagePadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PAGE HEADER
                    Text(
                      'Breakdown Incident Log',
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 22 : 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Live incident log, severity metrics, and historical logs',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                    ),
                    const SizedBox(height: 20),

                    // RESPONSIVE SUMMARY CARDS
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final columns = width >= 900
                            ? 5
                            : width >= 540
                                ? 3
                                : 2;

                        const spacing = 10.0;
                        final cardWidth =
                            (width - spacing * (columns - 1)) / columns;

                        final cards = [
                          BreakdownSummaryCard(
                            title: 'Total',
                            value: totalCount.toString(),
                            icon: Icons.warning_amber_rounded,
                            color: AppColors.accent,
                            isSelected: _currentSeverity == 'All',
                            onTap: () => _setSeverity('All'),
                          ),
                          BreakdownSummaryCard(
                            title: 'Critical',
                            value: criticalCount.toString(),
                            icon: Icons.error_outline_rounded,
                            color: AppColors.critical,
                            isSelected: _currentSeverity == 'Critical',
                            onTap: () => _setSeverity('Critical'),
                          ),
                          BreakdownSummaryCard(
                            title: 'High',
                            value: highCount.toString(),
                            icon: Icons.priority_high_rounded,
                            color: AppColors.high,
                            isSelected: _currentSeverity == 'High',
                            onTap: () => _setSeverity('High'),
                          ),
                          BreakdownSummaryCard(
                            title: 'Medium',
                            value: mediumCount.toString(),
                            icon: Icons.warning_rounded,
                            color: AppColors.medium,
                            isSelected: _currentSeverity == 'Medium',
                            onTap: () => _setSeverity('Medium'),
                          ),
                          BreakdownSummaryCard(
                            title: 'Low',
                            value: lowCount.toString(),
                            icon: Icons.info_outline_rounded,
                            color: AppColors.low,
                            isSelected: _currentSeverity == 'Low',
                            onTap: () => _setSeverity('Low'),
                          ),
                        ];

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: cards
                              .map((c) => SizedBox(width: cardWidth, child: c))
                              .toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // SEARCH & SEVERITY FILTER BAR
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim().toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search by machine, line, reporter, or issue...',
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                              suffixIcon: _searchQuery.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _SeverityFilterChip(
                                  label: 'All Severities',
                                  count: totalCount,
                                  color: AppColors.textPrimary,
                                  isSelected: _currentSeverity == 'All',
                                  onTap: () => _setSeverity('All'),
                                ),
                                const SizedBox(width: 8),
                                _SeverityFilterChip(
                                  label: 'Critical',
                                  count: criticalCount,
                                  color: AppColors.critical,
                                  isSelected: _currentSeverity == 'Critical',
                                  onTap: () => _setSeverity('Critical'),
                                ),
                                const SizedBox(width: 8),
                                _SeverityFilterChip(
                                  label: 'High',
                                  count: highCount,
                                  color: AppColors.high,
                                  isSelected: _currentSeverity == 'High',
                                  onTap: () => _setSeverity('High'),
                                ),
                                const SizedBox(width: 8),
                                _SeverityFilterChip(
                                  label: 'Medium',
                                  count: mediumCount,
                                  color: AppColors.medium,
                                  isSelected: _currentSeverity == 'Medium',
                                  onTap: () => _setSeverity('Medium'),
                                ),
                                const SizedBox(width: 8),
                                _SeverityFilterChip(
                                  label: 'Low',
                                  count: lowCount,
                                  color: AppColors.low,
                                  isSelected: _currentSeverity == 'Low',
                                  onTap: () => _setSeverity('Low'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LIST OF BREAKDOWNS
                    if (filteredList.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 40,
                              color: AppColors.running,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No breakdowns matching "$_searchQuery"'
                                  : 'No incidents with severity "$_currentSeverity"',
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Machines in this scope are operating normally.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: filteredList.map((doc) {
                          final data = doc.data();
                          final timestamp = data['timestamp'];
                          String reportedTime = 'Recent';

                          if (timestamp is Timestamp) {
                            final date = timestamp.toDate();
                            reportedTime =
                                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
                                '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                          }

                          final machineId = data['machineId'] as String? ?? '';
                          final machineName = data['machineName'] ?? 'Unknown Machine';
                          final lineName = data['lineName'] ?? 'Unknown Line';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: BreakdownCard(
                              machine: machineName,
                              line: lineName,
                              issue: data['description'] ?? 'No description provided.',
                              time: reportedTime,
                              severity: data['severity'] ?? 'Medium',
                              reportedBy: data['reportedBy'],
                              onTap: machineId.isNotEmpty
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MachineDetailsScreen(
                                            machineId: machineId,
                                            machineName: machineName,
                                            lineName: lineName,
                                            status: 'Breakdown',
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SeverityFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeverityFilterChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.18) : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.25)
                      : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? color : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
