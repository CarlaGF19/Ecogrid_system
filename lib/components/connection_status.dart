import 'package:flutter/material.dart';
import '../services/connection_manager.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final ConnectionStatus status;
  final DateTime? lastUpdate;
  final ConnectionType connectionType;
  final String? sessionId;
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  const ConnectionStatusWidget({
    super.key,
    required this.status,
    this.lastUpdate,
    required this.connectionType,
    this.sessionId,
    this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getStatusIcon(),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getStatusText(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(),
                ),
              ),
              if (lastUpdate != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Última: ${_formatTime(lastUpdate!)}',
                  style: TextStyle(
                  fontSize: 10,
                  color: _getTextColor().withValues(alpha: 0.8),
                ),
                ),
              ],
            ],
          ),
          if (onRefresh != null && status == ConnectionStatus.connected) ...[
            const SizedBox(width: 8),
            _buildRefreshButton(),
          ],
        ],
      ),
    );
  }

  Widget _getStatusIcon() {
    switch (status) {
      case ConnectionStatus.connected:
        return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        );
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return SizedBox(
          width: 8,
          height: 8,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        );
      case ConnectionStatus.error:
        return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        );
      case ConnectionStatus.disconnected:
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        );
    }
  }

  String _getStatusText() {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Conectado';
      case ConnectionStatus.connecting:
        return 'Conectando...';
      case ConnectionStatus.reconnecting:
        return 'Reconectando...';
      case ConnectionStatus.error:
        return 'Error de conexión';
      case ConnectionStatus.disconnected:
        return 'Desconectado';
    }
  }

  Color _getBackgroundColor() {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green.withValues(alpha: 0.1);
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Colors.orange.withValues(alpha: 0.1);
      case ConnectionStatus.error:
        return Colors.red.withValues(alpha: 0.1);
      case ConnectionStatus.disconnected:
        return Colors.grey.withValues(alpha: 0.1);
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green.withValues(alpha: 0.3);
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Colors.orange.withValues(alpha: 0.3);
      case ConnectionStatus.error:
        return Colors.red.withValues(alpha: 0.3);
      case ConnectionStatus.disconnected:
        return Colors.grey.withValues(alpha: 0.3);
    }
  }

  Color _getTextColor() {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green[700]!;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Colors.orange[700]!;
      case ConnectionStatus.error:
        return Colors.red[700]!;
      case ConnectionStatus.disconnected:
        return Colors.grey[700]!;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ${difference.inSeconds % 60}s';
    } else {
      return '${difference.inSeconds}s';
    }
  }

  Widget _buildRefreshButton() {
    return GestureDetector(
      onTap: isRefreshing ? null : onRefresh,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: isRefreshing
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(
                Icons.refresh,
                size: 12,
                color: Colors.white,
              ),
      ),
    );
  }
}

class ConnectionStatusIndicator extends StatelessWidget {
  final ConnectionManager connectionManager;
  final VoidCallback? onRefresh;

  const ConnectionStatusIndicator({
    super.key,
    required this.connectionManager,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: connectionManager.statusStream,
      initialData: connectionManager.status,
      builder: (context, statusSnapshot) {
        return StreamBuilder<Map<String, dynamic>>(
          stream: connectionManager.dataStream,
          builder: (context, dataSnapshot) {
            return ConnectionStatusWidget(
              status: statusSnapshot.data ?? ConnectionStatus.disconnected,
              lastUpdate: connectionManager.lastSuccessfulUpdate,
              connectionType: connectionManager.connectionType,
              sessionId: connectionManager.sessionId,
              onRefresh: onRefresh,
              isRefreshing: statusSnapshot.data == ConnectionStatus.connecting ||
                           statusSnapshot.data == ConnectionStatus.reconnecting,
            );
          },
        );
      },
    );
  }
}