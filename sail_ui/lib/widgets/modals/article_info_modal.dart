import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sail_ui/sail_ui.dart';

void showArticleDetails(BuildContext context, Article article, String groupTitle) {
  final theme = SailTheme.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.colors.backgroundSecondary,
    useSafeArea: true,
    builder: (context) {
      return SelectionArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: SailStyleValues.padding20,
                right: SailStyleValues.padding20,
                top: SailStyleValues.padding20,
                bottom: SailStyleValues.padding10,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colors.background,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 80), // Balance the header
                  Expanded(
                    child: Center(
                      child: SailText.primary15(groupTitle, bold: true),
                    ),
                  ),
                  SizedBox(
                    width: 80, // Match left spacing
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SailButton(
                        label: 'Done',
                        variant: ButtonVariant.ghost,
                        onPressed: () async => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: SailColumn(
                  spacing: 0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content below image - with padding
                    SailPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SailStyleValues.padding20,
                        vertical: SailStyleValues.padding20,
                      ),
                      child: SailColumn(
                        spacing: 0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          SailText.primary24(
                            article.title,
                            bold: true,
                          ),
                          SailSpacing(SailStyleValues.padding20),
                          // Content
                          MarkdownBody(
                            data: article.markdown,
                            styleSheet: MarkdownStyleSheet(
                              p: SailStyleValues.fifteen.copyWith(color: theme.colors.text),
                              h1: SailStyleValues.twentyFour.copyWith(color: theme.colors.text),
                              h2: SailStyleValues.twentyFour.copyWith(color: theme.colors.text),
                              h3: SailStyleValues.twenty.copyWith(color: theme.colors.text),
                              listBullet: SailStyleValues.fifteen.copyWith(color: theme.colors.text),
                              listBulletPadding: const EdgeInsets.only(bottom: 20),
                              pPadding: const EdgeInsets.only(bottom: 20),
                              h1Padding: const EdgeInsets.only(top: SailStyleValues.padding16, bottom: 0),
                              h2Padding: const EdgeInsets.only(top: SailStyleValues.padding16, bottom: 0),
                              h3Padding: const EdgeInsets.only(top: SailStyleValues.padding16, bottom: 0),
                              blockquoteDecoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: SailStyleValues.borderRadius,
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: SailColorScheme.blackLighter,
                                borderRadius: SailStyleValues.borderRadius,
                              ),
                              code: SailStyleValues.thirteen.copyWith(
                                color: SailColorScheme.white,
                                fontFamily: 'SourceCodePro',
                              ),
                              codeblockPadding: const EdgeInsets.all(16),
                            ),
                            onTapLink: (_, href, __) async {
                              if (href == null) return;
                              await launchUrl(
                                Uri.parse(href),
                              );
                            },
                          ),
                          const SailSpacing(SailStyleValues.padding40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

String expectedReadTime(String markdown) {
  final words = markdown.split(' ').length;
  final minutes = (words / 200).ceil();
  return '$minutes min';
}

class Article {
  final String title;
  final String markdown;
  final String filename;

  Article({
    required this.title,
    required this.markdown,
    required this.filename,
  });
}

class ArticleGroup {
  final String title;
  final String subtitle;
  final List<Article> articles;

  ArticleGroup({
    required this.title,
    required this.subtitle,
    required this.articles,
  });
}
