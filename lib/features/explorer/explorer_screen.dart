import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nebula_core/nebula_core.dart';
import 'package:go_router/go_router.dart';

class ExplorerScreen extends ConsumerStatefulWidget {
  const ExplorerScreen({super.key});

  @override
  ConsumerState<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends ConsumerState<ExplorerScreen> {
  final _core = NebulaCore();
  List<FileMeta> _files = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final files = await _core.listFiles('/');
    setState(() => _files = files);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nebula Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => context.push('/transfers'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          return ListTile(
            leading: Icon(
              file.isFolder ? Icons.folder : Icons.insert_drive_file,
              color: file.isFolder ? const Color(0xFF6366F1) : Colors.grey,
            ),
            title: Text(file.name),
            trailing: file.isFolder ? null : const Icon(Icons.download),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFile,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _uploadFile() async {
    // Simulate file upload
    context.push('/transfers');
  }
}
