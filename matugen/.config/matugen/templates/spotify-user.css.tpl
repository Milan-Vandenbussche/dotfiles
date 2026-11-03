/* Matugen Material You Spotify Stylesheet */

:root {
  --spice-text: {{ colors.on_surface.default.hex }};
  --spice-subtext: {{ colors.on_surface_variant.default.hex }};
  --spice-main: {{ colors.surface.default.hex }};
  --spice-sidebar: {{ colors.surface_container_low.default.hex }};
  --spice-player: {{ colors.surface_container.default.hex }};
  --spice-card: {{ colors.surface_container.default.hex }};
  --spice-shadow: 000000;
  --spice-selected-row: {{ colors.surface_container_high.default.hex }};
  --spice-button: {{ colors.primary.default.hex }};
  --spice-button-active: {{ colors.primary.default.hex }};
  --spice-button-disabled: {{ colors.outline.default.hex }};
  --spice-tab-active: {{ colors.primary.default.hex }};
  --spice-notification: {{ colors.primary_container.default.hex }};
  --spice-notification-error: {{ colors.error.default.hex }};
  --spice-misc: {{ colors.outline_variant.default.hex }};
}

/* Translucent backgrounds allowing Hyprland wallpaper blur */
.Root__top-container,
.Root__nav-bar,
.Root__main-view,
.main-view-container,
.under-main-view,
.main-home-content,
.main-topBar-container,
.main-topBar-background {
  background-color: transparent !important;
}

/* Sidebar translucency */
.Root__nav-bar,
.main-yourLibraryX-entryPoints {
  background-color: {{ colors.surface_container_low.default.hex }}bb !important;
}

/* Main content view translucency */
.main-view-container {
  background-color: {{ colors.surface.default.hex }}cc !important;
}

/* Bottom Player Bar */
.Root__now-playing-bar,
.main-nowPlayingBar-container {
  background-color: {{ colors.surface_container.default.hex }}e6 !important;
  border-top: 1px solid {{ colors.outline_variant.default.hex }}40 !important;
}

/* Primary Play Button */
.main-playButton-PlayButton,
.main-playButton-primary,
button[data-testid="play-button"],
.main-playPauseButton-button {
  background-color: {{ colors.primary.default.hex }} !important;
  color: {{ colors.on_primary.default.hex }} !important;
}
.main-playButton-PlayButton:hover,
.main-playButton-primary:hover,
button[data-testid="play-button"]:hover,
.main-playPauseButton-button:hover {
  transform: scale(1.05);
}

/* Progress bar & Volume bar */
.x-progressBar-fillColor,
.playback-progressbar-isInteractive .x-progressBar-fillColor,
.volume-bar .x-progressBar-fillColor {
  background-color: {{ colors.primary.default.hex }} !important;
}

/* Sliders background track */
.x-progressBar-progressBarBg {
  background-color: {{ colors.outline_variant.default.hex }}40 !important;
}

/* Track list row hover & selection */
.main-trackList-trackListRow:hover {
  background-color: {{ colors.surface_container_high.default.hex }}99 !important;
}
.main-trackList-trackListRow.main-trackList-selected {
  background-color: {{ colors.primary_container.default.hex }} !important;
}
.main-trackList-trackListRow.main-trackList-selected .main-trackList-rowTitle {
  color: {{ colors.on_primary_container.default.hex }} !important;
}

/* Active links, active tabs, and pill buttons */
.main-navBar-navBarLinkActive,
.main-navBar-navBarLinkActive .home-icon,
.main-navBar-navBarLinkActive .search-icon {
  color: {{ colors.primary.default.hex }} !important;
}

.main-buttons-button[aria-checked="true"],
.main-tag-selected {
  background-color: {{ colors.primary.default.hex }} !important;
  color: {{ colors.on_primary.default.hex }} !important;
}

/* Cards */
.main-card-card {
  background-color: {{ colors.surface_container.default.hex }}99 !important;
  border: 1px solid {{ colors.outline_variant.default.hex }}20 !important;
  transition: background-color 0.2s ease, transform 0.2s ease;
}
.main-card-card:hover {
  background-color: {{ colors.surface_container_high.default.hex }}cc !important;
}

/* Search bar */
.x-searchInput-searchInputInput {
  background-color: {{ colors.surface_container_high.default.hex }} !important;
  color: {{ colors.on_surface.default.hex }} !important;
  border-radius: 9999px !important;
  border: 1px solid {{ colors.outline_variant.default.hex }} !important;
}
.x-searchInput-searchInputInput:focus {
  border-color: {{ colors.primary.default.hex }} !important;
}

/* Connect to device bar */
.main-connectBar-connectBar {
  background-color: {{ colors.primary.default.hex }} !important;
  color: {{ colors.on_primary.default.hex }} !important;
}
