import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sail_ui/sail_ui.dart';

/// Dialog for selecting wallet background SVG
class SelectBackgroundDialog extends StatelessWidget {
  final String? currentBackground;
  final List<String> takenBackgrounds;

  const SelectBackgroundDialog({
    super.key,
    this.currentBackground,
    this.takenBackgrounds = const [],
  });

  static const List<BackgroundOption> _backgrounds = [
    BackgroundOption(name: 'Bitcoin', svg: 'background_orange.svg'),
    BackgroundOption(name: 'Forest', svg: 'background_forest.svg'),
    BackgroundOption(name: 'Fog', svg: 'background_fog.svg'),
    BackgroundOption(name: 'Ice', svg: 'background_ice.svg'),
    BackgroundOption(name: 'Ocean', svg: 'background_ocean.svg'),
    BackgroundOption(name: 'Northern', svg: 'background_northern.svg'),
    BackgroundOption(name: 'Northern Blue', svg: 'background_northern_blue.svg'),
    BackgroundOption(name: 'Northern Green', svg: 'background_northern_green.svg'),
    BackgroundOption(name: 'Northern Dark', svg: 'background_northern_dark_green.svg'),
    BackgroundOption(name: 'Sphere', svg: 'background_sphere.svg'),
    BackgroundOption(name: 'Contact', svg: 'background_contact.svg'),
    BackgroundOption(name: 'Hooked', svg: 'background_hooked.svg'),
    BackgroundOption(name: 'Swirl Green', svg: 'background_swirl_green.svg'),
    BackgroundOption(name: 'Swirl Orange', svg: 'background_swirl_orange.svg'),
    BackgroundOption(name: 'Swirl Purple', svg: 'background_swirl_purple.svg'),
    BackgroundOption(name: 'Sky', svg: 'background_blue.svg'),
    BackgroundOption(name: 'Purple', svg: 'background_purple.svg'),
    BackgroundOption(name: 'Sunrise', svg: 'background_sunrise.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: SailCard(
          title: 'Select Background',
          subtitle: 'Choose a background for your wallet',
          withCloseButton: true,
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding12,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < (_backgrounds.length / 3).ceil(); i++)
                  SailRow(
                    spacing: SailStyleValues.padding12,
                    children: [
                      for (int j = 0; j < 3; j++)
                        if (i * 3 + j < _backgrounds.length)
                          Expanded(
                            child: _BackgroundTile(
                              background: _backgrounds[i * 3 + j],
                              isTaken: takenBackgrounds.contains(_backgrounds[i * 3 + j].svg),
                              isSelected: currentBackground == _backgrounds[i * 3 + j].svg,
                              onTap: () {
                                Navigator.of(context).pop(_backgrounds[i * 3 + j].svg);
                              },
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BackgroundOption {
  final String name;
  final String svg;

  const BackgroundOption({required this.name, required this.svg});
}

class _BackgroundTile extends StatefulWidget {
  final BackgroundOption background;
  final bool isTaken;
  final bool isSelected;
  final VoidCallback onTap;

  const _BackgroundTile({
    required this.background,
    required this.isTaken,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_BackgroundTile> createState() => _BackgroundTileState();
}

class _BackgroundTileState extends State<_BackgroundTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    const ratio = 375.0 / 435;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isTaken ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isTaken ? null : widget.onTap,
        child: Opacity(
          opacity: widget.isTaken ? 0.5 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? theme.colors.primary
                    : _isHovered
                    ? theme.colors.primary.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: widget.isSelected ? 3 : 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: ratio,
                child: Stack(
                  children: [
                    SvgPicture.asset(
                      'packages/sail_ui/assets/svgs/${widget.background.svg}',
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Center(
                      child: widget.isTaken
                          ? SailText.primary12(
                              'Already in use',
                              color: Colors.white.withValues(alpha: 0.8),
                            )
                          : widget.isSelected
                          ? SailText.primary12(
                              widget.background.name,
                              color: Colors.white,
                              bold: true,
                            )
                          : SailText.primary12(
                              widget.background.name,
                              color: Colors.white,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
