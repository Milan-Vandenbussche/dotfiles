/**
 * @name Matugen
 * @author Matugen
 * @version 1.0.0
 * @description Dynamic Material You theme for Discord / Vesktop generated from wallpaper
*/

@import url('https://refact0r.github.io/midnight-discord/build/midnight.css');

:root {
  --colors: on;

  /* Accent colors from Wallpaper */
  --accent-1: {{ colors.primary.default.hex }};
  --accent-2: {{ colors.primary.default.hex }};
  --accent-3: {{ colors.primary.default.hex }};
  --accent-4: {{ colors.primary.default.hex }};
  --accent-5: {{ colors.primary_container.default.hex }};

  /* Surfaces & Backgrounds */
  --bg-1: {{ colors.surface_container_high.default.hex }};
  --bg-2: {{ colors.surface_container.default.hex }};
  --bg-3: {{ colors.surface_container_low.default.hex }};
  --bg-4: {{ colors.surface.default.hex }};
  --hover: {{ colors.surface_container_high.default.hex }}80;
  --active: {{ colors.primary_container.default.hex }};
  --message-hover: {{ colors.surface_container_high.default.hex }}40;

  /* Text & Typography */
  --text-0: {{ colors.on_primary.default.hex }};
  --text-1: {{ colors.on_surface.default.hex }};
  --text-2: {{ colors.on_surface.default.hex }};
  --text-3: {{ colors.on_surface_variant.default.hex }};
  --text-4: {{ colors.outline.default.hex }};
  --text-5: {{ colors.outline.default.hex }};

  /* Native Discord Tokens & Visual Refresh Fallback */
  --brand-500: {{ colors.primary.default.hex }} !important;
  --brand-560: {{ colors.primary_fixed_dim.default.hex }} !important;
  --brand-600: {{ colors.primary_container.default.hex }} !important;
  --brand-experiment: {{ colors.primary.default.hex }} !important;
  --text-link: {{ colors.primary.default.hex }} !important;
  --bg-base-primary: {{ colors.surface.default.hex }} !important;
  --bg-base-secondary: {{ colors.surface_container_low.default.hex }} !important;
  --bg-base-tertiary: {{ colors.surface_container.default.hex }} !important;
  --bg-surface-raised: {{ colors.surface_container_high.default.hex }} !important;
  --button-filled-brand-background: {{ colors.primary.default.hex }} !important;
  --button-filled-brand-text: {{ colors.on_primary.default.hex }} !important;
  --badge-notification-background: {{ colors.primary.default.hex }} !important;
}

.theme-dark,
.theme-light,
.visual-refresh,
.visual-refresh.theme-dark,
.visual-refresh .theme-dark {
  --brand-500: {{ colors.primary.default.hex }} !important;
  --brand-560: {{ colors.primary_fixed_dim.default.hex }} !important;
  --brand-600: {{ colors.primary_container.default.hex }} !important;
  --brand-experiment: {{ colors.primary.default.hex }} !important;
  --text-link: {{ colors.primary.default.hex }} !important;
  --bg-base-primary: {{ colors.surface.default.hex }} !important;
  --bg-base-secondary: {{ colors.surface_container_low.default.hex }} !important;
  --bg-base-tertiary: {{ colors.surface_container.default.hex }} !important;
  --bg-surface-raised: {{ colors.surface_container_high.default.hex }} !important;
  --button-filled-brand-background: {{ colors.primary.default.hex }} !important;
  --button-filled-brand-text: {{ colors.on_primary.default.hex }} !important;
  --badge-notification-background: {{ colors.primary.default.hex }} !important;
}
