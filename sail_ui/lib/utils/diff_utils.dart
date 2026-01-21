enum DiffLineType {
  added,
  removed,
  unchanged,
}

class DiffLine {
  final String content;
  final DiffLineType type;

  DiffLine(this.content, this.type);
}

List<DiffLine> computeDiff(List<String> original, List<String> working) {
  final List<DiffLine> result = [];
  final lcs = _longestCommonSubsequence(original, working);

  int i = 0;
  int j = 0;
  int k = 0;

  while (i < original.length || j < working.length) {
    if (k < lcs.length && i < original.length && original[i] == lcs[k]) {
      if (j < working.length && working[j] == lcs[k]) {
        result.add(DiffLine('  ${original[i]}', DiffLineType.unchanged));
        i++;
        j++;
        k++;
      } else {
        result.add(DiffLine('+ ${working[j]}', DiffLineType.added));
        j++;
      }
    } else if (k < lcs.length && j < working.length && working[j] == lcs[k]) {
      result.add(DiffLine('- ${original[i]}', DiffLineType.removed));
      i++;
    } else {
      if (i < original.length && j < working.length) {
        result.add(DiffLine('- ${original[i]}', DiffLineType.removed));
        result.add(DiffLine('+ ${working[j]}', DiffLineType.added));
        i++;
        j++;
      } else if (i < original.length) {
        result.add(DiffLine('- ${original[i]}', DiffLineType.removed));
        i++;
      } else if (j < working.length) {
        result.add(DiffLine('+ ${working[j]}', DiffLineType.added));
        j++;
      }
    }
  }

  return result;
}

List<String> _longestCommonSubsequence(List<String> a, List<String> b) {
  final int m = a.length;
  final int n = b.length;

  final List<List<int>> dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

  for (int i = 1; i <= m; i++) {
    for (int j = 1; j <= n; j++) {
      if (a[i - 1] == b[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
      } else {
        dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
      }
    }
  }

  final List<String> lcs = [];
  int i = m, j = n;

  while (i > 0 && j > 0) {
    if (a[i - 1] == b[j - 1]) {
      lcs.insert(0, a[i - 1]);
      i--;
      j--;
    } else if (dp[i - 1][j] > dp[i][j - 1]) {
      i--;
    } else {
      j--;
    }
  }

  return lcs;
}
