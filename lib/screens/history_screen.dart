import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/reqgpt_controller.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.onSessionSelected});

  /// Oturum seçilince Chat sekmesine geçmek için çağrılır.
  final VoidCallback onSessionSelected;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReqGptController>();

    // Güncellenme tarihine göre en yeni üstte
    final sorted = [...controller.sessions]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş'),
        actions: [
          if (sorted.length > 1)
            IconButton(
              tooltip: 'Tüm geçmişi sil',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClearAll(context, controller),
            ),
        ],
      ),
      body: sorted.isEmpty
          ? const Center(
              child: Text('Henüz kaydedilmiş proje yok.'),
            )
          : ListView.separated(
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final session = sorted[i];
                final isCurrent = session.id == controller.currentSessionId;
                final userCount = session.messages
                    .where((m) => m.role.name == 'user')
                    .length;
                final hasArtifacts = session.artifacts.requirements.isNotEmpty ||
                    session.artifacts.useCases.isNotEmpty ||
                    session.artifacts.srs.isNotEmpty;

                return Dismissible(
                  key: ValueKey(session.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  confirmDismiss: (_) => _confirmDelete(context),
                  onDismissed: (_) => controller.deleteSession(session.id),
                  child: ListTile(
                    selected: isCurrent,
                    selectedTileColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.35),
                    leading: CircleAvatar(
                      backgroundColor: isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        isCurrent ? Icons.chat : Icons.history,
                        size: 20,
                        color: isCurrent
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      session.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _subtitle(session.updatedAt, userCount, hasArtifacts),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: isCurrent
                        ? const Chip(
                            label: Text('Aktif'),
                            visualDensity: VisualDensity.compact,
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: isCurrent
                        ? () => onSessionSelected()
                        : () async {
                            await controller.switchToSession(session.id);
                            onSessionSelected();
                          },
                  ),
                );
              },
            ),
    );
  }

  String _subtitle(DateTime updatedAt, int userCount, bool hasArtifacts) {
    final date = DateFormat('d MMM yyyy, HH:mm', 'tr_TR').format(updatedAt);
    final artifacts = hasArtifacts ? ' · Artifact var' : '';
    return '$date · $userCount mesaj$artifacts';
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Oturumu Sil'),
        content: const Text('Bu proje oturumu kalıcı olarak silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearAll(
      BuildContext context, ReqGptController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tüm Geçmişi Temizle'),
        content: const Text('Tüm proje oturumları silinecek ve yeni bir oturum başlatılacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ids = controller.sessions.map((s) => s.id).toList();
      for (final id in ids) {
        await controller.deleteSession(id);
      }
      onSessionSelected();
    }
  }
}
