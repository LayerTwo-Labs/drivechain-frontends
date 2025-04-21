import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/content_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            ArticleGroupCarousel(),
          ],
        ),
      ),
    );
  }
}

class ArticleGroupCarousel extends StatefulWidget {
  const ArticleGroupCarousel({super.key});

  @override
  State<ArticleGroupCarousel> createState() => _ArticleGroupCarouselState();
}

class _ArticleGroupCarouselState extends State<ArticleGroupCarousel> {
  @override
  Widget build(BuildContext context) {
    final articleProvider = GetIt.I.get<ContentProvider>();
    final groups = articleProvider.groups;

    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return SailColumn(
      spacing: SailStyleValues.padding20,
      children: [
        for (final group in groups)
          ArticleGroupCard(
            key: ValueKey(group.title),
            group: group,
          ),
      ],
    );
  }
}

class ArticleGroupCard extends StatefulWidget {
  final ArticleGroup group;

  const ArticleGroupCard({
    super.key,
    required this.group,
  });

  @override
  State<ArticleGroupCard> createState() => _ArticleGroupCardState();
}

class _ArticleGroupCardState extends State<ArticleGroupCard> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.position.pixels <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _scroll(double offset) {
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildScrollButton({
    required VoidCallback onPressed,
    required bool isLeft,
    required SailThemeData theme,
  }) {
    return Material(
      color: Colors.black,
      borderRadius: SailStyleValues.borderRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: SailStyleValues.borderRadius,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            isLeft ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.group.articles.isEmpty) {
      return const SizedBox.shrink();
    }

    final showArrows = widget.group.articles.length > 3;
    final scrollDistance = MediaQuery.of(context).size.width >= 768 ? 800.0 : 400.0;
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding40),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadiusLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary24(
                  widget.group.title,
                  bold: true,
                ),
                const SailSpacing(5),
                SailText.secondary15(widget.group.subtitle),
                const SailSpacing(SailStyleValues.padding20),
              ],
            ),
          ),
          SizedBox(
            height: 280,
            child: Stack(
              children: [
                ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding20),
                  itemCount: widget.group.articles.length,
                  separatorBuilder: (context, index) => const SizedBox(width: SailStyleValues.padding20),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width >= 768 ? 400 : 280,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colors.background,
                          borderRadius: SailStyleValues.borderRadiusLarge,
                        ),
                        child: ArticleCard(
                          groupTitle: widget.group.title,
                          article: widget.group.articles[index],
                        ),
                      ),
                    );
                  },
                ),
                if (showArrows) ...[
                  if (_isScrolled)
                    Positioned(
                      left: 0,
                      top: 100,
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  theme.colors.backgroundSecondary,
                                  theme.colors.backgroundSecondary.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                          _buildScrollButton(
                            onPressed: () => _scroll(-scrollDistance),
                            isLeft: true,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    right: 0,
                    top: 100,
                    child: Row(
                      children: [
                        _buildScrollButton(
                          onPressed: () => _scroll(scrollDistance),
                          isLeft: false,
                          theme: theme,
                        ),
                        Container(
                          width: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                theme.colors.backgroundSecondary,
                                theme.colors.backgroundSecondary.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final String groupTitle;
  final Article article;

  const ArticleCard({
    super.key,
    required this.groupTitle,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return StoryCard(
      title: article.title,
      subtitle: 'Read time: ${expectedReadTime(article.markdown)}',
      largeIcon: true,
      onPressed: () => showArticleDetails(context, article, groupTitle),
    );
  }
}

class StoryCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool largeIcon;
  final VoidCallback onPressed;

  const StoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.largeIcon = false,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: SailStyleValues.borderRadiusLarge,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: SailStyleValues.borderRadiusLarge,
        child: _StoryCardContent(
          title: widget.title,
          subtitle: widget.subtitle,
          largeIcon: widget.largeIcon,
        ),
      ),
    );
  }
}

class _StoryCardContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool largeIcon;

  const _StoryCardContent({
    required this.title,
    required this.subtitle,
    required this.largeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SailSVG.png(
              SailPNGAsset.articleBeginner,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SailStyleValues.padding16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary15(
                        title,
                        bold: true,
                      ),
                      SailText.secondary12(
                        subtitle,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: SailTheme.of(context).colors.icon,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
