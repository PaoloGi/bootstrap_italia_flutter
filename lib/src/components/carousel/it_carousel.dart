import 'dart:async';

import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../a11y/it_icon_action.dart';
import '../../l10n/it_localizations.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../button/it_button.dart';

/// The named carousel presets, matching `CONFIGS` in `design-react-kit`'s
/// `Carousel.tsx`.
///
/// Upstream a carousel is not configured field by field: the caller picks a
/// `type` and the kit supplies `perPage`, `gap`, `padding` and `arrows` for
/// every breakpoint. Keeping that shape means a Flutter caller cannot invent a
/// layout the design system does not have.
enum ItCarouselType {
  /// `landscape` — one slide at every width.
  landscape,

  /// `landscape-three-cols` — 3 / 2 / 1 by width, no arrows.
  landscapeThreeCols,

  /// `landscape-three-cols-arrows` — as above, with arrows.
  landscapeThreeColsArrows,

  /// `big-image` — a single looping slide with wide side padding.
  bigImage,

  /// `standard-image` — 3 / 2 / 1 looping slides.
  standardImage,

  /// `calendar-wrapper` — 4 / 3 / 2 / 1, no gap.
  calendar,
}

/// The geometry an [ItCarouselType] resolves to at a given width.
///
/// Public so a caller — or a test — can ask what a preset does at a width
/// without rendering it, which is the only way to check the breakpoints are
/// read as max-width rather than min-width.
class ItCarouselConfig {
  /// Creates a resolved carousel geometry.
  const ItCarouselConfig({
    required this.perPage,
    required this.gap,
    required this.padLeft,
    required this.padRight,
    required this.arrows,
    required this.loop,
  });

  /// Slides visible at once.
  final int perPage;

  /// Space between slides, in logical pixels.
  final double gap;

  /// Padding before the first slide.
  final double padLeft;

  /// Padding after the last slide.
  final double padRight;

  /// Whether previous/next controls are shown.
  final bool arrows;

  /// Whether the track wraps around (`type: loop` upstream).
  final bool loop;
}

/// `.it-carousel-wrapper` — the Bootstrap Italia carousel.
///
/// Upstream this is a wrapper around Splide, so the CSS that belongs to
/// Bootstrap Italia is the pagination and the track; the sliding itself is the
/// library's. This reproduces the parts the design system actually specifies
/// and uses the kit's own controls for the rest, rather than inventing an
/// appearance for arrows that Bootstrap Italia never styles.
///
/// ```
/// .it-carousel-wrapper .splide__track            { padding-top:24px; padding-bottom:0 }
/// .it-carousel-wrapper .splide__pagination       { margin-top:8px }
/// .it-carousel-wrapper .splide__pagination button{ width:16px; height:16px;
///                                                  background:hsl(210,83%,77%);
///                                                  border-radius:50px; margin:0 8px }
/// .it-carousel-wrapper .splide__pagination button.is-active { background:#06c }
/// .splide:not(.is-overflow) .splide__pagination  { display:none }
/// ```
///
/// ## Autoplay
///
/// Off by default, exactly as upstream — `CONFIG_DEFAULT` sets no `autoplay`.
/// Turning it on brings a play/pause control with it, and that is not
/// negotiable: content that moves for more than five seconds must be pausable
/// (WCAG 2.2.2 Pause, Stop, Hide). Autoplay also stops permanently the moment
/// the user interacts, which is what Splide does and what keeps a keyboard
/// user from being carried away mid-slide.
class ItCarousel extends StatefulWidget {
  /// The slides.
  final List<Widget> items;

  /// Which upstream preset to lay out with.
  final ItCarouselType type;

  /// Whether the carousel advances on its own.
  ///
  /// See the class docs: this is off upstream, and switching it on adds a
  /// mandatory pause control rather than an optional one.
  final bool autoPlay;

  /// How long each slide is shown when [autoPlay] is on.
  final Duration autoPlayInterval;

  /// Overrides the carousel's accessible name (upstream `'Carosello'`).
  final String? semanticLabel;

  /// The slide shown first.
  final int initialPage;

  /// The height of the **track** — not of the widget.
  ///
  /// The rendered carousel is taller than this by
  /// [trackPaddingTop] plus, when the pagination shows, [paginationGap] +
  /// [dotSize], plus the autoplay control when it is on. Constraining the
  /// carousel to `height` in a parent `SizedBox` therefore overflows, which is
  /// exactly what happened the first time this component was placed in a
  /// gallery. With `height` set the widget sizes itself; it does not need to
  /// be boxed.
  ///
  /// Upstream the carousel sizes to its slides — the track is a flex row and
  /// the tallest slide sets the height. A [PageView] cannot do that: it is a
  /// viewport, so it has to be told how tall it is. One of the two is
  /// therefore required:
  ///
  ///  * pass a [height], or
  ///  * leave it null and place the carousel somewhere with a bounded height,
  ///    where it expands to fill.
  ///
  /// Left null in an unbounded parent — a `Column` in a scroll view, say — it
  /// throws *"Horizontal viewport was given unbounded height"*, which is the
  /// framework saying the same thing.
  final double? height;

  /// Called with the leading slide index whenever the carousel moves.
  final ValueChanged<int>? onPageChanged;

  /// Creates a Bootstrap Italia carousel.
  const ItCarousel({
    super.key,
    required this.items,
    this.type = ItCarouselType.landscape,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.semanticLabel,
    this.initialPage = 0,
    this.height,
    this.onPageChanged,
  });

  /// `.splide__track { padding-top: 24px }`.
  static const double trackPaddingTop = 24;

  /// `.splide__pagination { margin-top: 8px }`.
  static const double paginationGap = 8;

  /// `.splide__pagination button { width:16px; height:16px }`.
  static const double dotSize = 16;

  /// `.splide__pagination button { margin: 0 8px }`.
  static const double dotMargin = 8;

  /// `.splide__pagination button { border-radius: 50px }` on a 16px box.
  static const double dotRadius = 50;

  /// `.splide__pagination button { background: hsl(210,83%,77%) }`.
  ///
  /// Stays a literal. It appears exactly once in the whole distribution and
  /// maps to no `--bs-*` token, so it is the carousel's own colour rather than
  /// a palette role — unlike the active dot, which is `--bs-primary` and does
  /// re-theme.
  static const Color inactiveDot = Color(0xFF94C4F5);

  /// Resolves a preset at a given width.
  ///
  /// Splide breakpoints are **max-width**: a `768` entry applies at 768px and
  /// below. Reading them as min-width inverts every layout, which is why the
  /// comparison here is `<=`.
  static ItCarouselConfig configFor(ItCarouselType type, double width) {
    switch (type) {
      case ItCarouselType.landscape:
        return ItCarouselConfig(
          perPage: 1,
          gap: 24,
          padLeft: width <= 992 && width > 768 ? 24 : 0,
          padRight: width <= 992 && width > 768 ? 24 : 0,
          arrows: false,
          loop: false,
        );
      case ItCarouselType.landscapeThreeCols:
      case ItCarouselType.landscapeThreeColsArrows:
        final arrows = type == ItCarouselType.landscapeThreeColsArrows;
        if (width <= 768) {
          return ItCarouselConfig(
            perPage: 1,
            gap: 24,
            padLeft: arrows ? 40 : 0,
            padRight: arrows ? 40 : 0,
            arrows: arrows,
            loop: false,
          );
        }
        if (width <= 992) {
          return ItCarouselConfig(
            perPage: 2,
            gap: 24,
            padLeft: 40,
            padRight: 40,
            arrows: arrows,
            loop: false,
          );
        }
        return ItCarouselConfig(
          perPage: 3,
          gap: 24,
          padLeft: 0,
          padRight: 0,
          arrows: arrows,
          loop: false,
        );
      case ItCarouselType.bigImage:
        if (width <= 768) {
          return const ItCarouselConfig(
            perPage: 1,
            gap: 0,
            padLeft: 0,
            padRight: 0,
            arrows: false,
            loop: true,
          );
        }
        if (width <= 992) {
          return const ItCarouselConfig(
            perPage: 1,
            gap: 24,
            padLeft: 160,
            padRight: 160,
            arrows: false,
            loop: true,
          );
        }
        return const ItCarouselConfig(
          perPage: 1,
          gap: 48,
          padLeft: 320,
          padRight: 320,
          arrows: false,
          loop: true,
        );
      case ItCarouselType.standardImage:
        if (width <= 768) {
          return const ItCarouselConfig(
            perPage: 1,
            gap: 24,
            padLeft: 40,
            padRight: 40,
            arrows: false,
            loop: true,
          );
        }
        if (width <= 992) {
          return const ItCarouselConfig(
            perPage: 2,
            gap: 24,
            padLeft: 48,
            padRight: 48,
            arrows: false,
            loop: true,
          );
        }
        return const ItCarouselConfig(
          perPage: 3,
          gap: 24,
          padLeft: 48,
          padRight: 48,
          arrows: false,
          loop: true,
        );
      case ItCarouselType.calendar:
        if (width <= 560) {
          return const ItCarouselConfig(
            perPage: 1,
            gap: 0,
            padLeft: 24,
            padRight: 24,
            arrows: false,
            loop: false,
          );
        }
        if (width <= 768) {
          return const ItCarouselConfig(
            perPage: 2,
            gap: 0,
            padLeft: 0,
            padRight: 0,
            arrows: false,
            loop: false,
          );
        }
        if (width <= 992) {
          return const ItCarouselConfig(
            perPage: 3,
            gap: 0,
            padLeft: 0,
            padRight: 0,
            arrows: false,
            loop: false,
          );
        }
        return const ItCarouselConfig(
          perPage: 4,
          gap: 0,
          padLeft: 0,
          padRight: 0,
          arrows: false,
          loop: false,
        );
    }
  }

  @override
  State<ItCarousel> createState() => _ItCarouselState();
}

class _ItCarouselState extends State<ItCarousel> {
  late final PageController _controller;
  late int _page;
  Timer? _timer;

  /// Whether autoplay is currently running.
  ///
  /// Distinct from `widget.autoPlay`, which only says whether the feature is
  /// available: the user can stop it, and once stopped it stays stopped.
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage;
    _controller = PageController(initialPage: widget.initialPage);
    _playing = widget.autoPlay;
    if (_playing) _startTimer();
  }

  @override
  void didUpdateWidget(ItCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlay != widget.autoPlay) {
      widget.autoPlay ? _play() : _pause();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || widget.items.isEmpty) return;
      final next = (_page + 1) % widget.items.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _play() {
    setState(() => _playing = true);
    _startTimer();
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _playing = false);
  }

  void _goTo(int index) {
    // Any deliberate move stops autoplay for good. Splide behaves the same
    // way, and it is the difference between a control that pauses and one that
    // merely delays the next jump.
    _pause();
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ItLocalizations.of(context);
    final colors = resolveColorScheme(context);

    if (widget.items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final config = ItCarousel.configFor(widget.type, width);

        // `.splide:not(.is-overflow) .splide__pagination { display: none }` —
        // with nothing to scroll to there is nothing to paginate, and a row of
        // dots that cannot do anything is one more thing for AT to read out.
        final overflows = widget.items.length > config.perPage;

        return Semantics(
          container: true,
          // Without this the region's label swallows its own controls: with a
          // single slide the pagination dot merged into the "Carosello" node
          // and stopped existing as a target, while three slides kept their
          // nodes because the scrollable in between broke the merge. A defect
          // that appears only at one item count is exactly what a contract
          // test is for.
          explicitChildNodes: true,
          label: widget.semanticLabel ?? l10n.carousel,
          child: Column(
            // `min` only when the track has been given a height of its own;
            // otherwise the Expanded below needs the column to take what it is
            // offered.
            mainAxisSize:
                widget.height == null ? MainAxisSize.max : MainAxisSize.min,
            children: [
              _flexible(
                widget.height == null,
                Padding(
                  // `.splide__track { padding-top:24px; padding-bottom:0 }`
                  padding: const EdgeInsets.only(
                    top: ItCarousel.trackPaddingTop,
                  ),
                  child: Row(
                    children: [
                      if (config.arrows)
                        ItIconAction(
                          icon: BootstrapItaliaIcons.it_arrow_left,
                          color: colors.primary,
                          label: l10n.previousSlide,
                          onPressed: _page > 0 || config.loop
                              ? () => _goTo(
                                    (_page - 1) % widget.items.length,
                                  )
                              : null,
                        ),
                      Expanded(
                        child: widget.height == null
                            ? _track(config, l10n)
                            : SizedBox(
                                height: widget.height,
                                child: _track(config, l10n),
                              ),
                      ),
                      if (config.arrows)
                        ItIconAction(
                          icon: BootstrapItaliaIcons.it_arrow_right,
                          color: colors.primary,
                          label: l10n.nextSlide,
                          onPressed:
                              _page < widget.items.length - 1 || config.loop
                                  ? () => _goTo(
                                        (_page + 1) % widget.items.length,
                                      )
                                  : null,
                        ),
                    ],
                  ),
                ),
              ),
              if (overflows) _pagination(colors, l10n),
              if (widget.autoPlay) _playPause(colors, l10n),
            ],
          ),
        );
      },
    );
  }

  /// Wraps [child] in [Expanded] only when the track must fill its parent.
  ///
  /// Two shapes rather than one because the alternative — always Expanded —
  /// makes the carousel unusable in a scroll view, and always-not makes it
  /// unusable without an explicit height.
  Widget _flexible(bool expand, Widget child) =>
      expand ? Expanded(child: child) : child;

  Widget _track(ItCarouselConfig config, ItLocalizations l10n) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.items.length,
      onPageChanged: (i) {
        setState(() => _page = i);
        widget.onPageChanged?.call(i);
      },
      itemBuilder: (context, i) {
        return Padding(
          padding: EdgeInsets.only(
            left: i == 0 ? config.padLeft : config.gap / 2,
            right:
                i == widget.items.length - 1 ? config.padRight : config.gap / 2,
          ),
          child: Semantics(
            // Upstream a slide is `role="group"` carrying `aria-label`, so it
            // is a node in its own right rather than a label smeared onto the
            // content. Without `container` + `explicitChildNodes` the position
            // merges into the slide's own text and both are lost: the label
            // becomes "1 di 3\nslide 0", which is neither.
            container: true,
            explicitChildNodes: true,
            // Upstream `slideLabel: '%s di %s'`. Without it a screen-reader
            // user has no idea how far through the set they are.
            label: l10n.slideLabel
                .replaceFirst('%s', '${i + 1}')
                .replaceFirst('%s', '${widget.items.length}'),
            child: widget.items[i],
          ),
        );
      },
    );
  }

  Widget _pagination(BootstrapItaliaColorScheme colors, ItLocalizations l10n) {
    return Padding(
      // `.splide__pagination { margin-top: 8px }`
      padding: const EdgeInsets.only(top: ItCarousel.paginationGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(widget.items.length, (i) {
          final active = i == _page;
          return Padding(
            // `margin: 0 8px`
            padding: const EdgeInsets.symmetric(
              horizontal: ItCarousel.dotMargin,
            ),
            // Upstream the dot IS the button — `.splide__pagination button`
            // is a 16x16 element with a background colour and a 50px radius,
            // no glyph involved. The first attempt here used an ItIconAction
            // with `iconSize: 0`, expecting the button to paint its own
            // background: it does not, so the dots were completely invisible
            // while every semantic test still passed. They were checking the
            // name, not the paint.
            child: Semantics(
              button: true,
              selected: active,
              label: l10n.goToSlide.replaceFirst('%s', '${i + 1}'),
              child: ItActivatable(
                onPressed: () => _goTo(i),
                borderRadius: BorderRadius.circular(ItCarousel.dotRadius),
                child: Container(
                  width: ItCarousel.dotSize,
                  height: ItCarousel.dotSize,
                  decoration: BoxDecoration(
                    color: active ? colors.primary : ItCarousel.inactiveDot,
                    // `border-radius: 50px` on a 16px box — a circle.
                    borderRadius: BorderRadius.circular(ItCarousel.dotRadius),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// The autoplay control, required whenever [ItCarousel.autoPlay] is set.
  ///
  /// Deliberately a labelled button rather than a glyph: `bootstrap_italia_icons`
  /// ships no play or pause symbol, and inventing one would leave the single
  /// control that satisfies WCAG 2.2.2 depending on an icon nobody can be sure
  /// reads as "pause". The visible text says what it does.
  Widget _playPause(BootstrapItaliaColorScheme colors, ItLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: ItCarousel.paginationGap),
      child: ItButton(
        variant: ItButtonVariant.primary,
        size: ItButtonSize.small,
        outline: true,
        onPressed: _playing ? _pause : _play,
        child: Text(_playing ? l10n.pauseCarousel : l10n.playCarousel),
      ),
    );
  }
}
