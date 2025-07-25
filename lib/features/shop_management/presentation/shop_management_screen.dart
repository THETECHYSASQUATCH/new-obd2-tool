import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../shared/widgets/responsive_layout.dart';
import '../models/customer.dart';
import '../models/work_order.dart';
import '../models/inventory_item.dart';

class ShopManagementScreen extends ConsumerStatefulWidget {
  const ShopManagementScreen({super.key});

  @override
  ConsumerState<ShopManagementScreen> createState() => _ShopManagementScreenState();
}

class _ShopManagementScreenState extends ConsumerState<ShopManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(),
      tabletBody: _buildTabletLayout(),
      desktopBody: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Customers'),
            Tab(icon: Icon(Icons.work), text: 'Work Orders'),
            Tab(icon: Icon(Icons.inventory), text: 'Inventory'),
          ],
        ),
      ),
      body: _buildTabView(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Customers'),
            Tab(icon: Icon(Icons.work), text: 'Work Orders'),
            Tab(icon: Icon(Icons.inventory), text: 'Inventory'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildTabView(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          const SizedBox(width: 200, child: _NavigationSidebar()),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: const Text('Professional Shop Management'),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                      Tab(icon: Icon(Icons.people), text: 'Customers'),
                      Tab(icon: Icon(Icons.work), text: 'Work Orders'),
                      Tab(icon: Icon(Icons.inventory), text: 'Inventory'),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildTabView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildCustomersTab(),
        _buildWorkOrdersTab(),
        _buildInventoryTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop Overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildMetricsCards(),
          const SizedBox(height: 24),
          _buildRecentActivityCard(),
          const SizedBox(height: 24),
          _buildQuickActionsCard(),
        ],
      ),
    );
  }

  Widget _buildMetricsCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Active Work Orders',
          '12',
          Icons.work,
          Colors.blue,
          '+3 today',
        ),
        _buildMetricCard(
          'Total Customers',
          '248',
          Icons.people,
          Colors.green,
          '+5 this week',
        ),
        _buildMetricCard(
          'Monthly Revenue',
          '\$18,542',
          Icons.attach_money,
          Colors.orange,
          '+12% vs last month',
        ),
        _buildMetricCard(
          'Low Stock Items',
          '7',
          Icons.inventory,
          Colors.red,
          'Need reorder',
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              'Work Order #1234 completed',
              '2024 Honda Civic - Oil change',
              '10 minutes ago',
              Icons.check_circle,
              Colors.green,
            ),
            _buildActivityItem(
              'New customer added',
              'John Smith - (555) 123-4567',
              '1 hour ago',
              Icons.person_add,
              Colors.blue,
            ),
            _buildActivityItem(
              'Inventory alert',
              'Oil filters running low (3 remaining)',
              '2 hours ago',
              Icons.warning,
              Colors.orange,
            ),
            _buildActivityItem(
              'Invoice sent',
              'Invoice #INV-2024-0156 - \$245.50',
              '3 hours ago',
              Icons.receipt,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionButton(
                  'New Work Order',
                  Icons.add_business,
                  Colors.blue,
                  () => _showNewWorkOrderDialog(),
                ),
                _buildQuickActionButton(
                  'Add Customer',
                  Icons.person_add,
                  Colors.green,
                  () => _showNewCustomerDialog(),
                ),
                _buildQuickActionButton(
                  'Create Invoice',
                  Icons.receipt_long,
                  Colors.orange,
                  () => _showCreateInvoiceDialog(),
                ),
                _buildQuickActionButton(
                  'Check Inventory',
                  Icons.inventory_2,
                  Colors.purple,
                  () => _tabController.animateTo(3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildCustomersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Customer Management',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ElevatedButton.icon(
              onPressed: () => _showNewCustomerDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Customer'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildCustomersList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomersList() {
    return ListView.builder(
      itemCount: 10, // Mock data
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: Text('${index + 1}'),
          ),
          title: Text('Customer ${index + 1}'),
          subtitle: Text('customer${index + 1}@example.com'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditCustomerDialog(),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
          onTap: () => _showCustomerDetails(),
        );
      },
    );
  }

  Widget _buildWorkOrdersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Work Orders',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ElevatedButton.icon(
              onPressed: () => _showNewWorkOrderDialog(),
              icon: const Icon(Icons.add),
              label: const Text('New Work Order'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildWorkOrdersList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkOrdersList() {
    return ListView.builder(
      itemCount: 8, // Mock data
      itemBuilder: (context, index) {
        final statuses = [WorkOrderStatus.pending, WorkOrderStatus.inProgress, WorkOrderStatus.completed];
        final status = statuses[index % statuses.length];
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(
              status == WorkOrderStatus.completed ? Icons.check_circle :
              status == WorkOrderStatus.inProgress ? Icons.work : Icons.schedule,
              color: status == WorkOrderStatus.completed ? Colors.green :
                     status == WorkOrderStatus.inProgress ? Colors.orange : Colors.blue,
            ),
            title: Text('Work Order #WO-${1000 + index}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('2024 Honda Civic - Oil Change'),
                Text('Customer: John Doe'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Chip(
                  label: Text(status.name.toUpperCase()),
                  backgroundColor: (status == WorkOrderStatus.completed ? Colors.green :
                                   status == WorkOrderStatus.inProgress ? Colors.orange : Colors.blue)
                                   .withOpacity(0.1),
                ),
                Text('\$${150 + (index * 25)}'),
              ],
            ),
            onTap: () => _showWorkOrderDetails(),
          ),
        );
      },
    );
  }

  Widget _buildInventoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Inventory Management',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddInventoryDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildInventoryList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryList() {
    return ListView.builder(
      itemCount: 15, // Mock data
      itemBuilder: (context, index) {
        final quantities = [25, 3, 45, 8, 0, 12, 2, 67, 5, 34, 1, 89, 15, 7, 23];
        final quantity = quantities[index % quantities.length];
        final isLowStock = quantity <= 5;
        
        return ListTile(
          leading: Icon(
            isLowStock ? Icons.warning : Icons.inventory_2,
            color: isLowStock ? Colors.red : Colors.green,
          ),
          title: Text('Part ${index + 1} - ${_getPartName(index)}'),
          subtitle: Text('SKU: P${1000 + index}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Qty: $quantity',
                style: TextStyle(
                  color: isLowStock ? Colors.red : null,
                  fontWeight: isLowStock ? FontWeight.bold : null,
                ),
              ),
              Text('\$${(15.99 + index * 2.5).toStringAsFixed(2)}'),
            ],
          ),
          onTap: () => _showInventoryItemDetails(),
        );
      },
    );
  }

  String _getPartName(int index) {
    final parts = [
      'Oil Filter', 'Air Filter', 'Brake Pads', 'Spark Plugs', 'Fuel Filter',
      'Cabin Filter', 'Brake Fluid', 'Transmission Fluid', 'Coolant', 'Power Steering Fluid',
      'Windshield Wipers', 'Battery', 'Alternator', 'Starter', 'Timing Belt'
    ];
    return parts[index % parts.length];
  }

  void _showNewWorkOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Work Order'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Customer Name'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Vehicle'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Service Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showNewCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Customer'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCreateInvoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Invoice'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Work Order ID'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog() {
    // Implementation for editing customer
  }

  void _showCustomerDetails() {
    // Implementation for showing customer details
  }

  void _showWorkOrderDetails() {
    // Implementation for showing work order details
  }

  void _showAddInventoryDialog() {
    // Implementation for adding inventory item
  }

  void _showInventoryItemDetails() {
    // Implementation for showing inventory item details
  }
}

class _NavigationSidebar extends StatelessWidget {
  const _NavigationSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          ListTile(
            leading: Icon(MdiIcons.brain),
            title: const Text('AI Diagnostics'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/ai-diagnostics'),
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Maintenance'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/predictive-maintenance'),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Shop Management'),
            selected: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}