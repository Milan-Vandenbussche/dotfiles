/**
 * @name Matugen
 * @author Matugen
 * @version 1.0.0
 * @description Dynamic Material You theme for Discord / Vesktop generated from wallpaper
*/

:root,
.theme-dark,
.theme-light,
.visual-refresh,
.visual-refresh.theme-dark,
.visual-refresh .theme-dark,
[class*="theme-"] {
  /* Discord Visual Refresh & Modern Tokens */
  --brand-500: {{ colors.primary.default.hex }} !important;
  --brand-560: {{ colors.primary_fixed_dim.default.hex }} !important;
  --brand-600: {{ colors.primary_container.default.hex }} !important;
  --brand-430: {{ colors.primary.default.hex }} !important;
  --brand-260: {{ colors.primary_container.default.hex }} !important;
  --status-brand: {{ colors.primary.default.hex }} !important;

  /* Legacy brand experiment */
  --brand-experiment: {{ colors.primary.default.hex }} !important;
  --brand-experiment-500: {{ colors.primary.default.hex }} !important;
  --brand-experiment-560: {{ colors.primary_fixed_dim.default.hex }} !important;
  --brand-experiment-600: {{ colors.primary_container.default.hex }} !important;
  --text-link: {{ colors.primary.default.hex }} !important;

  /* Surfaces & Backgrounds */
  --bg-base-primary: {{ colors.surface.default.hex }} !important;
  --bg-base-secondary: {{ colors.surface_container_low.default.hex }} !important;
  --bg-base-tertiary: {{ colors.surface_container.default.hex }} !important;
  --bg-surface-raised: {{ colors.surface_container_high.default.hex }} !important;
  --bg-surface-overlay: {{ colors.surface_container_high.default.hex }} !important;
  --bg-mod-subtle: {{ colors.surface_container_high.default.hex }}80 !important;
  --bg-mod-strong: {{ colors.primary_container.default.hex }} !important;

  /* Legacy Backgrounds */
  --background-primary: {{ colors.surface.default.hex }} !important;
  --background-secondary: {{ colors.surface_container_low.default.hex }} !important;
  --background-secondary-alt: {{ colors.surface_container.default.hex }} !important;
  --background-tertiary: {{ colors.surface_container.default.hex }} !important;
  --background-accent: {{ colors.surface_container_high.default.hex }} !important;
  --background-floating: {{ colors.surface_container_high.default.hex }} !important;
  --channeltextarea-background: {{ colors.surface_container.default.hex }} !important;
  --input-background: {{ colors.surface_container.default.hex }} !important;

  /* Text & Headers */
  --header-primary: {{ colors.on_surface.default.hex }} !important;
  --header-secondary: {{ colors.on_surface_variant.default.hex }} !important;
  --text-normal: {{ colors.on_surface.default.hex }} !important;
  --text-muted: {{ colors.outline.default.hex }} !important;
  --interactive-normal: {{ colors.on_surface_variant.default.hex }} !important;
  --interactive-hover: {{ colors.on_surface.default.hex }} !important;
  --interactive-active: {{ colors.primary.default.hex }} !important;
  --interactive-muted: {{ colors.outline.default.hex }} !important;

  /* Buttons & Badges */
  --button-filled-brand-background: {{ colors.primary.default.hex }} !important;
  --button-filled-brand-background-hover: {{ colors.primary.default.hex }}ee !important;
  --button-filled-brand-text: {{ colors.on_primary.default.hex }} !important;
  --badge-notification-background: {{ colors.primary.default.hex }} !important;
  --mention-background: {{ colors.primary.default.hex }}33 !important;
  --mention-foreground: {{ colors.primary.default.hex }} !important;

  /* Scrollbars */
  --scrollbar-auto-thumb: {{ colors.outline_variant.default.hex }}80 !important;
  --scrollbar-auto-track: transparent !important;
  --scrollbar-thin-thumb: {{ colors.outline_variant.default.hex }}80 !important;
}

/* Translucent panels allowing wallpaper blur */
.appMount_ea7e65,
.app_a01200,
.bg__960e4,
.container__5c7e7,
[class*="appMount_"],
[class*="app_"],
[class*="layers_"] {
  background: transparent !important;
}

/* Active Channel Pill & Mention Badges */
[class*="modeSelected_"] [class*="link_"],
[class*="modeSelected_"] [class*="link_"]:hover {
  background-color: {{ colors.primary_container.default.hex }} !important;
  color: {{ colors.on_primary_container.default.hex }} !important;
}

[class*="numberBadge_"] {
  background-color: {{ colors.primary.default.hex }} !important;
  color: {{ colors.on_primary.default.hex }} !important;
}
