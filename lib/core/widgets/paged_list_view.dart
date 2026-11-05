import 'package:flutter/material.dart';

import '../../app/theme/theme_context.dart';
import '../../l10n/generated/app_localizations.dart';
import '../pagination/paged_state.dart';
import 'empty_state_view.dart';
import 'error_view.dart';
import 'loading_view.dart';

/// Список страницами: загрузка, ошибка, пустой список и подгрузка при прокрутке.
class PagedListView<T> extends StatelessWidget {
  /// Создаёт список по состоянию [state]; [empty] показывается, когда данных нет.
  const PagedListView({
    super.key,
    required this.state,
    required this.errorTitle,
    required this.empty,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRetry,
  });

  final PagedState<T> state;
  final String errorTitle;
  final EmptyStateView empty;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;

  /// Строит состояние списка или сам список с подвалом подгрузки.
  @override
  Widget build(BuildContext context) {
    final failure = state.failure;
    if (state.items.isEmpty) {
      if (failure != null) {
        return ErrorView(title: errorTitle, failure: failure, onRetry: onRetry);
      }
      return state.loading ? const LoadingView() : empty;
    }
    final showFooter = state.hasMore || failure != null;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (failure == null &&
            metrics.extentAfter < metrics.viewportDimension / 2) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsetsDirectional.only(bottom: context.sizes.fabClearance),
        itemCount: state.items.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < state.items.length) {
            return itemBuilder(context, state.items[index], index);
          }
          return failure == null
              ? Padding(
                  padding: EdgeInsetsDirectional.all(context.spacing.md),
                  child: const LoadingView(),
                )
              : TextButton(
                  onPressed: onLoadMore,
                  child: Text(AppLocalizations.of(context).actionRetry),
                );
        },
      ),
    );
  }
}
