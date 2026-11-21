# One place for the desktop's shared look. Umbriel, the Noctalia bar and panels,
# foot, GTK and the fonts all read from here. Ignored by import-tree (leading _).
{
  font = "Maple Mono NF";

  # Background translucency for the bar, panels, terminals and GTK apps. Text
  # and images stay opaque; the compositor blurs whatever shows through.
  opacity = 0.6;

  # Strong frosted glass, as in popular Hyprland/KDE "strong blur" setups. Each
  # pass halves the image: much past 4-5 passes the wallpaper collapses into
  # one flat color and the glass looks solid instead of blurrier.
  blur = {
    passes = 4;
    radius = 12;
  };

  # Corner radius shared by windows and the bar.
  radius = 12;

  # Gap between windows; the floating bar is inset by the same amount.
  gap = 8;

  # Unfocused windows are darkened by this fraction (colors only, never more
  # see-through); focus has no border or title bar.
  unfocusedDim = 0.12;
}
