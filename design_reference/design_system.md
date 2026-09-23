---
name: Precision Ledger
colors:
  surface: '#0f131c'
  surface-dim: '#0f131c'
  surface-bright: '#353943'
  surface-container-lowest: '#0a0e17'
  surface-container-low: '#181b25'
  surface-container: '#1c1f29'
  surface-container-high: '#262a34'
  surface-container-highest: '#31353f'
  on-surface: '#dfe2ef'
  on-surface-variant: '#bec8ce'
  inverse-surface: '#dfe2ef'
  inverse-on-surface: '#2c303a'
  outline: '#899298'
  outline-variant: '#3f484e'
  surface-tint: '#7bd1fa'
  primary: '#c5eaff'
  on-primary: '#003547'
  primary-container: '#7dd3fc'
  on-primary-container: '#005b78'
  inverse-primary: '#006686'
  secondary: '#4cd7f6'
  on-secondary: '#003640'
  secondary-container: '#03b5d3'
  on-secondary-container: '#00424e'
  tertiary: '#cde8ff'
  on-tertiary: '#00344d'
  tertiary-container: '#8ed0ff'
  on-tertiary-container: '#005981'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#c0e8ff'
  primary-fixed-dim: '#7bd1fa'
  on-primary-fixed: '#001e2b'
  on-primary-fixed-variant: '#004d66'
  secondary-fixed: '#acedff'
  secondary-fixed-dim: '#4cd7f6'
  on-secondary-fixed: '#001f26'
  on-secondary-fixed-variant: '#004e5c'
  tertiary-fixed: '#c9e6ff'
  tertiary-fixed-dim: '#89ceff'
  on-tertiary-fixed: '#001e2f'
  on-tertiary-fixed-variant: '#004c6e'
  background: '#0f131c'
  on-background: '#dfe2ef'
  surface-variant: '#31353f'
typography:
  display-lg:
    fontFamily: Space Grotesk
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
  display-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 34px
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Space Grotesk
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 18px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 0.75rem
  gutter-tablet: 1rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-tablet: 2rem
  margin-desktop: 3rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system defines an ultra-crisp, high-utility financial interface tailored for splitting group tabs, dining bills, and itemized receipts. The aesthetic converges modern digital craftsmanship with sharp computational clarity.

- **Brand Personality**: Swift, hyper-accurate, effortless, and modern. It projects zero ambiguity around numbers while remaining fluid, social, and friction-free.
- **Target Audience**: Digital-native social diners, shared households, travel groups, and cost-conscious organizers who value quick execution over tedious bookkeeping.
- **Emotional Response**: Relief from social awkwardness around shared payments, supreme confidence in itemized calculations, and tactile delight when claiming line items.
- **Aesthetic Direction**: Deep Slate Precision Glass. Anchored by deep midnight-slate canvasses, razor-thin translucent surfaces, and radiant ice blue/cyan accents. It balances high-contrast legibility with sleek, nocturnal mobile ergonomics.

## Colors

- **Primary (`#7dd3fc` - Ice Blue)**: primary CTAs, highlighted totals, active toggles, selection badges.
- **Secondary (`#06b6d4` - Vivid Cyan)**: progress states, scanner reticles, live computation badges.
- **Tertiary (`#0ea5e9` - Sky Teal)**: secondary actions, item indicators, linked participant tokens.
- **Neutral Core (`#090d16` - Deep Midnight Slate)**: base canvas, paired with `#0f172a`, `#1e293b`.
- **Success/Settled**: `#10b981`. **Warning/Unassigned**: `#f59e0b`. **Critical/Owed**: `#f43f5e`.
- **Foreground**: `#f8fafc` headers/values, `#94a3b8` metadata.

## Typography

1. **Space Grotesk** — headlines, totals, modal titles.
2. **Hanken Grotesk** — body/interface copy, item descriptions.
3. **JetBrains Mono** — all monetary figures, percentages, timestamps (tabular alignment).

## Layout & Spacing

Mobile-first, 8pt rhythm with 4pt sub-grid. `margin: 1rem`, `gutter: 0.75rem`. Sticky bottom action bars respect `env(safe-area-inset-bottom)`. Dense itemized rows.

## Shapes

- Base radius 8px: inputs, tiles, chips.
- Container radius 16px: cards, modules.
- Sheet/modal radius 24px (top corners): bottom drawers, camera overlays.
- Pill (9999px): avatars, filter chips, primary CTAs.

## Components (summary)

- **Buttons**: Primary = solid `#7dd3fc` bg / `#090d16` text, pill or 12px radius. Secondary = translucent ice ghost. Destructive = low-opacity coral.
- **Receipt line item card**: name (Hanken) left, qty badge, right-aligned mono price. Unassigned = dashed left border; assigned = soft cyan tint.
- **Participant/Tip chips**: 24px circular avatar + name + subtotal, color-coded border. Tip segmented matrix (10/15/20/Custom).
- **Currency field**: giant centered Space Grotesk display, auto-shrinks past 6 digits.
- **Split breakdown card**: monospaced tabular summary — subtotal, tip, total — with per-person accordion.

See `screens/*.html` for full reference markup of each screen (uses Tailwind + Material Symbols, built as a web prototype — not the Flutter source, just the visual/UX spec).
