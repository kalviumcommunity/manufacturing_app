import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/machine_card.dart';
import '../widgets/machine_status_summary_card.dart';
import 'add_machine_screen.dart';

class AllMachinesScreen extends StatefulWidget {
  final String? statusFilter;

  const AllMachinesScreen({super.key, this.statusFilter});

  @override
  State<AllMachinesScreen> createState() => _AllMachinesScreenState();
}

class _AllMachinesScreenState extends State<AllMachinesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.statusFilter ?? 'All';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setFilter(String filter) {
    setState(() {
      _currentFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Machines'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddMachineScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Machine'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('machines').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load machines: ${snapshot.error}',
                style: const TextStyle(color: AppColors.breakdown),
              ),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          // Compute counts
          final totalCount = allDocs.length;
          final runningCount = allDocs.where((d) => (d.data()['status'] ?? '') == 'Running').length;
          final breakdownCount = allDocs.where((d) => (d.data()['status'] ?? '') == 'Breakdown').length;
          final maintenanceCount = allDocs.where((d) => (d.data()['status'] ?? '') == 'Maintenance').length;

          // Filter by status
          var filteredList = allDocs.where((d) {
            if (_currentFilter == 'All') return true;
            return (d.data()['status'] ?? '') == _currentFilter;
          }).toList();

          // Filter by search query
          if (_searchQuery.isNotEmpty) {
            filteredList = filteredList.where((d) {
              final data = d.data();
              final name = (data['machineName'] ?? '').toString().toLowerCase();
              final id = (data['machineId'] ?? '').toString().toLowerCase();
              final line = (data['lineName'] ?? '').toString().toLowerCase();
              return name.contains(_searchQuery) ||
                  id.contains(_searchQuery) ||
                  line.contains(_searchQuery);
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
                      'All Machines',
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 22 : 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Live telemetry and operational status across all lines',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                    ),
                    const SizedBox(height: 20),

                    // RESPONSIVE SUMMARY CARDS
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 640;

                        final totalCard = MachineStatusSummaryCard(
                          title: 'Total',
                          value: totalCount.toString(),
                          icon: Icons.precision_manufacturing_rounded,
                          color: AppColors.accent,
                          isSelected: _currentFilter == 'All',
                          onTap: () => _setFilter('All'),
                        );

                        final runningCard = MachineStatusSummaryCard(
                          title: 'Running',
                          value: runningCount.toString(),
                          icon: Icons.play_circle_rounded,
                          color: AppColors.running,
                          isSelected: _currentFilter == 'Running',
                          onTap: () => _setFilter('Running'),
                        );

                        final breakdownCard = MachineStatusSummaryCard(
                          title: 'Breakdown',
                          value: breakdownCount.toString(),
                          icon: Icons.warning_rounded,
                          color: AppColors.breakdown,
                          isSelected: _currentFilter == 'Breakdown',
                          onTap: () => _setFilter('Breakdown'),
                        );

                        final maintenanceCard = MachineStatusSummaryCard(
                          title: 'Maintenance',
                          value: maintenanceCount.toString(),
                          icon: Icons.build_rounded,
                          color: AppColors.maintenance,
                          isSelected: _currentFilter == 'Maintenance',
                          onTap: () => _setFilter('Maintenance'),
                        );

                        if (isNarrow) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: totalCard),
                                  const SizedBox(width: 10),
                                  Expanded(child: runningCard),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: breakdownCard),
                                  const SizedBox(width: 10),
                                  Expanded(child: maintenanceCard),
                                ],
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: totalCard),
                            const SizedBox(width: 12),
                            Expanded(child: runningCard),
                            const SizedBox(width: 12),
                            Expanded(child: breakdownCard),
                            const SizedBox(width: 12),
                            Expanded(child: maintenanceCard),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // SEARCH BAR & INTERACTIVE FILTER CHIPS
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
                              hintText: 'Search by machine name, ID, or line...',
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
                          // Filter Pills
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _StatusFilterChip(
                                  label: 'All',
                                  count: totalCount,
                                  color: AppColors.textPrimary,
                                  isSelected: _currentFilter == 'All',
                                  onTap: () => _setFilter('All'),
                                ),
                                const SizedBox(width: 8),
                                _StatusFilterChip(
                                  label: 'Running',
                                  count: runningCount,
                                  color: AppColors.running,
                                  isSelected: _currentFilter == 'Running',
                                  onTap: () => _setFilter('Running'),
                                ),
                                const SizedBox(width: 8),
                                _StatusFilterChip(
                                  label: 'Breakdown',
                                  count: breakdownCount,
                                  color: AppColors.breakdown,
                                  isSelected: _currentFilter == 'Breakdown',
                                  onTap: () => _setFilter('Breakdown'),
                                ),
                                const SizedBox(width: 8),
                                _StatusFilterChip(
                                  label: 'Maintenance',
                                  count: maintenanceCount,
                                  color: AppColors.maintenance,
                                  isSelected: _currentFilter == 'Maintenance',
                                  onTap: () => _setFilter('Maintenance'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // MACHINES LIST OR GRID
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
                              Icons.search_off_rounded,
                              size: 40,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No machines matching "$_searchQuery"'
                                  : 'No machines with status "$_currentFilter"',
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _currentFilter = 'All';
                                });
                              },
                              child: const Text('Reset Filters'),
                            ),
                          ],
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 1050
                              ? 3
                              : constraints.maxWidth >= 680
                                  ? 2
                                  : 1;

                          final children = filteredList.map((doc) {
                            final data = doc.data();
                            final machineId = data['machineId'] ?? doc.id;
                            final machineName = data['machineName'] ?? 'Unknown Machine';
                            final lineName = data['lineName'] ?? 'Unknown Line';
                            final status = data['status'] ?? 'Unknown';
                            final statusColor = AppColors.getStatusColor(status);

                            return MachineCard(
                              machineId: machineId,
                              machineName: machineName,
                              lineName: lineName,
                              status: status,
                              statusColor: statusColor,
                            );
                          }).toList();

                          if (columns == 1) {
                            return Column(
                              children: children
                                  .map((c) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: c,
                                      ))
                                  .toList(),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 84,
                            ),
                            itemCount: children.length,
                            itemBuilder: (context, index) => children[index],
                          );
                        },
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

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusFilterChip({
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
