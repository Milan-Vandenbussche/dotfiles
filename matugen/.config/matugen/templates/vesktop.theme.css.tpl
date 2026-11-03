/**
 * @name Matugen
 * @author Matugen
 * @version 1.0.0
 * @description Dynamic Material You theme for Discord / Vesktop generated from wallpaper
*/

:root {
  /* Accent / Brand Colors */
  --brand-experiment: {{ colors.primary.default.hex }} !important;
  --brand-experiment-500: {{ colors.primary.default.hex }} !important;
  --brand-experiment-560: {{ colors.primary_fixed_dim.default.hex }} !important;
  --brand-experiment-600: {{ colors.primary_container.default.hex }} !important;
  --text-link: {{ colors.primary.default.hex }} !important;

  /* Backgrounds & Surfaces */
  --background-primary: {{ colors.surface.default.hex }} !important;
  --background-secondary: {{ colors.surface_container_low.default.hex }} !important;
  --background-secondary-alt: {{ colors.surface_container.default.hex }} !important;
  --background-tertiary: {{ colors.surface_container.default.hex }} !important;
  --background-accent: {{ colors.surface_container_high.default.hex }} !important;
  --background-floating: {{ colors.surface_container_high.default.hex }} !important;
  --channeltextarea-background: {{ colors.surface_container.default.hex }} !important;

  /* Text & Content */
  --header-primary: {{ colors.on_surface.default.hex }} !important;
  --header-secondary: {{ colors.on_surface_variant.default.hex }} !important;
  --text-normal: {{ colors.on_surface.default.hex }} !important;
  --text-muted: {{ colors.outline.default.hex }} !important;
  --interactive-normal: {{ colors.on_surface_variant.default.hex }} !important;
  --interactive-hover: {{ colors.on_surface.default.hex }} !important;
  --interactive-active: {{ colors.primary.default.hex }} !important;
  --interactive-muted: {{ colors.outline.default.hex }} !important;

  /* Channels & Navigation */
  --channels-default: {{ colors.on_surface_variant.default.hex }} !important;
  --channel-icon: {{ colors.outline.default.hex }} !important;
  --status-positive: #9ece6a !important;
  --status-warning: #e0af68 !important;
  --status-danger: {{ colors.error.default.hex }} !important;

  /* Borders & Dividers */
  --border-subtle: {{ colors.outline_variant.default.hex }}40 !important;
  --scrollbar-auto-thumb: {{ colors.outline_variant.default.hex }}80 !important;
  --scrollbar-auto-track: transparent !important;
  --scrollbar-thin-thumb: {{ colors.outline_variant.default.hex }}80 !important;
}

/* Translucency for Hyprland blur */
.appMount_ea7e65,
.app_a01200,
.bg__960e4,
.container__5c7e7 {
  background: transparent !important;
}

/* Selected Channel Pill & Mention Badges */
.modeSelected__2ea32 .link__2ea32,
.modeSelected__2ea32 .link__2ea32:hover {
  background-color: {{ colors.primary_container.default.hex }} !important;
  color: {{ colors.on_primary_container.default.hex }} !important;
}

.numberBadge__2b0ff {
  background-color: {{ colors.primary.default.hex }} !important;
  color: {{ colors.on_primary.default.hex }} !important;
}
