import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dtc_list_widget.dart';
import '../widgets/live_data_widget.dart';
import '../widgets/diagnostic_actions_widget.dart';

class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.error_outline),
              text: 'Trouble Codes',
            ),
            Tab(
              icon: Icon(Icons.show_chart),
              text: 'Live Data',
            ),
            Tab(
              icon: Icon(Icons.build),
              text: 'Actions',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DTCListWidget(),
          LiveDataWidget(),
          DiagnosticActionsWidget(),
        ],
      ),
    );
  }
}