import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../rating/data/gym_repository_provider.dart';
import '../../rating/domain/gym.dart';
import 'create_gym_dialog.dart';

/// Выбор зала: поиск по названию с подгрузкой страниц и создание нового.
class GymPickerScreen extends ConsumerStatefulWidget {
  /// Создаёт экран выбора зала; выбранный зал возвращается через pop.
  const GymPickerScreen({super.key});

  /// Создаёт состояние экрана.
  @override
  ConsumerState<GymPickerScreen> createState() => _GymPickerScreenState();
}

/// Хранит запрос, загруженные залы, курсор следующей страницы и ошибку.
class _GymPickerScreenState extends ConsumerState<GymPickerScreen> {
  static const Duration _searchDelay = Duration(milliseconds: 300);

  final List<Gym> _gyms = [];
  String _query = '';
  String? _cursor;
  bool _loading = false;
  bool _hasMore = true;
  AppFailure? _failure;
  Timer? _debounce;
  int _requestId = 0;

  /// Загружает первую страницу залов.
  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  /// Останавливает отложенный поиск.
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Строит поле поиска, список и кнопку создания зала.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.gymPickerTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.gymCreate),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.all(spacing.md),
            child: TextField(
              decoration: InputDecoration(
                labelText: l10n.gymSearchLabel,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: _onQueryChanged,
            ),
          ),
          Expanded(child: _buildResults(l10n)),
        ],
      ),
    );
  }

  /// Строит загрузку, ошибку, пустой результат или список залов.
  Widget _buildResults(AppLocalizations l10n) {
    final failure = _failure;
    if (failure != null && _gyms.isEmpty) {
      return ErrorView(
        title: l10n.gymPickerTitle,
        failure: failure,
        onRetry: () => _load(reset: true),
      );
    }
    if (_gyms.isEmpty) {
      return _loading
          ? const LoadingView()
          : EmptyStateView(
              icon: Icons.fitness_center_outlined,
              title: l10n.gymPickerTitle,
              message: l10n.gymSearchEmpty,
            );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (metrics.extentAfter < metrics.viewportDimension / 2) {
          _load();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _gyms.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _gyms.length) {
            return Padding(
              padding: EdgeInsetsDirectional.all(context.spacing.md),
              child: const LoadingView(),
            );
          }
          final gym = _gyms[index];
          return ListTile(
            title: Text(gym.name),
            subtitle: Text(gym.city),
            onTap: () => context.pop(gym),
          );
        },
      ),
    );
  }

  /// Перезапускает поиск после паузы в наборе.
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDelay, () {
      _query = value;
      _load(reset: true);
    });
  }

  /// Загружает страницу залов; [reset] начинает список заново.
  Future<void> _load({bool reset = false}) async {
    if (!reset && (_loading || !_hasMore)) {
      return;
    }
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      if (reset) {
        _gyms.clear();
        _cursor = null;
        _hasMore = true;
        _failure = null;
      }
    });
    final result = await ref
        .read(gymRepositoryProvider)
        .searchGyms(query: _query, cursor: _cursor);
    if (!mounted || requestId != _requestId) {
      return;
    }
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final value):
          _gyms.addAll(value.items);
          _cursor = value.nextCursor;
          _hasMore = value.hasMore;
        case Failure(:final failure):
          _failure = failure;
          _hasMore = false;
      }
    });
  }

  /// Создаёт зал и сразу выбирает его.
  Future<void> _create() async {
    final gym = await showCreateGymDialog(context, initialName: _query);
    if (gym != null && mounted) {
      context.pop(gym);
    }
  }
}
