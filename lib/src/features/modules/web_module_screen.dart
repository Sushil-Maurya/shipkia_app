import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api.dart';
import '../../core/auth/shipkia_auth_scope.dart';
import '../../core/router/web_module_catalog.dart';
import '../../core/state/paginated_controller.dart';
import '../../design_system/design_system.dart';
import '../../design_system/app_paginated_list.dart';
import 'module_records.dart';
import 'module_list_tabs.dart';
import 'asset_form_screen.dart';
import 'workspace_settings_screen.dart';

class WebModuleScreen extends StatelessWidget {
  const WebModuleScreen({required this.route, this.recordId, super.key});
  final WebModuleRoute route;
  final String? recordId;
  @override
  Widget build(BuildContext context) {
    if (route.kind == WebModuleKind.section) {
      return _ModuleSection(route: route);
    }
    if (route.objectType == 'company_info' && recordId == null) {
      final id = context
          .dependOnInheritedWidgetOfExactType<ShipKiaAuthScope>()
          ?.notifier
          ?.profile
          ?.customerId;
      if (id == null || id.isEmpty) {
        return AppScaffold(
          title: route.label,
          body: const AppEmptyState(
            title: 'Company unavailable',
            message: 'Your company profile could not be loaded. Sign in again to retry.',
          ),
        );
      }
      return ModuleDetailScreen(route: route, id: id);
    }
    if (recordId != null) {
      return ModuleDetailScreen(route: route, id: recordId!);
    }
    if (route.kind == WebModuleKind.list) return _ModuleList(route: route);
    return WorkspaceSettingsScreen(route: route);
  }
}

class _ModuleSection extends StatefulWidget {
  const _ModuleSection({required this.route});
  final WebModuleRoute route;
  @override
  State<_ModuleSection> createState() => _ModuleSectionState();
}

class _ModuleSectionState extends State<_ModuleSection> {
  String search = '';
  String group(WebModuleRoute route) {
    if ([
      'company_info',
      'pickup_address',
      'pickup_address_details',
      'tax_rate',
      'bank_accounts',
      'bank_account_details',
    ].contains(route.objectType)) {
      return 'Company & payouts';
    }
    if ([
          'products',
          'box',
          'product_box_combination',
          'product_box_proposal',
        ].contains(route.objectType) ||
        route.path.endsWith('default-dimension')) {
      return 'Catalog & packaging';
    }
    if (route.path.contains('notification') ||
        route.path.contains('confirmation')) {
      return 'Notifications & verification';
    }
    if (route.objectType == 'print_template' ||
        route.path.contains('automation') ||
        route.path.contains('ndr-flow')) {
      return 'Shipping & automation';
    }
    return 'Workspace';
  }

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<WebModuleRoute>>{
      if (widget.route.path == '/settings') ...{
        'Company & payouts': [],
        'Catalog & packaging': [],
        'Shipping & automation': [],
        'Notifications & verification': [],
        'Workspace': [],
      },
    };
    for (final child in widget.route.children.where(
      (r) => '${r.label} ${r.description}'.toLowerCase().contains(
        search.toLowerCase(),
      ),
    )) {
      groups
          .putIfAbsent(
            widget.route.path == '/settings' ? group(child) : 'Explore',
            () => [],
          )
          .add(child);
    }
    groups.removeWhere((_, routes) => routes.isEmpty);
    return AppScaffold(
      title: widget.route.label,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Manage your workspace',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(widget.route.description),
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Find a page or setting',
            ),
          ),
          if (groups.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No matching pages'),
            ),
          for (final entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final child in entry.value)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: Icon(child.icon),
                      title: Text(child.label),
                      subtitle: Text(child.description),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(child.path),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ModuleList extends StatefulWidget {
  const _ModuleList({required this.route});
  final WebModuleRoute route;
  @override
  State<_ModuleList> createState() => _ModuleListState();
}

class _ModuleListState extends State<_ModuleList> {
  final controller = PaginatedController<ModuleRecord>(recordKey: (r) => r.id);
  final search = TextEditingController();
  Timer? debounce;
  ModuleRepository? repository;
  int selectedTab = 0;
  List<ModuleListTab> get tabs =>
      ModuleListTab.forType(widget.route.objectType);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final api = ShipKiaApiScope.maybeOf(context);
    if (repository == null && api != null) {
      repository = ModuleRepository(api, widget.route);
      load();
    }
  }

  void load() {
    final repo = repository;
    if (repo != null) {
      final query = search.text;
      final tab = tabs.isEmpty ? null : tabs[selectedTab];
      unawaited(
        controller.setQuery(
          (p, s, t) => repo.list(p, s, t, search: query, tab: tab),
        ),
      );
    }
  }

  @override
  void dispose() {
    debounce?.cancel();
    search.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: widget.route.label,
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextField(
            controller: search,
            decoration: InputDecoration(
              hintText: 'Search ${widget.route.label.toLowerCase()}',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close),
                onPressed: () {
                  search.clear();
                  debounce?.cancel();
                  load();
                },
              ),
            ),
            onChanged: (_) {
              debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 350), load);
            },
          ),
        ),
        if (tabs.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final (index, tab) in tabs.indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChip(
                      label: tab.label,
                      selected: selectedTab == index,
                      onSelected: (_) {
                        setState(() => selectedTab = index);
                        debounce?.cancel();
                        load();
                      },
                    ),
                  ),
              ],
            ),
          ),
        if (AssetFormAccess.canWrite(
          context,
          widget.route.objectType,
          create: true,
        ))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppButton(
              label: 'Add ${widget.route.label}',
              icon: Icons.add,
              onPressed: () async {
                final saved = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => AssetFormScreen(route: widget.route),
                  ),
                );
                if (saved == true && mounted) load();
              },
            ),
          ),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.totalRecords == null
                        ? widget.route.description
                        : '${controller.totalRecords} records',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: controller.refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: repository == null
              ? const AppEmptyState(
                  title: 'Connection unavailable',
                  message: 'Sign in to load your records.',
                )
              : AppPaginatedList<ModuleRecord>(
                  controller: controller,
                  emptyTitle: 'No ${widget.route.label.toLowerCase()} found',
                  emptyMessage: 'Try another search or pull down to refresh.',
                  itemBuilder: (context, record) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(child: Icon(widget.route.icon)),
                        title: Text(
                          record.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(record.id),
                              if (record.primary) const Text('Primary'),
                              ...record.displayFields
                                  .where(
                                    (f) =>
                                        f.type != 'section' &&
                                        ![
                                          'id',
                                          'name',
                                          'is_primary',
                                        ].contains(f.name) &&
                                        record.values[f.name] != null &&
                                        record.values[f.name] is! Map &&
                                        record.values[f.name] is! List &&
                                        f.format(record.values[f.name]) !=
                                            record.title,
                                  )
                                  .take(3)
                                  .map(
                                    (f) => Text(
                                      '${f.label}: ${f.format(record.values[f.name])}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(
                          '${widget.route.path}/${Uri.encodeComponent(record.id)}',
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    ),
  );
}

class ModuleDetailScreen extends StatefulWidget {
  const ModuleDetailScreen({required this.route, required this.id, super.key});
  final WebModuleRoute route;
  final String id;
  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  Future<ModuleRecord>? request;
  CancelToken? token;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    request ??= load();
  }

  @override
  void didUpdateWidget(ModuleDetailScreen old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id || old.route.path != widget.route.path) {
      request = load();
    }
  }

  Future<ModuleRecord> load() {
    token?.cancel();
    token = CancelToken();
    final api = ShipKiaApiScope.maybeOf(context);
    if (api == null) return Future.error(StateError('Connection unavailable'));
    return ModuleRepository(api, widget.route).detail(widget.id, token!);
  }

  void reload() => setState(() => request = load());
  @override
  void dispose() {
    token?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: widget.route.label,
    body: FutureBuilder<ModuleRecord>(
      future: request,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return AppErrorState(
            message: ApiExceptionMapper.unknown(snapshot.error!).message,
            onRetry: reload,
          );
        }
        final record = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            reload();
            await request;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 26, child: Icon(widget.route.icon)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SelectableText(record.id),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh details',
                    onPressed: reload,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              if (record.primary)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Chip(
                    label: Text('Primary'),
                    avatar: Icon(Icons.check_circle_outline),
                  ),
                ),
              const SizedBox(height: 20),
              AppButton(
                label:
                    AssetFormAccess.canWrite(
                      context,
                      widget.route.objectType,
                      create: false,
                    )
                    ? 'Edit details'
                    : 'View form fields',
                variant: AppButtonVariant.secondary,
                icon: Icons.edit_note,
                onPressed: () async {
                  final editable = AssetFormAccess.canWrite(
                    context,
                    widget.route.objectType,
                    create: false,
                  );
                  final saved = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => AssetFormScreen(
                        route: widget.route,
                        recordId: widget.id,
                        readOnly: !editable,
                      ),
                    ),
                  );
                  if (saved == true && mounted) reload();
                },
              ),
              const SizedBox(height: 16),
              RecordFieldsView(record: record),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    ),
  );
}

class RecordFieldsView extends StatelessWidget {
  const RecordFieldsView({required this.record, super.key});
  final ModuleRecord record;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final field in record.displayFields)
        if (field.type == 'section')
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Text(
              field.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          )
        else if (!(field.name == 'rto_address' &&
            record.values['rto_is_same_as_pickup'] == true))
          _value(context, field, record.values[field.name]),
    ],
  );
  Widget _value(BuildContext context, RecordField field, Object? value) {
    if (value is List || value is Map) {
      final values = value is List ? value : [value];
      return ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(field.label),
        subtitle: Text(
          '${values.length} ${value is List ? 'items' : 'record'}',
        ),
        children: [
          for (final (index, item) in values.indexed)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              child: item is Map
                  ? RecordFieldsView(
                      record: ModuleRecord(
                        Map<String, dynamic>.from(item),
                        field.children,
                      ),
                    )
                  : ListTile(
                      title: Text('${index + 1}. ${field.format(item)}'),
                    ),
            ),
        ],
      );
    }
    final target = field.objectType == null
        ? null
        : WebModuleCatalog.allRoutes
              .where((r) => r.objectType == field.objectType)
              .firstOrNull;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: .25),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 5),
          if (target != null && value != null && value != '')
            TextButton(
              onPressed: () => context.push(
                '${target.path}/${Uri.encodeComponent('$value')}',
              ),
              child: Text(field.format(value)),
            )
          else if (field.name == 'template')
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('View template source'),
              children: [SelectableText(field.format(value))],
            )
          else
            SelectableText(
              field.format(value),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
        ],
      ),
    );
  }
}
