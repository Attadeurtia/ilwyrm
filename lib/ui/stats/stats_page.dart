import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/library_stats.dart';
import '../../l10n/l10n.dart';
import '../theme_extensions.dart';

/// Statistiques de lecture : chiffres clés de la bibliothèque, puis le détail
/// d'une année (choisie dans la rangée de filtres, qui porte sur toute la
/// section « Lectures ») et les auteurs les plus lus.
class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  /// Année choisie ; null = l'année en cours si elle a des lectures, sinon la
  /// plus récente.
  int? _year;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statsAsync = ref.watch(libraryStatsProvider);
    final stats = statsAsync.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: stats == null
          ? Center(
              child: statsAsync.hasError
                  ? Text(l10n.genericError('${statsAsync.error}'))
                  : const CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _SectionTitle(l10n.statsLibrarySection),
                _LibraryOverview(stats: stats),
                const SizedBox(height: 24),
                _SectionTitle(l10n.statsReadingSection),
                ..._readingSection(context, stats),
              ],
            ),
    );
  }

  List<Widget> _readingSection(BuildContext context, LibraryStats stats) {
    final l10n = context.l10n;
    final years = stats.years;
    if (years.isEmpty) {
      return [
        Text(
          l10n.statsNoReadingYet,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ];
    }

    final currentYear = DateTime.now().year;
    final year =
        _year ?? (years.contains(currentYear) ? currentYear : years.first);
    final yearStats = stats.yearStats(year);
    final locale = l10n.localeName;
    final perYear = stats.booksPerYear;
    // Année précédente comparable seulement si elle fait partie de l'historique.
    final previous = perYear.where((e) => e.$1 == year - 1).firstOrNull;

    return [
      // Filtre : une seule rangée, au-dessus de tout ce qu'il concerne.
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final y in years)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$y'),
                  selected: y == year,
                  onSelected: (_) => setState(() => _year = y),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _HeroFigure(
        value: yearStats.booksRead,
        label: l10n.statsHeroLabel(yearStats.booksRead, year),
        delta: previous == null
            ? null
            : (value: yearStats.booksRead - previous.$2, year: previous.$1),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _StatTile(
              label: l10n.statsPagesRead,
              value: yearStats.pagesRead == null
                  ? '—'
                  : NumberFormat.decimalPattern(
                      locale,
                    ).format(yearStats.pagesRead),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatTile(
              label: l10n.statsAverageDuration,
              value: yearStats.averageDays == null
                  ? '—'
                  : l10n.durationDays(yearStats.averageDays!),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _ColumnChartCard(
        title: l10n.statsPerMonthTitle,
        labelHeader: l10n.statsMonthColumn,
        values: yearStats.perMonth,
        axisLabels: [
          for (var m = 1; m <= 12; m++)
            DateFormat('MMMMM', locale).format(DateTime(2000, m)),
        ],
        fullLabels: [
          for (var m = 1; m <= 12; m++)
            DateFormat.MMMM(locale).format(DateTime(2000, m)),
        ],
      ),
      if (perYear.length >= 2) ...[
        const SizedBox(height: 16),
        // Les 10 dernières années au plus : au-delà, les barres deviennent
        // trop étroites pour être lues.
        Builder(
          builder: (context) {
            final recent = perYear.length > 10
                ? perYear.sublist(perYear.length - 10)
                : perYear;
            return _ColumnChartCard(
              title: l10n.statsPerYearTitle,
              labelHeader: l10n.statsYearColumn,
              values: [for (final e in recent) e.$2],
              axisLabels: [for (final e in recent) "'${e.$1 % 100}"],
              fullLabels: [for (final e in recent) '${e.$1}'],
              highlighted: recent.indexWhere((e) => e.$1 == year),
            );
          },
        ),
      ],
      if (stats.topAuthors.isNotEmpty) ...[
        const SizedBox(height: 24),
        _SectionTitle(l10n.statsTopAuthorsTitle),
        _HorizontalBars(entries: stats.topAuthors.take(5).toList()),
      ],
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Chiffres clés de toute la bibliothèque : une rangée de tuiles.
class _LibraryOverview extends StatelessWidget {
  const _LibraryOverview({required this.stats});

  final LibraryStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tiles = [
      (l10n.statsTotalBooks, stats.total),
      (l10n.tabToRead, stats.toRead),
      (l10n.tabReading, stats.reading),
      (l10n.tabRead, stats.read),
      (l10n.favoritesFilter, stats.favorites),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final width = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final (label, value) in tiles)
              SizedBox(
                width: width,
                child: _StatTile(label: label, value: '$value'),
              ),
          ],
        );
      },
    );
  }
}

/// Tuile chiffrée : la valeur d'abord, son libellé dessous.
class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Le chiffre de l'année (grand, même police que le reste), avec l'écart par
/// rapport à l'année précédente.
class _HeroFigure extends StatelessWidget {
  const _HeroFigure({required this.value, required this.label, this.delta});

  final int value;
  final String label;
  final ({int value, int year})? delta;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final d = delta;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            '$value',
            key: ValueKey(value),
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.titleMedium?.copyWith(color: muted)),
        if (d != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              // Plus de lectures = bonne nouvelle (couleur de succès) ; moins,
              // simplement neutre : ce n'est pas une erreur.
              Icon(
                d.value > 0
                    ? Icons.trending_up
                    : d.value < 0
                    ? Icons.trending_down
                    : Icons.trending_flat,
                size: 18,
                color: d.value > 0 ? context.semanticColors.success : muted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  d.value == 0
                      ? l10n.statsSameAsYear(d.year)
                      : l10n.statsDeltaVsYear(
                          d.value > 0 ? '+${d.value}' : '${d.value}',
                          d.year,
                        ),
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Carte d'un histogramme en colonnes (une seule série, donc une seule couleur
/// et pas de légende : le titre dit ce qui est tracé). On touche une barre
/// pour lire sa valeur ; une vue tableau donne toutes les valeurs.
class _ColumnChartCard extends StatefulWidget {
  const _ColumnChartCard({
    required this.title,
    required this.labelHeader,
    required this.values,
    required this.axisLabels,
    required this.fullLabels,
    this.highlighted = -1,
  });

  final String title;

  /// En-tête de la colonne des libellés dans la vue tableau.
  final String labelHeader;
  final List<int> values;

  /// Libellés courts sous les barres, et complets (lecture, tableau).
  final List<String> axisLabels;
  final List<String> fullLabels;

  /// Barre mise en avant par défaut (ex. l'année choisie), -1 pour aucune.
  final int highlighted;

  @override
  State<_ColumnChartCard> createState() => _ColumnChartCardState();
}

class _ColumnChartCardState extends State<_ColumnChartCard> {
  int? _selected;
  bool _showTable = false;

  @override
  void didUpdateWidget(_ColumnChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Autre année affichée : la barre touchée ne correspond plus à rien.
    if (!listEquals(oldWidget.values, widget.values)) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final selected = _selected ?? (widget.highlighted >= 0 ? widget.highlighted : null);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(widget.title, style: theme.textTheme.titleSmall),
              ),
              IconButton(
                tooltip: _showTable ? l10n.statsShowChart : l10n.statsShowTable,
                icon: Icon(
                  _showTable ? Icons.bar_chart : Icons.table_rows_outlined,
                ),
                onPressed: () => setState(() => _showTable = !_showTable),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showTable
                  ? _table(context)
                  : Column(
                      key: const ValueKey('chart'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _readout(context, selected),
                        const SizedBox(height: 8),
                        _ColumnChart(
                          values: widget.values,
                          labels: widget.axisLabels,
                          semanticLabels: [
                            for (var i = 0; i < widget.values.length; i++)
                              l10n.fieldLabelPrefix(widget.fullLabels[i]) +
                                  l10n.statsBooksCount(widget.values[i]),
                          ],
                          selected: selected,
                          onSelect: (i) => setState(
                            () => _selected = _selected == i ? null : i,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Valeur de la barre touchée (la valeur d'abord, son libellé ensuite), ou
  /// l'invite à toucher une barre.
  Widget _readout(BuildContext context, int? selected) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    if (selected == null) {
      return Text(
        context.l10n.statsChartHint,
        style: theme.textTheme.bodySmall?.copyWith(color: muted),
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: context.l10n.statsBooksCount(widget.values[selected]),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: ' · ${widget.fullLabels[selected]}',
            style: TextStyle(color: muted),
          ),
        ],
      ),
      style: theme.textTheme.bodyMedium,
    );
  }

  Widget _table(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final header = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    // Chiffres à chasse fixe : ils s'alignent verticalement dans la colonne.
    const tabular = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);
    return Column(
      key: const ValueKey('table'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(child: Text(widget.labelHeader, style: header)),
              Text(l10n.statsBooksColumn, style: header),
            ],
          ),
        ),
        const Divider(height: 1),
        for (var i = 0; i < widget.values.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(child: Text(widget.fullLabels[i])),
                Text('${widget.values[i]}', style: tabular),
              ],
            ),
          ),
      ],
    );
  }
}

/// Histogramme en colonnes : barres fines (24 px max), bout arrondi de 4 px,
/// droites sur la ligne de base ; grille en traits fins discrets. La barre
/// touchée ressort, les autres s'estompent. Toute la colonne (barre et
/// libellé) réagit au toucher, bien plus large que la barre elle-même.
class _ColumnChart extends StatelessWidget {
  const _ColumnChart({
    required this.values,
    required this.labels,
    required this.semanticLabels,
    required this.selected,
    required this.onSelect,
  });

  final List<int> values;
  final List<String> labels;
  final List<String> semanticLabels;
  final int? selected;
  final ValueChanged<int> onSelect;

  static const double _plotHeight = 140;
  static const double _headroom = 20; // place pour la valeur au-dessus
  static const double _axisBand = 22;
  static const double _gutter = 24;

  /// Hauteur de la barre maximale : de la ligne de base (1 px) au trait du
  /// maximum.
  static const double _barArea = _plotHeight - 1 - _headroom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final maxValue = values.fold<int>(0, math.max);
    final top = math.max(1, maxValue);
    // Valeur écrite sur la barre la plus haute (et sur la barre touchée) :
    // l'axe et la lecture au toucher donnent les autres.
    final maxIndex = maxValue > 0 ? values.indexOf(maxValue) : -1;

    Widget hairline() => Container(height: 1, color: scheme.outlineVariant);

    return SizedBox(
      height: _plotHeight + _axisBand,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graduations : 0 et le maximum (nombres entiers de livres).
          SizedBox(
            width: _gutter,
            height: _plotHeight,
            child: Stack(
              // Le « 0 » est centré sur la ligne de base, donc déborde un peu.
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: 6,
                  top: _headroom - 7,
                  child: Text('$top', style: muted),
                ),
                Positioned(
                  right: 6,
                  bottom: -7,
                  child: Text('0', style: muted),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(left: 0, right: 0, top: _headroom, child: hairline()),
                Positioned(
                  left: 0,
                  right: 0,
                  top: _plotHeight - 1,
                  child: hairline(),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < values.length; i++)
                      Expanded(
                        child: _slot(
                          context,
                          i,
                          barHeight: _barArea * values[i] / top,
                          showValue: i == maxIndex || i == selected,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slot(
    BuildContext context,
    int i, {
    required double barHeight,
    required bool showValue,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isSelected = selected == i;
    final dimmed = selected != null && !isSelected;
    final showLabel = labels.length <= 12 || i.isEven;

    return Semantics(
      label: semanticLabels[i],
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(i),
        child: Column(
          children: [
            SizedBox(
              height: _plotHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showValue && values[i] > 0)
                    Text(
                      '${values[i]}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 2),
                  LayoutBuilder(
                    builder: (context, constraints) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: math.min(24, constraints.maxWidth * 0.6),
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: dimmed
                            ? scheme.primary.withValues(alpha: 0.35)
                            : scheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 1), // la ligne de base reste visible
                ],
              ),
            ),
            SizedBox(
              height: _axisBand,
              child: Center(
                child: Text(
                  showLabel ? labels[i] : '',
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barres horizontales (auteurs) : une seule couleur, le nombre au bout de la
/// barre, le nom en texte normal.
class _HorizontalBars extends StatelessWidget {
  const _HorizontalBars({required this.entries});

  final List<(String, int)> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxCount = entries.map((e) => e.$2).fold<int>(1, math.max);

    return Column(
      children: [
        for (final (name, count) in entries)
          Semantics(
            label:
                context.l10n.fieldLabelPrefix(name) +
                context.l10n.statsBooksCount(count),
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const valueWidth = 28.0;
                        final available = constraints.maxWidth - valueWidth;
                        return Row(
                          children: [
                            Container(
                              width: math.max(4, available * count / maxCount),
                              height: 12,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$count',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
