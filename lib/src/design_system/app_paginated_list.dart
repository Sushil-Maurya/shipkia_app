import 'package:flutter/material.dart';

import '../core/state/paginated_controller.dart';
import 'app_button.dart';
import 'app_state_views.dart';

/// Common mobile browsing states for server-paginated feature lists.
class AppPaginatedList<T> extends StatelessWidget {
  const AppPaginatedList({
    required this.controller,
    required this.itemBuilder,
    required this.emptyTitle,
    required this.emptyMessage,
    this.emptyActionLabel,
    this.onEmptyAction,
    super.key,
  });
  final PaginatedController<T> controller;
  final Widget Function(BuildContext, T) itemBuilder;
  final String emptyTitle;
  final String emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => RefreshIndicator(
      onRefresh: controller.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          if (controller.loading && controller.records.isNotEmpty)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (controller.error != null && controller.records.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Semantics(
                  liveRegion: true,
                  child: Column(
                    children: [
                      Text(
                        controller.error!.message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      AppButton(
                        label: 'Retry',
                        icon: Icons.refresh,
                        onPressed: controller.retry,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (controller.records.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: controller.loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Loading records',
                      ),
                    )
                  : controller.error != null
                  ? AppErrorState(
                      message: controller.error!.message,
                      onRetry: controller.retry,
                    )
                  : AppEmptyState(
                      title: emptyTitle,
                      message: emptyMessage,
                      actionLabel: emptyActionLabel,
                      onAction: onEmptyAction,
                    ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.only(top: 8),
              sliver: SliverList.builder(
                itemCount: controller.records.length,
                itemBuilder: (context, index) =>
                    itemBuilder(context, controller.records[index]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: controller.hasMore
                      ? AppButton(
                          label: 'Load more',
                          loading: controller.loadingMore,
                          variant: AppButtonVariant.secondary,
                          height: 48,
                          onPressed:
                              controller.loading || controller.error != null
                              ? null
                              : controller.loadMore,
                        )
                      : const Text('You have reached the end'),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
