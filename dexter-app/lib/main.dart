import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'auth/auth_gate.dart';

import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

const ink = Color(0xFF172033);
const blue = Color(0xFF2563EB);
const muted = Color(0xFF718096);
const canvas = Color(0xFFF5F7FB);
const line = Color(0xFFE8EDF4);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Dexter Platform',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: blue),
      scaffoldBackgroundColor: canvas,
    ),
    home: const AuthGate(),
  );
}

class DexterHome extends StatefulWidget {
  const DexterHome({super.key});

  @override
  State<DexterHome> createState() => _DexterHomeState();
}

class _DexterHomeState extends State<DexterHome> {
  int selected = 0;
  final labels = const ['Dashboard', 'Assets', 'Reports'];
  final icons = const [
    Icons.space_dashboard_outlined,
    Icons.inventory_2_outlined,
    Icons.query_stats_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final desktop = size.maxWidth >= 900;
        return Scaffold(
          drawer: desktop
              ? null
              : Drawer(
                  child: _Sidebar(
                    selected: selected,
                    onSelect: (i) {
                      setState(() => selected = i);
                      Navigator.pop(context);
                    },
                  ),
                ),
          body: Row(
            children: [
              if (desktop)
                _Sidebar(
                  selected: selected,
                  onSelect: (i) => setState(() => selected = i),
                ),
              Expanded(
                child: Column(
                  children: [
                    _Header(
                      title: labels[selected],
                      desktop: desktop,
                      onMenu: () => Scaffold.of(context).openDrawer(),
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: selected,
                        children: const [
                          DashboardPage(),
                          _ModulePage(
                            icon: Icons.inventory_2_outlined,
                            title: 'My assets',
                            description: 'Your personal asset register will appear here.',
                          ),
                          _ModulePage(
                            icon: Icons.query_stats_outlined,
                            title: 'My reports',
                            description: 'Explore asset valuations and bank transaction reports here.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _Sidebar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => Container(
    width: 245,
    color: const Color(0xFF172554),
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 28, 16, 38),
            child: Row(
              children: [
                Icon(Icons.layers_rounded, color: Colors.white, size: 34),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEXTER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Text(
                      'PLATFORM',
                      style: TextStyle(
                        color: Color(0xFFB9C9E8),
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 16, 13),
            child: Text(
              'MY WORKSPACE',
              style: TextStyle(
                color: Color(0xFF9EAFD0),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onSelect(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: selected == i ? blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        const [
                          Icons.space_dashboard_outlined,
                          Icons.inventory_2_outlined,
                          Icons.query_stats_outlined,
                        ][i],
                        color: Colors.white,
                        size: 19,
                      ),
                      const SizedBox(width: 13),
                      Text(
                        const ['Dashboard', 'Assets', 'Reports'][i],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: Color(0xFFDCE9FF),
                    child: Icon(Icons.person_outline, color: Color(0xFF1D4ED8)),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Personal workspace',
                        style: TextStyle(
                          color: Color(0xFFCAD6E9),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  final String title;
  final bool desktop;
  final VoidCallback onMenu;
  const _Header({
    required this.title,
    required this.desktop,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 76,
    padding: EdgeInsets.symmetric(horizontal: desktop ? 30 : 14),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: line)),
    ),
    child: Row(
      children: [
        if (!desktop)
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
            ),
          ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  color: ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Your personal workspace',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ],
          ),
        ),
        if (desktop)
          const SizedBox(
            width: 220,
            height: 38,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search your records',
                prefixIcon: Icon(Icons.search, size: 18),
                filled: true,
                fillColor: canvas,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
              ),
            ),
          ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          tooltip: 'Account',
          onSelected: (value) async {
            if (value == 'signout') {
              await FirebaseAuth.instance.signOut();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'signout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 10),
                  Text('Sign out'),
                ],
              ),
            ),
          ],
          child: const CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFFE5EEFF),
            child: Icon(Icons.person_outline, color: blue, size: 19),
          ),
        ),
      ],
    ),
  );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final compact = box.maxWidth < 650;
      final columns = box.maxWidth >= 1150
          ? 4
          : box.maxWidth >= 650
          ? 2
          : 1;
      return SingleChildScrollView(
        padding: EdgeInsets.all(compact ? 16 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your financial snapshot',
              style: TextStyle(
                fontSize: 23,
                color: ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'A private overview of your assets and finances.',
              style: TextStyle(color: muted, fontSize: 13),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFF5E5B8)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 17, color: Color(0xFF946200)),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Preview mode — figures are sample data, not personal financial records.',
                      style: TextStyle(color: Color(0xFF795600), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: compact ? 2.45 : 1.85,
              children: const [
                _Metric(
                  'My assets',
                  '12',
                  'Across 4 categories',
                  Icons.inventory_2_outlined,
                  Color(0xFFEAF1FF),
                  Color(0xFF2563EB),
                ),
                _Metric(
                  'Estimated asset value',
                  '₹18.4 L',
                  'Illustrative total',
                  Icons.account_balance_wallet_outlined,
                  Color(0xFFE7F7F2),
                  Color(0xFF0D9488),
                ),
                _Metric(
                  'Transactions imported',
                  '248',
                  'From sample statements',
                  Icons.receipt_long_outlined,
                  Color(0xFFF1EBFF),
                  Color(0xFF7C3AED),
                ),
                _Metric(
                  'Monthly spending',
                  '₹42,650',
                  'Sample current month',
                  Icons.trending_down_rounded,
                  Color(0xFFFFF0E6),
                  Color(0xFFEA580C),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (box.maxWidth >= 900)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _PortfolioCard()),
                  SizedBox(width: 16),
                  Expanded(flex: 2, child: _StatementCard()),
                ],
              )
            else
              const Column(
                children: [
                  _PortfolioCard(),
                  SizedBox(height: 16),
                  _StatementCard(),
                ],
              ),
            const SizedBox(height: 18),
            const _ActivityCard(),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Dexter Platform • Personal workspace',
                style: TextStyle(color: muted, fontSize: 10),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _Metric extends StatelessWidget {
  final String title, value, note;
  final IconData icon;
  final Color tint, accent;
  const _Metric(
    this.title,
    this.value,
    this.note,
    this.icon,
    this.tint,
    this.accent,
  );

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: _card(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: muted)),
            Text(note, style: const TextStyle(fontSize: 10, color: muted)),
          ],
        ),
      ],
    ),
  );
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard();

  @override
  Widget build(BuildContext context) {
    const data = [
      ('Property', .72, Color(0xFF2563EB), '₹12.0 L'),
      ('Vehicles', .48, Color(0xFF0D9488), '₹3.2 L'),
      ('Electronics', .28, Color(0xFFF59E0B), '₹1.4 L'),
      ('Other assets', .36, Color(0xFF8B5CF6), '₹1.8 L'),
    ];
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My asset portfolio',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          const Text(
            'Illustrative value by category',
            style: TextStyle(fontSize: 11, color: muted),
          ),
          const SizedBox(height: 22),
          for (final row in data) ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: row.$3,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(row.$1, style: const TextStyle(fontSize: 12)),
                ),
                Text(
                  row.$4,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: row.$2,
                minHeight: 7,
                backgroundColor: const Color(0xFFF0F2F6),
                valueColor: AlwaysStoppedAnimation(row.$3),
              ),
            ),
            const SizedBox(height: 17),
          ],
        ],
      ),
    );
  }
}

class _StatementCard extends StatelessWidget {
  const _StatementCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(21),
    decoration: _card(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.file_upload_outlined, color: blue),
            SizedBox(width: 9),
            Text(
              'Bank statements',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose a CSV statement to inspect its contents before importing.',
          style: TextStyle(color: muted, fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 16),
        const Text(
          'CSV files only · Maximum 5 MB',
          style: TextStyle(color: muted, fontSize: 10),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const _CsvPreviewDialog(),
            ),
            icon: const Icon(Icons.upload_file, size: 17),
            label: const Text('Choose CSV statement'),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Local preview only. No file is uploaded or saved in this demo.',
          style: TextStyle(color: muted, fontSize: 10),
        ),
      ],
    ),
  );
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(21),
    decoration: _card(),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent personal activity',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 16),
        _ActivityRow(
          Icons.add_box_outlined,
          'Personal asset added',
          'Laptop · Electronics',
        ),
        Divider(height: 22, color: line),
        _ActivityRow(
          Icons.receipt_long_outlined,
          'Statement reviewed',
          'Sample bank statement',
        ),
        Divider(height: 22, color: line),
        _ActivityRow(
          Icons.edit_note_outlined,
          'Asset value updated',
          'Vehicle · Personal asset',
        ),
      ],
    ),
  );
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _ActivityRow(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: blue, size: 19),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: muted)),
          ],
        ),
      ),
      const Text('Sample', style: TextStyle(fontSize: 10, color: muted)),
    ],
  );
}

class _ModulePage extends StatelessWidget {
  final IconData icon;
  final String title, description;
  const _ModulePage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: blue),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 15),
            const Chip(label: Text('Under development')),
          ],
        ),
      ),
    ),
  );
}

class _CsvPreviewDialog extends StatefulWidget {
  const _CsvPreviewDialog();

  @override
  State<_CsvPreviewDialog> createState() => _CsvPreviewDialogState();
}

class _CsvPreviewDialogState extends State<_CsvPreviewDialog> {
  String? fileName;
  List<List<dynamic>> rows = [];
  String? error;
  bool loading = false;

  Future<void> pickCsv() async {
    setState(() {
      loading = true;
      error = null;
      rows = [];
      fileName = null;
    });
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result.isEmpty) {
        setState(() => loading = false);
        return;
      }
      final file = result.single;
      final bytes = await file.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        throw const FormatException('File must be smaller than 5 MB.');
      }
      final content = utf8.decode(bytes, allowMalformed: true);
      final parsed = const CsvDecoder().convert(content);
      if (parsed.length < 2) {
        throw const FormatException('No transaction rows were found.');
      }
      setState(() {
        fileName = file.name;
        rows = parsed.take(6).toList();
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('FormatException: ', '');
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Preview bank statement'),
    content: SizedBox(
      width: 620,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a CSV file. It is read locally for preview only; this demo does not send it to a server or save it.',
              style: TextStyle(fontSize: 12, color: muted, height: 1.5),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: loading ? null : pickCsv,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select CSV file'),
            ),
            if (loading) const LinearProgressIndicator(),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (fileName != null) ...[
              const SizedBox(height: 12),
              Text(
                fileName!,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'First five rows',
                style: TextStyle(color: muted, fontSize: 11),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    for (final heading in rows.first)
                      DataColumn(
                        label: Text(
                          heading.toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                  ],
                  rows: [
                    for (final row in rows.skip(1))
                      DataRow(
                        cells: [
                          for (var i = 0; i < rows.first.length; i++)
                            DataCell(
                              Text(
                                i < row.length ? row[i].toString() : '',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  );
}

BoxDecoration _card() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: line),
);
