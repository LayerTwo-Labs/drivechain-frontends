import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class TreeNode {
  final String name;
  final String fullPath;
  bool isDirectory;
  final Map<String, TreeNode> children = {};

  TreeNode({required this.name, required this.fullPath, this.isDirectory = false});

  bool get shouldShowAsDirectory => isDirectory || children.isNotEmpty;

  /// Returns the tree and a set of paths that should be collapsed by default
  /// (directories that are leaf nodes in the original paths list)
  static Future<(TreeNode, Set<String>)> fromPaths(List<String> paths) async {
    final root = TreeNode(name: '', fullPath: '', isDirectory: true);
    final pathsSet = paths.toSet();
    final defaultCollapsed = <String>{};

    for (final path in paths) {
      final parts = path.split(Platform.pathSeparator).where((p) => p.isNotEmpty).toList();
      var current = root;

      for (var i = 0; i < parts.length; i++) {
        final part = parts[i];
        final isLast = i == parts.length - 1;
        final partialPath = Platform.pathSeparator + parts.sublist(0, i + 1).join(Platform.pathSeparator);

        if (!current.children.containsKey(part)) {
          var nodeIsDirectory = !isLast;
          if (isLast) {
            nodeIsDirectory = await FileSystemEntity.isDirectory(partialPath);
          }

          current.children[part] = TreeNode(
            name: part,
            fullPath: partialPath,
            isDirectory: nodeIsDirectory,
          );

          // If this is a leaf node (in original paths) and it's a directory,
          // collapse it by default since it represents an entire directory deletion
          if (isLast && nodeIsDirectory && pathsSet.contains(partialPath)) {
            defaultCollapsed.add(partialPath);
          }
        } else if (!isLast) {
          current.children[part]!.isDirectory = true;
        }
        current = current.children[part]!;
      }
    }

    return (root, defaultCollapsed);
  }
}

/// Displays a list of file paths as an expandable tree structure
class PathTreeView extends StatefulWidget {
  final List<String> paths;

  const PathTreeView({super.key, required this.paths});

  @override
  State<PathTreeView> createState() => _PathTreeViewState();
}

class _PathTreeViewState extends State<PathTreeView> {
  Set<String> _collapsed = {};
  TreeNode? _root;

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  @override
  void didUpdateWidget(PathTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paths != widget.paths) {
      _loadTree();
    }
  }

  Future<void> _loadTree() async {
    final (root, defaultCollapsed) = await TreeNode.fromPaths(widget.paths);
    if (mounted) {
      setState(() {
        _root = root;
        _collapsed = defaultCollapsed;
      });
    }
  }

  void _toggle(String path) {
    setState(() {
      if (_collapsed.contains(path)) {
        _collapsed.remove(path);
      } else {
        _collapsed.add(path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_root == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildNodeChildren(_root!, ''),
    );
  }

  List<Widget> _buildNodeChildren(TreeNode node, String prefix) {
    final widgets = <Widget>[];
    final children = node.children.values.toList()..sort((a, b) => a.name.compareTo(b.name));

    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final isLast = i == children.length - 1;
      final connector = isLast ? '└── ' : '├── ';
      final childPrefix = isLast ? '    ' : '│   ';
      final isExpanded = !_collapsed.contains(child.fullPath);

      widgets.add(
        _PathTreeItem(
          prefix: prefix,
          connector: connector,
          name: child.name,
          isDirectory: child.shouldShowAsDirectory,
          isExpanded: isExpanded,
          onToggle: child.children.isNotEmpty ? () => _toggle(child.fullPath) : null,
        ),
      );

      if (child.children.isNotEmpty && isExpanded) {
        widgets.addAll(_buildNodeChildren(child, '$prefix$childPrefix'));
      }
    }

    return widgets;
  }
}

class _PathTreeItem extends StatefulWidget {
  final String prefix;
  final String connector;
  final String name;
  final bool isDirectory;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const _PathTreeItem({
    required this.prefix,
    required this.connector,
    required this.name,
    required this.isDirectory,
    required this.isExpanded,
    this.onToggle,
  });

  @override
  State<_PathTreeItem> createState() => _PathTreeItemState();
}

class _PathTreeItemState extends State<_PathTreeItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final showToggle = _hovering && widget.onToggle != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.onToggle != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              SizedBox(
                width: 14,
                child: showToggle
                    ? SailText.secondary12(
                        widget.isExpanded ? '−' : '+',
                        monospace: true,
                      )
                    : null,
              ),
              Expanded(
                child: SailText.secondary12(
                  '${widget.prefix}${widget.connector}${widget.name}${widget.isDirectory ? Platform.pathSeparator : ''}',
                  monospace: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
