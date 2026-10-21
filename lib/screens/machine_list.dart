import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/machine_card.dart';

class MachineListScreen extends StatefulWidget {
  final String lineName;

  const MachineListScreen({super.key, required this.lineName});

  @override
  State<MachineListScreen> createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<MachineListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.lineName),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('machines')
            .where('lineName', isEqualTo: widget.lineName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load line machines: ${snapshot.error}',
                style: const TextStyle(color: AppColors.breakdown),
              ),
            );
          }

          final allMachines = snapshot.data?.docs ?? [];

          final runningCount = allMachines.where((m) => (m.data()['status'] ?? '') == 'Running').length;
          final breakdownCount = allMachines.where((m) => (m.data()['status'] ?? '') == 'Breakdown').length;

          var filteredList = allMachines;
          if (_searchQuery.isNotEmpty) {
            filteredList = filteredList.where((m) {
              final data = m.data();
              final name = (data['machineName'] ?? '').toString().toLowerCase();
              final id = (data['machineId'] ?? '').toString().toLowerCase();
              return name.contains(_searchQuery) || id.contains(_searchQuery);
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
                    // LINE HEADER & COUNTS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lineName,
                                style: TextStyle(
                                  fontSize: Responsive.isMobile(context) ? 22 : 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${allMachines.length} registered units • $runningCount running • $breakdownCount breakdown',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // SEARCH
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search machines in this line...',
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
                      ),
                    ),
                    const SizedBox(height: 20),

                    // EMPTY STATE OR GRID
                    if (filteredList.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(36),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            _searchQuery.isNotEmpty
                                ? 'No machines matching "$_searchQuery"'
                                : 'No machines found for this production line.',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 900
                              ? 3
                              : constraints.maxWidth >= 600
                                  ? 2
                                  : 1;

                          final children = filteredList.map((doc) {
                            final data = doc.data();
                            final machineId = data['machineId'] ?? doc.id;
                            final machineName = data['machineName'] ?? 'Unknown Machine';
                            final status = data['status'] ?? 'Unknown';
                            final statusColor = AppColors.getStatusColor(status);

                            return MachineCard(
                              machineId: machineId,
                              machineName: machineName,
                              lineName: widget.lineName,
                              status: status,
                              statusColor: statusColor,
                            );
                          }).toList();

                          if (columns == 1) {
                            return Column(
                              children: children
                                  .map((c) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
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
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
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
