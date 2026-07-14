import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kantor_camat_app/widgets/common_widgets.dart';

void main() {
  testWidgets('Status badge menampilkan status', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBadge('baru')),
      ),
    );
    expect(find.text('baru'), findsOneWidget);
  });
}
