import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/content_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/cover_image.dart';

@RoutePage()
class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LearnPageViewModel>.reactive(
      viewModelBuilder: () => LearnPageViewModel(),
      builder: (context, model, child) {
        return QtPage(
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ArticleGroupCarousel(viewModel: model),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LearnPageViewModel extends BaseViewModel {
  final ContentProvider _contentProvider = GetIt.I.get<ContentProvider>();

  List<ArticleGroup> get groups => _contentProvider.groups;
  bool get isLoading => groups.isEmpty;

  LearnPageViewModel() {
    _contentProvider.addListener(notifyListeners);
    _contentProvider.load();
  }

  @override
  void dispose() {
    _contentProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class ArticleGroupCarousel extends StatefulWidget {
  final LearnPageViewModel viewModel;

  const ArticleGroupCarousel({
    super.key,
    required this.viewModel,
  });

  @override
  State<ArticleGroupCarousel> createState() => _ArticleGroupCarouselState();
}

class _ArticleGroupCarouselState extends State<ArticleGroupCarousel> {
  @override
  Widget build(BuildContext context) {
    final groups = widget.viewModel.groups;

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
  bool _isAtEnd = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _updateEdges(ScrollMetrics metrics) {
    final isScrolled = metrics.pixels > metrics.minScrollExtent;
    final isAtEnd = metrics.pixels >= metrics.maxScrollExtent;
    if (isScrolled != _isScrolled || isAtEnd != _isAtEnd) {
      setState(() {
        _isScrolled = isScrolled;
        _isAtEnd = isAtEnd;
      });
    }
    return false;
  }

  void _scroll(double offset) {
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.group.articles.isEmpty) {
      return const SizedBox.shrink();
    }

    if (SailStyleValues.phoneLayout(context)) {
      return _ArticleGroupList(group: widget.group);
    }

    final showArrows = widget.group.articles.length > 3;
    final scrollDistance = MediaQuery.of(context).size.width >= 768 ? 800.0 : 400.0;
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding40),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: context.sailTheme.chrome.radiusLarge,
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
                NotificationListener<ScrollMetricsNotification>(
                  onNotification: (notification) => _updateEdges(notification.metrics),
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) => _updateEdges(notification.metrics),
                    child: ListView.separated(
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
                              color: theme.colors.backgroundSecondary,
                              borderRadius: context.sailTheme.chrome.radiusLarge,
                            ),
                            child: ArticleCard(
                              groupTitle: widget.group.title,
                              article: widget.group.articles[index],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
                                  theme.colors.background,
                                  theme.colors.background.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                          _ScrollButton(
                            onPressed: () => _scroll(-scrollDistance),
                            isLeft: true,
                          ),
                        ],
                      ),
                    ),
                  if (!_isAtEnd)
                    Positioned(
                      right: 0,
                      top: 100,
                      child: Row(
                        children: [
                          _ScrollButton(
                            onPressed: () => _scroll(scrollDistance),
                            isLeft: false,
                          ),
                          Container(
                            width: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  theme.colors.background,
                                  theme.colors.background.withValues(alpha: 0),
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

class _ArticleGroupList extends StatelessWidget {
  final ArticleGroup group;

  const _ArticleGroupList({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary18(group.title, bold: true),
        if (group.subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          SailText.secondary13(group.subtitle),
        ],
        const SizedBox(height: SailStyleValues.padding12),
        SailStatList(
          children: [
            for (final article in group.articles) _ArticleRow(groupTitle: group.title, article: article),
          ],
        ),
      ],
    );
  }
}

class _ArticleRow extends StatelessWidget {
  final String groupTitle;
  final Article article;

  const _ArticleRow({required this.groupTitle, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final background = article.background;
    return SailTappable(
      onTap: () async => showArticleDetails(context, article, groupTitle),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: theme.chrome.radius,
              child: SizedBox.square(
                dimension: 48,
                child: CoverImage(
                  background != null
                      ? AssetImage(background)
                      : AssetImage(SailPNGAsset.articleBeginner.toAssetPath(), package: 'sail_ui'),
                ),
              ),
            ),
            const SizedBox(width: SailStyleValues.padding12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SailText.primary15(article.title),
                  const SizedBox(height: 2),
                  SailText.secondary12('Read time: ${expectedReadTime(article.markdown)}'),
                ],
              ),
            ),
            const SizedBox(width: SailStyleValues.padding08),
            SailSVG.fromAsset(SailSVGAsset.chevronRight, width: 12, color: theme.colors.textTertiary),
          ],
        ),
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
      background: article.background,
      onPressed: () => showArticleDetails(context, article, groupTitle),
    );
  }
}

class StoryCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool largeIcon;
  final String? background;
  final VoidCallback onPressed;

  const StoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.largeIcon = false,
    this.background,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  @override
  Widget build(BuildContext context) {
    return SailTappable(
      onTap: () async => widget.onPressed(),
      borderRadius: context.sailTheme.chrome.radiusLarge,
      child: _StoryCardContent(
        title: widget.title,
        subtitle: widget.subtitle,
        largeIcon: widget.largeIcon,
        background: widget.background,
      ),
    );
  }
}

class _StoryCardContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool largeIcon;
  final String? background;

  const _StoryCardContent({
    required this.title,
    required this.subtitle,
    required this.largeIcon,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CoverImage(
              background != null
                  ? AssetImage(background!)
                  : AssetImage(SailPNGAsset.articleBeginner.toAssetPath(), package: 'sail_ui'),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SailText.secondary12(
                        subtitle,
                      ),
                    ],
                  ),
                ),
                SailSVG.fromAsset(SailSVGAsset.chevronRight, color: SailTheme.of(context).colors.icon),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLeft;

  const _ScrollButton({
    required this.onPressed,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.text,
        borderRadius: context.sailTheme.chrome.radius,
      ),
      child: SailTappable(
        onTap: () async => onPressed(),
        borderRadius: context.sailTheme.chrome.radius,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: SailSVG.fromAsset(
            isLeft ? SailSVGAsset.chevronLeft : SailSVGAsset.chevronRight,
            width: 16,
            color: theme.colors.background,
          ),
        ),
      ),
    );
  }
}
