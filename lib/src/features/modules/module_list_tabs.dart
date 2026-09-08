/// Confirmed React list tabs. Filter values retain the backend spelling.
class ModuleListTab {
  const ModuleListTab(
    this.label, {
    this.value,
    this.field = 'stage',
    this.operator = '=',
  });
  final String label;
  final String? value;
  final String field;
  final String operator;
  Map<String, Object?>? get filter => value == null
      ? null
      : {
          'id': field,
          'opr': operator,
          'value': operator == 'in' ? [value] : value,
        };
  static List<ModuleListTab> forType(String? type) => switch (type) {
    'return_orders' => const [
      ModuleListTab('New', value: 'New'),
      ModuleListTab('Ready to Pickup', value: 'Ready to Pickup'),
      ModuleListTab('In Transit', value: 'In-Transit'),
      ModuleListTab('Delivered', value: 'Delivered'),
      ModuleListTab('Cancelled', value: 'Cancelled'),
      ModuleListTab('All'),
    ],
    'delivery_attempt' => const [
      ModuleListTab('All'),
      ModuleListTab('Pending', value: 'Pending', operator: 'in'),
      ModuleListTab('Unsuccessful', value: 'Unsuccessful', operator: 'in'),
      ModuleListTab('Delivered', value: 'Delivered', operator: 'in'),
      ModuleListTab(
        'Delivery Reattempted',
        value: 'Delivery Reattempted',
        operator: 'in',
      ),
    ],
    'pickup_and_manifest' => const [
      ModuleListTab('All'),
      ModuleListTab('Scheduled', field: 'status', value: 'Scheduled'),
      ModuleListTab('Completed', field: 'status', value: 'Completed'),
      ModuleListTab(
        'Partially Completed',
        field: 'status',
        value: 'Partially Completed',
      ),
      ModuleListTab('Cancelled', field: 'status', value: 'Cancelled'),
    ],
    _ => const [],
  };
}
