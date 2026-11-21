# One place for the desktop's shared look. Umbriel, the Noctalia bar and panels,
# foot, GTK and the fonts all read from here. Ignored by import-tree (leading _).
{
  font = "Maple Mono NF";

  # Background translucency for the bar, panels, terminals and GTK apps. Text
  # and images stay opaque; the compositor blurs whatever shows through.
  opacity = 0.55;

  # Heavy frosted-glass blur behind every translucent surface.
  blur = {
    passes = 6;
    radius = 20;
  };

  # Corner radius shared by windows and the bar.
  radius = 12;

  # Gap between windows; the floating bar is inset by the same amount.
  gap = 8;

  # Unfocused windows are darkened by this fraction (colors only, never more
  # see-through); focus has no border or title bar.
  unfocusedDim = 0.12;
}
