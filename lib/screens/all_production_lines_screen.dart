import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/breakdown_summary_card.dart';
import '../widgets/production_line_card.dart';

class AllProductionLinesScreen extends StatefulWidget {
  final String? statusFilter;

  const AllProductionLinesScreen({super.key, this.statusFilter});

  @override
  State<AllProductionLinesScreen> createState() => _AllProductionLinesScreenState();
}

class _LineInfo {
  final String name;
  final int machineCount;
  final int runningCount;
  final int breakdownCount;
  final int maintenanceCount;
  final String status;
  final Color statusColor;

  const _LineInfo({
    required this.name,
    required this.machineCount,
    required this.runningCount,
    required this.breakdownCount,
    required this.maintenanceCount,
    required this.status,
    required this.statusColor,
  });
}

class _AllProductionLinesScreenState extends State<AllProductionLinesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _currentStatus;
  bool _glideForward = true;

  int _getStatusIndex(String status) {
    switch (status) {
      case 'All':
        return 0;
      case 'Running':
        return 1;
      case 'Maintenance':
        return 2;
      case 'Breakdown':
        return 3;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.statusFilter ?? 'All';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setStatus(String status) {
    if (_currentStatus == status) return;
    final newIndex = _getStatusIndex(status);
    final oldIndex = _getStatusIndex(_currentStatus);
    setState(() {
      _glideForward = newIndex >= oldIndex;
      _currentStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Production Lines'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('machines').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.breakdown),
                    const SizedBox(height: 12),
                    const Text(
                      'Failed to load production lines',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.breakdown),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          final machines = snapshot.data?.docs ?? [];

          // Group machines by production line
          final Map<String, List<Map<String, dynamic>>> lineGroups = {};
          for (final doc in machines) {
            final data = doc.data();
            final line = (data['lineName'] ?? data['line'] ?? 'Main Floor').toString().trim();
            final safeLine = line.isEmpty ? 'Main Floor' : line;
            lineGroups.putIfAbsent(safeLine, () => []).add(data);
          }

          // Build line metrics
          final List<_LineInfo> allLines = [];
          for (final entry in lineGroups.entries) {
            final lineName = entry.key;
            final lineMachines = entry.value;
            final total = lineMachines.length;
            final running = lineMachines.where((m) => (m['status'] ?? '') == 'Running').length;
            final breakdown = lineMachines.where((m) => (m['status'] ?? '') == 'Breakdown').length;
            final maintenance = lineMachines.where((m) {
              final s = (m['status'] ?? '').toString();
              return s == 'Maintenance' || s == 'Idle';
            }).length;

            String status = 'Running';
            Color statusColor = AppColors.running;
            if (breakdown > 0) {
              status = 'Breakdown';
              statusColor = AppColors.breakdown;
            } else if (maintenance > 0) {
              status = 'Maintenance';
              statusColor = AppColors.maintenance;
            }

            allLines.add(_LineInfo(
              name: lineName,
              machineCount: total,
              runningCount: running,
              breakdownCount: breakdown,
              maintenanceCount: maintenance,
              status: status,
              statusColor: statusColor,
            ));
          }

          // Sort lines alphabetically
          allLines.sort((a, b) => a.name.compareTo(b.name));

          // Compute status counts
          final totalLinesCount = allLines.length;
          final runningLinesCount = allLines.where((l) => l.status == 'Running').length;
          final maintenanceLinesCount = allLines.where((l) => l.status == 'Maintenance').length;
          final breakdownLinesCount = allLines.where((l) => l.status == 'Breakdown').length;

          // Filter by status
          var filteredLines = allLines.where((l) {
            if (_currentStatus == 'All') return true;
            return l.status == _currentStatus;
          }).toList();

          // Filter by search query
          if (_searchQuery.isNotEmpty) {
            filteredLines = filteredLines.where((l) {
              return l.name.toLowerCase().contains(_searchQuery);
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
                      'Production Lines & Cells',
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 22 : 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Real-time line capacity, active work cells, and operational throughput across production hubs.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SUMMARY CARDS GRID
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final columns = width >= 900 ? 4 : (width >= 540 ? 2 : 2);
                        const spacing = 10.0;
                        final cardWidth = (width - spacing * (columns - 1)) / columns;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: BreakdownSummaryCard(
                                title: 'Total Lines',
                                value: totalLinesCount.toString(),
                                icon: Icons.alt_route_rounded,
                                color: AppColors.primary,
                                isSelected: _currentStatus == 'All',
                                onTap: () => _setStatus('All'),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: BreakdownSummaryCard(
                                title: 'Running',
                                value: runningLinesCount.toString(),
                                icon: Icons.check_circle_rounded,
                                color: AppColors.running,
                                isSelected: _currentStatus == 'Running',
                                onTap: () => _setStatus('Running'),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: BreakdownSummaryCard(
                                title: 'Maintenance',
                                value: maintenanceLinesCount.toString(),
                                icon: Icons.warning_amber_rounded,
                                color: AppColors.maintenance,
                                isSelected: _currentStatus == 'Maintenance',
                                onTap: () => _setStatus('Maintenance'),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: BreakdownSummaryCard(
                                title: 'Breakdown',
                                value: breakdownLinesCount.toString(),
                                icon: Icons.cancel_rounded,
                                color: AppColors.breakdown,
                                isSelected: _currentStatus == 'Breakdown',
                                onTap: () => _setStatus('Breakdown'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // SEARCH BAR
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val.trim().toLowerCase();
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search production line or cell name...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // RESULTS HEADER & ACTIVE FILTER STATUS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ACTIVE PRODUCTION HUBS (${filteredLines.length})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (_currentStatus != 'All' || _searchQuery.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _currentStatus = 'All';
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 14),
                            label: const Text('Reset filters', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // DIRECTIONAL GLIDING LINES LIST
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final inOffset = Tween<Offset>(
                          begin: Offset(_glideForward ? 0.07 : -0.07, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ));
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: inOffset,
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey('lines-view-$_currentStatus-$_searchQuery'),
                        child: filteredLines.isEmpty
                            ? Container(
                                key: const ValueKey('empty-lines'),
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
                                      Icons.alt_route_rounded,
                                      size: 40,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'No production lines matching "$_searchQuery"'
                                          : 'No production lines with status "$_currentStatus"',
                                      style: const TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Production lines are created when machinery is assigned to a line.',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredLines.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final line = filteredLines[index];
                                  return ProductionLineCard(
                                    lineName: line.name,
                                    machineCount: line.machineCount,
                                    status: line.status,
                                    statusColor: line.statusColor,
                                  );
                                },
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),
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
