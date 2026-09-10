import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => const _RemoteListScreen(kind: _RemoteKind.notifications);
}

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) => const _RemoteListScreen(kind: _RemoteKind.logs);
}

enum _RemoteKind { notifications, logs }

class _RemoteListScreen extends StatefulWidget {
  final _RemoteKind kind;
  const _RemoteListScreen({required this.kind});

  @override
  State<_RemoteListScreen> createState() => _RemoteListScreenState();
}

class _RemoteListScreenState extends State<_RemoteListScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final Dio dio = sl<Dio>();
    final response = widget.kind == _RemoteKind.notifications
        ? await dio.get(ApiConstants.notifications)
        : await dio.get(ApiConstants.auditLogs, queryParameters: {'page': 1, 'pageSize': 100});
    final data = response.data;
    if (widget.kind == _RemoteKind.notifications) {
      if (data is! List) throw StateError('Invalid notifications response');
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (data is! Map || data['items'] is! List) throw StateError('Invalid audit log response');
    return (data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isLogs = widget.kind == _RemoteKind.logs;
    return Scaffold(
      appBar: AppTopBar(title: isLogs ? 'سجل العمليات' : 'الإشعارات'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          if (snapshot.hasError) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(snapshot.error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => setState(() => _future = _load()), child: const Text('إعادة المحاولة')),
            ])));
          }
          final items = snapshot.data ?? const [];
          if (items.isEmpty) return const Center(child: Text('لا توجد بيانات في قاعدة البيانات حالياً'));
          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () async => setState(() => _future = _load()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final item = items[index];
                if (!isLogs) {
                  return Card(child: ListTile(leading: const Icon(Icons.notifications, color: AppColors.gold), title: Text('${item['message'] ?? ''}'), subtitle: Text('${item['severity'] ?? ''}')));
                }
                return Card(child: ExpansionTile(
                  leading: const Icon(Icons.history, color: AppColors.gold),
                  title: Text('${item['action'] ?? ''}'),
                  subtitle: Text('${item['entity'] ?? ''} #${item['entityId'] ?? '-'} • ${item['timestamp'] ?? ''}'),
                  childrenPadding: const EdgeInsets.all(16),
                  children: [
                    if (item['userId'] != null) Align(alignment: Alignment.centerLeft, child: Text('User ID: ${item['userId']}')),
                    if (item['oldValue'] != null) Align(alignment: Alignment.centerLeft, child: SelectableText('Old: ${item['oldValue']}')),
                    if (item['newValue'] != null) Align(alignment: Alignment.centerLeft, child: SelectableText('New: ${item['newValue']}')),
                  ],
                ));
              },
            ),
          );
        },
      ),
    );
  }
}
