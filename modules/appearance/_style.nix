# One place for the desktop's shared look. Umbriel, the Noctalia bar and panels,
# foot, GTK and the fonts all read from here. Ignored by import-tree (leading _).
{
  font = "Maple Mono NF";

  # Background translucency for the bar, panels and terminals. Text and images
  # stay opaque; the compositor blurs whatever shows through.
  opacity = 0.85;

  # Strong frosted blur behind every translucent surface.
  blur = {
    passes = 4;
    radius = 8;
  };

  # Corner radius shared by windows and the bar.
  radius = 12;

  # Gap between windows; the floating bar is inset by the same amount.
  gap = 8;

  # Unfocused windows fade by this much; focus has no border or title bar.
  unfocusedDim = 0.2;
}
