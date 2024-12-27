import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'dart:convert';
import 'package:bitwindow/pages/tools/hash_calculator_viewmodel.dart';

@RoutePage()
class HashCalculatorPage extends StatefulWidget {
  const HashCalculatorPage({super.key});

  @override
  State<HashCalculatorPage> createState() => _HashCalculatorPageState();
}

class _HashCalculatorPageState extends State<HashCalculatorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HashCalculatorViewModel>.reactive(
      viewModelBuilder: () => HashCalculatorViewModel(),
      builder: (context, viewModel, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: _tabController,
              labelPadding: EdgeInsets.zero,
              tabs: const [
                Tab(
                  child: Text('Regular', style: TextStyle(fontSize: 16)),
                ),
                Tab(
                  child: Text('HMAC', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            ValueListenableBuilder<double>(
              valueListenable: _tabController.animation!,
              builder: (context, value, child) {
                final isHmacTab = value.round() == 1;
                final hasOutput = isHmacTab ? viewModel.getHmacOutput() != null : viewModel.getBasicOutput() != null;
                return SizedBox(
                  height: hasOutput ? (isHmacTab ? 180 : 250) : (isHmacTab ? 120 : 80),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        child: _buildRegularTab(context, viewModel),
                      ),
                      SingleChildScrollView(
                        child: _buildHmacTab(context, viewModel),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRegularTab(BuildContext context, HashCalculatorViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: viewModel.basicInputController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter text',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: viewModel.clearBasic,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Text('Clear', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: viewModel.pasteFromClipboard,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Text('Paste', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Hex:', style: TextStyle(fontSize: 14)),
                  Switch(
                    value: viewModel.isHexMode,
                    onChanged: (_) => viewModel.toggleHexMode(),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (viewModel.getBasicOutput() != null)
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 0,
                mainAxisExtent: 56,
              ),
              itemCount: viewModel.getHashSections().length + 1,
              itemBuilder: (context, index) {
                if (index < viewModel.getHashSections().length) {
                  return _buildHashBox(context, viewModel.getHashSections()[index], viewModel);
                } else {
                  return _buildMoreBox(context, viewModel);
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMoreBox(BuildContext context, HashCalculatorViewModel viewModel) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovering = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovering = true),
          onExit: (_) => setState(() => isHovering = false),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showDecodeDetails(context, viewModel),
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Text(
                                'More',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_outlined, size: 16),
                                onPressed: () => _showDecodeDetails(context, viewModel),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'View details',
                              ),
                            ],
                          ),
                          Text(
                            'Decode • Hex • Bin',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isHovering)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              'View More',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHashBox(BuildContext context, HashSection section, HashCalculatorViewModel viewModel) {
    final hashValue = section.output.hex;
    final truncatedHash = hashValue.length > 8
        ? '${hashValue.substring(0, 4)}...${hashValue.substring(hashValue.length - 4)}'
        : hashValue;

    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovering = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovering = true),
          onExit: (_) => setState(() => isHovering = false),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showHashDetails(context, section, viewModel),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                section.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy_outlined, size: 16),
                                onPressed: () => viewModel.copyToClipboard(section.output.hex),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Copy hash',
                              ),
                            ],
                          ),
                          Text(
                            truncatedHash,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isHovering)
                Positioned.fill(
                  child: Material(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                    child: InkWell(
                      onTap: () => _showHashDetails(context, section, viewModel),
                      child: const Center(
                        child: Text(
                          'View More',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showHashDetails(BuildContext context, HashSection section, HashCalculatorViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        if (section.bitcoinUsage.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            section.bitcoinUsage,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: SailColumn(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Full Hash:',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_outlined, size: 16),
                                  onPressed: () => viewModel.copyToClipboard(section.output.hex),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Copy hash',
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              section.output.hex,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Binary:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              section.output.bin,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              maxLines: null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDecodeDetails(BuildContext context, HashCalculatorViewModel viewModel) {
    final str = viewModel.basicInputController.text;
    if (str.isEmpty) return;

    List<int> dataBytes = viewModel.isHexMode ? hexDecode(str) : utf8.encode(str);
    String decodeStr = viewModel.isHexMode ? String.fromCharCodes(dataBytes) : str;
    String hexStr = viewModel.isHexMode ? str.toLowerCase() : hexEncode(dataBytes);
    String binStr = hexToBinStr(hexStr);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'More',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: SailColumn(
                      spacing: 4,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Decode:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        SelectableText(
                          decodeStr,
                          style: const TextStyle(fontSize: 14),
                          maxLines: null,
                        ),
                        const Text(
                          'Hex:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        SelectableText(
                          hexStr,
                          style: const TextStyle(fontSize: 14),
                          maxLines: null,
                        ),
                        Text(
                          'Binary:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        SelectableText(
                          binStr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          maxLines: null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHmacTab(BuildContext context, HashCalculatorViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reduced padding
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: viewModel.hmacKeyController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Enter key',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: viewModel.clearHmac,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text('Clear', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Row(
                    children: [
                      const Text('Hex:', style: TextStyle(fontSize: 14)),
                      Switch(
                        value: viewModel.hmacIsHexMode,
                        onChanged: (_) => viewModel.toggleHmacHexMode(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: viewModel.hmacMessageController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Enter message',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => viewModel.pasteFromClipboard(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text('Paste', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (viewModel.getHmacOutput() != null)
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            constraints: const BoxConstraints(maxWidth: double.infinity),
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 0,
                childAspectRatio: 2.6,
                mainAxisExtent: 56,
              ),
              itemCount: 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHmacHashBox(
                    context,
                    'HMAC-SHA256',
                    viewModel.getHmacSha256(),
                    viewModel,
                  );
                } else {
                  return _buildHmacHashBox(
                    context,
                    'HMAC-SHA512',
                    viewModel.getHmacSha512(),
                    viewModel,
                  );
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHmacHashBox(
    BuildContext context,
    String title,
    HashOutput output,
    HashCalculatorViewModel viewModel,
  ) {
    final hashValue = output.hex;
    final truncatedHash = hashValue.length > 8
        ? '${hashValue.substring(0, 4)}...${hashValue.substring(hashValue.length - 4)}'
        : hashValue;

    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovering = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovering = true),
          onExit: (_) => setState(() => isHovering = false),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showHashDetails(
                      context,
                      HashSection(title, output, bitcoinUsage: ''),
                      viewModel,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy_outlined, size: 16),
                                onPressed: () => viewModel.copyToClipboard(hashValue),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Copy hash',
                              ),
                            ],
                          ),
                          Text(
                            truncatedHash,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isHovering)
                Positioned.fill(
                  child: Material(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                    child: InkWell(
                      onTap: () => _showHashDetails(
                        context,
                        HashSection(title, output, bitcoinUsage: ''),
                        viewModel,
                      ),
                      child: const Center(
                        child: Text(
                          'View More',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}