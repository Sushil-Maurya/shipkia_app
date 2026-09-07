import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api.dart';
import '../../core/router/web_module_catalog.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';

class WebModuleScreen extends StatefulWidget {
  const WebModuleScreen({required this.route, super.key});

  final WebModuleRoute route;

  @override
  State<WebModuleScreen> createState() => _WebModuleScreenState();
}

class _WebModuleScreenState extends State<WebModuleScreen> {
  Future<Object?>? _request;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _request ??= _load();
  }

  @override
  void didUpdateWidget(WebModuleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route.path != widget.route.path) {
      _request = _load();
    }
  }

  Future<Object?> _load() async {
    if (widget.route.kind == WebModuleKind.section) return null;
    final apiClient = ShipKiaApiScope.maybeOf(context);
    if (apiClient == null) return null;

    final endpoint =
        widget.route.endpoint ??
        (widget.route.objectType == null
            ? null
            : WebModuleCatalog.listEndpointFor(widget.route.objectType!));
    if (endpoint == null) return null;
    try {
      return await apiClient.request<Object?>(
        ApiRequestConfig(
          method: widget.route.method,
          path: endpoint,
          data: widget.route.kind == WebModuleKind.list ? const [] : null,
          params: widget.route.kind == WebModuleKind.list
              ? const {'page': '1', 'rows': '10'}
              : null,
          showSuccessMessage: false,
          showErrorMessage: false,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.route.label,
      body: widget.route.kind == WebModuleKind.section
          ? _SectionBody(route: widget.route)
          : FutureBuilder<Object?>(
              future: _request,
              builder: (context, snapshot) {
                final data = snapshot.data;
                return RefreshIndicator(
                  onRefresh: () async {
                    final request = _load();
                    setState(() => _request = request);
                    await request;
                  },
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: ShipKiaSpacing.xl),
                    children: [
                      _ModuleHeader(route: widget.route),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const LinearProgressIndicator(minHeight: 2),
                      _LiveStatus(
                        route: widget.route,
                        data: data,
                        loading:
                            snapshot.connectionState == ConnectionState.waiting,
                      ),
                      ..._previewRows(data),
                    ],
                  ),
                );
              },
            ),
    );
  }

  List<Widget> _previewRows(Object? data) {
    final rows = _extractRows(data);
    if (rows.isEmpty) {
      return [
        const AppEmptyState(
          title: 'No records to preview',
          message: 'The page is wired to the same web route and API. Records will appear here when the backend returns list data.',
        ),
      ];
    }

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(
          ShipKiaSpacing.page,
          ShipKiaSpacing.md,
          ShipKiaSpacing.page,
          ShipKiaSpacing.sm,
        ),
        child: Text(
          '${rows.length} records loaded',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: ShipKiaColors.textSecondary(context)),
        ),
      ),
      for (final row in rows.take(20))
        AppListTile(
          leading: const Icon(Icons.dataset_outlined),
          title: _recordTitle(row),
          subtitle: _recordSubtitle(row),
          trailing: const Icon(Icons.chevron_right, size: 18),
        ),
    ];
  }

  List<Map<String, dynamic>> _extractRows(Object? data) {
    if (data is List) return data.whereType<Map>().map(_jsonMap).toList();
    if (data is! Map) return const <Map<String, dynamic>>[];
    final json = _jsonMap(data);
    final values = json['values'] ?? json['records'] ?? json['data'];
    if (values is List) return values.whereType<Map>().map(_jsonMap).toList();
    return const <Map<String, dynamic>>[];
  }

  String _recordTitle(Map<String, dynamic> row) {
    for (final key in const ['id', 'name', 'order_id', 'awb', 'email']) {
      final value = row[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return widget.route.label;
  }

  String? _recordSubtitle(Map<String, dynamic> row) {
    final parts = <String>[];
    for (final key in const ['status', 'customer', 'type', 'created_at']) {
      final value = row[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        parts.add(value.toString());
      }
    }
    return parts.isEmpty ? null : parts.join(' - ');
  }

  Map<String, dynamic> _jsonMap(Map<dynamic, dynamic> value) {
    return Map<String, dynamic>.from(value);
  }
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.route});

  final WebModuleRoute route;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: ShipKiaSpacing.xl),
      children: [
        _ModuleHeader(route: route),
        for (final child in route.children)
          AppListTile(
            leading: Icon(child.icon, color: ShipKiaColors.shipkiaBlue),
            title: child.label,
            subtitle: child.description,
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => context.push(child.path),
          ),
      ],
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.route});

  final WebModuleRoute route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ShipKiaSpacing.page),
      child: AppCard(
        padding: const EdgeInsets.all(ShipKiaSpacing.md),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: ShipKiaColors.shipkiaBlue.withValues(alpha: 0.12),
                borderRadius: ShipKiaRadius.mdBorder,
              ),
              child: Padding(
                padding: const EdgeInsets.all(ShipKiaSpacing.sm),
                child: Icon(route.icon, color: ShipKiaColors.shipkiaBlue),
              ),
            ),
            const SizedBox(width: ShipKiaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.label,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: ShipKiaSpacing.xs),
                  Text(
                    route.description,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: ShipKiaColors.textSecondary(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveStatus extends StatelessWidget {
  const _LiveStatus({
    required this.route,
    required this.data,
    required this.loading,
  });

  final WebModuleRoute route;
  final Object? data;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final endpoint =
        route.endpoint ??
        (route.objectType == null
            ? null
            : WebModuleCatalog.listEndpointFor(route.objectType!));

    return AppListTile(
      leading: Icon(
        loading ? Icons.sync : Icons.cloud_done_outlined,
        color: ShipKiaColors.shipkiaBlue,
      ),
      title: loading ? 'Loading API data' : 'API route connected',
      subtitle: endpoint,
      trailing: Text(
        data == null ? 'Fallback' : 'Live',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: data == null
              ? ShipKiaColors.textSecondary(context)
              : ShipKiaColors.success,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
