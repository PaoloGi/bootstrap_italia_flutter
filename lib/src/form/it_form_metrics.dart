import 'package:flutter/widgets.dart';

import '../theme/bootstrap_italia_theme_data.dart';
import '../tokens/typography.dart';

/// Pixel metrics and colours shared by all Bootstrap Italia form controls.
///
/// Every value here is taken verbatim from the compiled Bootstrap Italia
/// stylesheet (`bootstrap-italia.min.css`, v2.18.0) so the Flutter widgets
/// render at exactly the same size as the reference web components.
/// Bootstrap Italia uses `1rem = 16px`.
///
/// The metrics are all constants. Two of the colours are not: where the kit's
/// value is a semantic token, it is a function of a [BootstrapItaliaColorScheme]
/// so an administration's palette reaches the form controls. See the note above
/// the colour block for how that call is made, value by value.
abstract final class ItFormMetrics {
  // ── .form-control / input[type=text] ───────────────────────────────
  //
  // input[type=text] { border:none; border-bottom:1px solid hsl(210,17%,44%);
  //                    padding:.375rem .5rem }
  // .form-control    { min-height:2.5rem; font-size:1rem; line-height:1.5 }

  /// `.form-control { min-height: 2.5rem }`
  static const double controlHeight = 40;

  /// `input[type=text] { border-bottom: 1px solid … }`
  static const double borderWidth = 1;

  /// `input[type=text] { padding: .375rem .5rem }` — horizontal component.
  static const double horizontalPadding = 8;

  /// `.form-control { font-size: 1rem }`
  static const double fontSize = 16;

  /// `.form-control { line-height: 1.5 }` → 24px at 16px font size.
  static const double textLineHeight = 24;

  // ── .form-group label (floating label) ─────────────────────────────
  //
  // .form-group label        { line-height:calc(2.5rem - 1px); top:0;
  //                            font-size:1rem; padding:0 .5rem;
  //                            color:hsl(210,17%,44%) }
  // .form-group label.active { transform:translateY(-85%); font-weight:600;
  //                            font-size:.875rem; color:hsl(0,0%,10%) }

  /// `line-height: calc(2.5rem - 1px)`
  static const double labelLineHeight = 39;

  /// Resting (non-floating) label size.
  static const double labelFontSize = 16;

  /// Floating (`label.active`) label size — `.875rem`.
  static const double activeLabelFontSize = 14;

  /// `transform: translateY(-85%)` of the 39px label line box.
  static const double activeLabelOffset = -0.85 * labelLineHeight;

  // ── .form-text (helper) and .form-feedback (validation message) ────
  //
  // .form-group small.form-text { padding:.25rem .5rem; font-size:.875rem }
  // .form-feedback              { margin-left:.5rem; margin-top:.25rem;
  //                               font-size:.75rem }
  // .form-feedback.just-validate-error-label { color:#d9364f }

  /// `.form-text { font-size: .875rem }`
  static const double helperFontSize = 14;

  /// Computed line box of `.form-text` (`.875rem × 1.5`).
  static const double helperLineHeight = 21;

  /// Height the helper line occupies inside `.form-group` (parent strut).
  static const double helperBlockHeight = 24;

  /// `.form-feedback { font-size: .75rem }`
  static const double feedbackFontSize = 12;

  /// Computed line box of `.form-feedback` (`.75rem × 1.5`).
  static const double feedbackLineHeight = 18;

  /// `.form-feedback { margin-top: .25rem }`
  static const double feedbackTopMargin = 4;

  /// `.form-feedback { margin-left: .5rem }`
  static const double feedbackLeftMargin = 8;

  // ── .input-group ───────────────────────────────────────────────────

  /// `.input-group .input-group-text { min-width: 40px }`
  static const double inputGroupTextWidth = 40;

  /// `.input-group .input-group-text~label:not(.active) { left: 2.25rem }`
  static const double inputGroupLabelLeft = 36;

  /// `.icon.icon-sm { width: 24px; height: 24px }`
  static const double iconSize = 24;

  // ── .form-control-sm / .form-control-lg ────────────────────────────
  //
  // .form-control-sm { min-height:calc(1.5em + 0.5rem); padding:.25rem .5rem;
  //                    font-size:0.875rem }
  // .form-control-lg { min-height:calc(1.5em + 1rem);   padding:.5rem 1rem;
  //                    font-size:1.25rem }
  //
  // Both are declared *after* `.form-control { min-height:2.5rem }` at the same
  // specificity, so they win the cascade and the control really does change
  // height — the docs describe them as changing "la grandezza del carattere e
  // la spaziatura interna", but the min-height moves with them.
  //
  // `1.5em` resolves against the element's own computed font-size, which the
  // same rule has just set: 1.5 x 14 + 8 = 29 for `sm`, 1.5 x 20 + 16 = 46 for
  // `lg`. The border radius each rule also declares is overridden back to 0 by
  // `.form-control.form-control-lg { border-radius:0 }` and by
  // `.form-control { border-radius:0 !important }`, so no radius is carried.

  /// `.form-control-sm { font-size: 0.875rem }`
  static const double smallFontSize = 14;

  /// `.form-control-sm { min-height: calc(1.5em + 0.5rem) }` at 14px type.
  static const double smallControlHeight = 29;

  /// `.form-control-sm { padding: .25rem .5rem }` — horizontal component.
  static const double smallHorizontalPadding = 8;

  /// `.form-control-lg { font-size: 1.25rem }`
  static const double largeFontSize = 20;

  /// `.form-control-lg { min-height: calc(1.5em + 1rem) }` at 20px type.
  static const double largeControlHeight = 46;

  /// `.form-control-lg { padding: .5rem 1rem }` — horizontal component.
  static const double largeHorizontalPadding = 16;

  // ── .form-check.form-check-group ("Raggruppati visivamente") ───────
  //
  // .form-check.form-check-group { padding:0 0 1rem 0; margin-bottom:1rem;
  //                                box-shadow:inset 0 -1px 0 0 rgba(1,1,1,.1) }
  // .form-check.form-check-group [type=checkbox]+label,
  // .form-check.form-check-group [type=radio]+label
  //   { position:static; padding-left:0; padding-right:3.25rem }
  // .form-check.form-check-group [type=checkbox]+label::after,::before,
  // .form-check.form-check-group [type=radio]+label::after,::before
  //   { right:0px; left:auto }
  // .form-check.form-check-group .form-text
  //   { display:block; padding-right:3.25rem; margin-bottom:.5rem }
  //
  // The indicator does not move *within* its own box — only the box's anchor
  // flips from `left` to `right`. Every offset the resting variant already
  // uses is therefore reused verbatim, mirrored; that is why the grouped
  // checkbox tick lands at `right:11px` in the sheet, which is the same +1px
  // from the box's leading edge it has on the left.

  /// `.form-check.form-check-group { padding-bottom: 1rem }`
  static const double checkGroupPaddingBottom = 16;

  /// `.form-check.form-check-group { margin-bottom: 1rem }`
  static const double checkGroupMarginBottom = 16;

  /// `.form-check.form-check-group […]+label { padding-right: 3.25rem }` — the
  /// gutter the indicator is parked in, kept clear of the label text.
  static const double checkGroupGutter = 52;

  /// `.form-check.form-check-group .form-text { margin-bottom: .5rem }`
  static const double checkGroupHelperBottomMargin = 8;

  /// `.form-text { margin-top: .25rem }` — the base rule, which applies to the
  /// grouped helper because it is not inside a `.form-group` in this layout.
  static const double checkGroupHelperTopMargin = 4;

  // ── Colours ────────────────────────────────────────────────────────
  //
  // Which of these may follow [BootstrapItaliaColorScheme] cannot be read off
  // the syntax: v2.18.0 resolves every semantic token at build time, so the
  // compiled sheet contains no `var(--bs-primary)` at all and every colour is
  // written out as a literal. Provenance is decided by identity AND role — a
  // value is a token when it is byte-identical to a declared `--bs-*` *and*
  // sits in the role that token exists for. Only [textColor] and
  // [focusRingColor] clear both bars, which is why they alone take a scheme.
  //
  // The rest are colours the stylesheet declares in their own right. Routing
  // those through the scheme would be its own defect: re-theming would not move
  // them upstream either, so a retinted app would drift away from the kit.

  /// `input[type=date],…,input[type=text],textarea
  ///   { border-bottom: 1px solid hsl(210,17%,44%) }`, and the same value again
  /// on `.form-group label { color: … }`, on `input::placeholder { color: … }`
  /// and on `.form-check [type=radio]:not(:checked)+label::before
  ///   { border-color: … }`.
  ///
  /// Literal, despite matching a token. `hsl(210,17%,44%)` is declared three
  /// times over — as `--bs-secondary`, as `--bs-info` and as
  /// `--bs-gray-secondary` — so identity alone settles nothing, and every use
  /// above is resting chrome or muted metadata. That is the grey, not the brand
  /// accent: an administration retinting `secondary` wants its buttons
  /// recoloured, not its form helper text.
  static const Color borderColor = Color(0xFF5D7083);

  /// `.select-wrapper select
  ///   { border-bottom: 1px solid rgb(91.035,110.5425,130.05) }`.
  ///
  /// Literal, matching no token at all. The kit exposes this exact value as
  /// `.neutral-1-color-a7` — step 7 of the neutral-1 ramp — and it is nowhere
  /// near `--bs-secondary` (`rgb(93.126,112.2,131.274)`). Chrome, not accent.
  static const Color selectBorderColor = Color(0xFF5B6F82);

  /// `.form-control:disabled { background-color: hsl(210,3%,85%) }` and
  /// `.select-wrapper select:disabled { background-color: hsl(210,3%,85%) }`.
  ///
  /// Literal: `hsl(210,3%,85%)` is the kit's `.lightgrey-bg-a1` and is not the
  /// value of any `--bs-*` custom property.
  static const Color disabledBackground = Color(0xFFD8D9DA);

  /// `.form-control { color: hsl(0,0%,10%) }`, `.form-group label.active
  ///   { color: hsl(0,0%,10%) }` and `.select-wrapper select
  ///   { font-weight: 700; color: hsl(0,0%,10%) }`.
  ///
  /// **Token.** `hsl(0,0%,10%)` is `--bs-body-color`, and the role is the body
  /// text the user reads and types — precisely what that token means, so it
  /// follows the scheme. Takes [colors] for that reason; [ItAccordion] resolves
  /// the same value the same way.
  static Color textColor(BootstrapItaliaColorScheme colors) => colors.bodyColor;

  /// `.form-feedback.just-validate-error-label { color: #d9364f }`.
  ///
  /// Literal, and deliberately so — this is the trap in this file. `#d9364f` is
  /// **not** the danger token: `--bs-danger` is `hsl(350,60%,50%)` =
  /// `rgb(204,51,76.5)` = `#CC334D`, which is exactly what Bootstrap's own
  /// `.invalid-feedback { color: rgb(204,51,76.5) }` carries. Bootstrap Italia
  /// overrides the validation message with a standalone `#d9364f` that backs no
  /// custom property anywhere in the sheet, so retinting `danger` would not
  /// move it upstream.
  ///
  /// The field *chrome* is the opposite case and is already handled:
  /// `.form-control.is-invalid { border-color: rgb(204,51,76.5) }` **is** the
  /// token, and [ItInput] takes it from the scheme.
  static const Color feedbackDangerColor = Color(0xFFD9364F);

  /// `.form-control:focus { box-shadow: 0 0 0 .25rem rgba(0,102,204,.25) }` —
  /// and identically on `.form-check-input:focus` and `.form-select:focus`.
  ///
  /// **Token.** `rgb(0,102,204)` is byte-identical to `--bs-primary`
  /// (`hsl(210,100%,40%)`), and this is Bootstrap's `$input-btn-focus-color`,
  /// derived from `$component-active-bg: $primary` — the accent role the token
  /// exists for. Written literally it would leave a retinted app focusing every
  /// field in Blu Italia.
  ///
  /// `withAlpha(0x40)` rather than a 0.25 double: `0x40 / 255 = 0.2510` is the
  /// 8-bit alpha this value has always carried, so the ring stays byte-identical
  /// under the standard palette.
  static Color focusRingColor(BootstrapItaliaColorScheme colors) =>
      colors.primary.withAlpha(0x40);

  /// `.form-check [type=checkbox]:not(:checked)+label::after
  ///   { border-color: rgb(91.035,110.5425,130.05) }` — the resting outline of
  /// a checkbox — and `.toggles label input[type=checkbox]+.lever:after
  ///   { background-color: rgb(91.035,110.5425,130.05) }`, the toggle thumb.
  ///
  /// Literal: same `.neutral-1-color-a7` value as [selectBorderColor], matching
  /// no semantic token, in the same resting-chrome role.
  static const Color checkOutlineColor = Color(0xFF5B6F82);

  /// `.toggles label input[type=checkbox]+.lever
  ///   { background-color: #e6e9f2 }` (the track, in every state) and
  /// `.form-check [type=checkbox]:disabled:checked+label::after
  ///   { background-color: #e6e9f2 }`.
  ///
  /// Literal. Deceptively close to `--bs-light` (`#E9E6F2`) but not equal to it
  /// — the middle digits are transposed — and it backs no custom property.
  static const Color mutedChrome = Color(0xFFE6E9F2);

  /// `.form-check [type=radio]:disabled:checked+label::after
  ///   { border-color: hsl(210,3%,85%); background-color: hsl(210,3%,85%) }`.
  ///
  /// Literal: the same `.lightgrey-bg-a1` grey as [disabledBackground], which
  /// is not the value of any `--bs-*` custom property.
  static const Color disabledChrome = Color(0xFFD8D9DA);

  /// `.form-check input.semi-checked:not(:checked)+label::after
  ///   { border-color: rgb(32.13,123.165,214.2);
  ///     background-color: rgb(32.13,123.165,214.2) }`, and identically inside
  /// `.it-transfer-wrapper`, which is the component the docs point at for this
  /// state.
  ///
  /// Literal, and *not* the primary token — this is the trap in the mixed
  /// state. `--bs-primary` is `hsl(210,100%,40%)` = `rgb(0,102,204)`, which is
  /// what `:checked+label::after` carries; the semi-checked box is deliberately
  /// a different, lighter blue. The kit exposes this exact value as
  /// `.primary-color-a5` — step 5 of the hand-authored primary ramp — and it
  /// backs no custom property anywhere in the sheet, so retinting `primary`
  /// would not move it upstream. Resolving it from the scheme would paint the
  /// indeterminate box the *checked* colour, which is precisely the distinction
  /// this state exists to draw.
  static const Color semiCheckedFill = Color(0xFF207BD6);

  /// `.form-check.form-check-group
  ///   { box-shadow: inset 0 -1px 0 0 rgba(1,1,1,.1) }` — the hairline that
  /// separates one visually-grouped row from the next.
  ///
  /// Literal: `rgba(1,1,1,.1)` is very nearly black at 10%, matches no token
  /// (`--bs-black` is `hsl(0,0%,0%)`, one unit away on every channel) and is a
  /// divider rather than an accent.
  static const Color checkGroupSeparator = Color(0x1A010101);

  /// Builds a Titillium Web text style whose line box is exactly
  /// [lineHeight] CSS pixels tall, distributed like CSS half-leading.
  static TextStyle textStyle({
    required double fontSize,
    required double lineHeight,
    required Color color,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: fontSize,
      height: lineHeight / fontSize,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Alphabetic baseline of the `.form-group` "strut", measured from the top
  /// of the 24px line box.
  ///
  /// `small.form-text` is an inline element, so the line it sits on is as tall
  /// as the group's own 16px/24px strut and takes that strut's baseline rather
  /// than the one its smaller 14px type would produce. Titillium Web's
  /// ascender is 1.133em and its descender 0.388em, so the half-leading is
  /// `(24 - 16 × 1.521) / 2 = -0.17` and the baseline lands at
  /// `-0.17 + 16 × 1.133 ≈ 18`.
  static const double groupStrutBaseline = 18;
}
