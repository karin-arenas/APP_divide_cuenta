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

The palette is engineered specifically for low-light social dining venues while delivering uncompromising numeric readability under direct sunlight.

- **Primary (`#7dd3fc` - Ice Blue)**: Used for primary calls to action, highlighted totals, active toggles, and user selection badges. Emits a cool, neon-like illumination against slate surfaces.
- **Secondary (`#06b6d4` - Vivid Cyan)**: The accent for progress states, receipt scanner alignment reticles, and real-time computation badges.
- **Tertiary (`#0ea5e9` - Sky Teal)**: Dedicated to secondary actions, interactive line-item indicators, and linked participant tokens.
- **Neutral Core (`#090d16` - Deep Midnight Slate)**: The foundation canvas. Paired with elevated dark slates (`#0f172a`, `#1e293b`) and translucent crisp cool grays (`#334155` at 40–80% alpha) to create clear surface hierarchies.
- **Functional Semantics**:
  - **Success / Settled**: Emerald Bright (`#10b981`) for settled debts and matched line items.
  - **Warning / Unassigned**: Amber Glow (`#f59e0b`) for unclaimed receipt items or tipping discrepancies.
  - **Critical / Owed**: Coral Flame (`#f43f5e`) for negative balances or deleted entries.
  - **Foreground Typography**: Ultra-pure ice white (`#f8fafc`) for headers and numeric values; cool slate (`#94a3b8`) for metadata, splits, and subtotals.

## Typography

The typographic strategy leverages three distinct font families to establish immediate semantic hierarchy:

1. **Space Grotesk (Headlines & Totals)**: Imparts a technical, futuristic edge suitable for high-level bill overviews, aggregate sums, and modal view titles.
2. **Hanken Grotesk (Body & Interface Copy)**: A refined, neo-grotesque workhorse that delivers supreme legibility in dense receipts, item descriptions, and user listings.
3. **JetBrains Mono (Data, Currency, & Calculations)**: Monospaced precision is non-negotiable for accounting. All line-item prices, split math, tax percentages, and timestamps utilize JetBrains Mono to ensure tabular figures line up cleanly without horizontal jitter during live calculations.

## Layout & Spacing

The layout model prioritizes mobile ergonomics, placing all primary interactions within the thumb zone of modern handheld devices:

- **Mobile First Canvas**: Utilizes an 8pt architectural rhythm, with a strict 4pt sub-grid for fine alignment of monetary figures and avatar chips.
- **Fluid Column Grid**: 4 columns on mobile viewports (minimum target: 360dp width) with standard `margin: 1rem` (16px) and `gutter: 0.75rem` (12px). Expands to 8 columns on tablets and 12 columns on desktop web dashboards.
- **Thumb Zone Anchor**: Floating action bars (e.g., "Confirm Split", "Scan Receipt") and split summary drawers are sticky-pinned to the bottom viewport edge, respecting device safe area insets (`env(safe-area-inset-bottom)`).
- **Dense Itemization Layout**: Receipt line items use tightly bounded padding (`space-sm` vertically, `space-md` horizontally) to minimize vertical scrolling and maximize visible item context during live bill assignments.

## Elevation & Depth

This design system repudiates generic drop shadows in favor of **Tonal Glass Layers** and **Luminescent Surface Gradients**:

- **Layer 0 (Canvas Base)**: Deep Slate `#090d16`. Pure flat background.
- **Layer 1 (Card / Container Surfaces)**: Translucent Slate `#0f172a` at 85% opacity with a `16px` backdrop blur filter and a 1px inner hairline stroke of `rgba(148, 163, 184, 0.12)`.
- **Layer 2 (Floating Modals & Action Drawers)**: High-luminance slate `#1e293b` with a fine ice blue ambient shadow: `0 12px 32px -4px rgba(6, 182, 212, 0.15)`.
- **Layer 3 (Active Item Selection / Tap Highlights)**: Pure ice glow stroke: 1.5px border of `#7dd3fc` accompanied by an inner radial bloom of `rgba(125, 211, 252, 0.08)`.
- **Hairlines**: All receipt perforations, item row dividers, and subtotal rules employ low-contrast 1px strokes tinted to `#334155` at 50% alpha, ensuring structure without visual noise.

## Shapes

The geometric personality features balanced, purposeful curvature that feels engineered rather than bubbly:

- **Base Radius (`0.5rem` / 8px)**: Inputs, line-item selection tiles, tip percentage chips, and receipt tags.
- **Container Radius (`1rem` / 16px)**: Receipt summary cards, scanning preview modules, and breakdown containers.
- **Sheet & Modal Radius (`1.5rem` / 24px)**: Bottom split drawers, participant assignment sheets, and full-screen camera overlays (top corners).
- **Pill Exception (`9999px`)**: Interactive person-assignment avatars, pill-style category filters, and primary conversion CTA buttons to optimize touch affordance and distinction from rectangular content blocks.

## Components

### Buttons
- **Primary Action**: Full-width pill or `0.75rem` rounded, background in solid `#7dd3fc` with `#090d16` text (bold Space Grotesk). Interactive press states scale to `98%` with an inner shadow.
- **Secondary / Action Ghost**: Translucent ice surface (`rgba(125, 211, 252, 0.08)`) with a 1px border of `rgba(125, 211, 252, 0.3)` and `#7dd3fc` text.
- **Destructive**: Low-opacity coral background (`rgba(244, 63, 94, 0.1)`) with `#f43f5e` text and border.

### Receipt Line Item Card
- **Structure**: A multi-tiered row component displaying item name on the left in Hanken Grotesk, quantity badge, and right-aligned JetBrains Mono currency text.
- **State Feedback**: Unassigned items have an ambient slate surface with a subtle dashed left border. Tapping an item opens participant assignment and floods the card with a soft cyan gradient tint (`rgba(6, 182, 212, 0.1)`).

### Participant & Tip Chips
- **Participant Pill**: Compact horizontal badges with a 24px circular avatar, truncated first name, and individual subtotal. Color-coded border matching the user’s assigned receipt color.
- **Tip Selectors**: Segmented matrix chips (`15%`, `18%`, `20%`, `Custom`) configured with mono figures. Selected state elevates with solid cyan border and high-contrast text.

### Inputs & Number Steppers
- **Currency Field**: Giant centered display text using Space Grotesk Display, dynamically sizing down if character count exceeds 6 digits.
- **Text Inputs**: Flat slate background (`#0f172a`), 1px muted border, transitioning to `#7dd3fc` on active focus with zero layout shift.

### Split Breakdown Card
- **Anatomy**: Monospaced tabular receipt summary with simulated digital perforations. Includes subtotal, tax breakdown, service charge, and tip. Concludes with an expandable accordion detailing who owes whom, integrated with one-tap payment request shortcuts.