import 'dart:io';
import 'package:mysql_client_plus/mysql_client_plus.dart';

class Database {
  static MySQLConnectionPool? _pool;

  static Future<MySQLConnectionPool> getConnection() async {
    _pool ??= MySQLConnectionPool(
      host: Platform.environment['DB_HOST'] ?? '127.0.0.1',
      port: int.tryParse(Platform.environment['DB_PORT'] ?? '3306') ?? 3306,
      userName: Platform.environment['DB_USER'] ?? 'root',
      password: Platform.environment['DB_PASSWORD'] ?? '',
      databaseName: Platform.environment['DB_NAME'] ?? 'sicamat_db',
      maxConnections:
          int.tryParse(Platform.environment['DB_POOL_SIZE'] ?? '10') ?? 10,
      secure: (Platform.environment['DB_SECURE'] ?? 'false') == 'true',
    );
    return _pool!;
  }
}
